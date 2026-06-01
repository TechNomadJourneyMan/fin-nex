import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_domain/pf_domain.dart';

import '../analytics_summary.dart';
import '../providers.dart';
import '../state/analytics_period.dart';

/// Reactive aggregator that produces the [AnalyticsSummary] driving the
/// Analytics screen.
///
/// Listens to the transactions stream and the period selection; recomputes
/// purely in memory via [AnalyticsAggregator]. All math is currency-aware
/// using the active display currency.
class AnalyticsController extends AsyncNotifier<AnalyticsSummary> {
  @override
  Future<AnalyticsSummary> build() async {
    final AnalyticsPeriod period = ref.watch(analyticsPeriodProvider);
    final Currency currency = ref.watch(analyticsDisplayCurrencyProvider);
    final List<Transaction> all = await ref.watch(
      analyticsTransactionsStreamProvider.future,
    );
    return AnalyticsAggregator.aggregate(
      transactions: all,
      period: period,
      currency: currency,
    );
  }

  /// Updates the selected [AnalyticsPeriod].
  void selectPeriod(AnalyticsPeriod period) {
    ref.read(analyticsPeriodProvider.notifier).state = period;
  }
}

/// Riverpod provider for [AnalyticsController].
final analyticsControllerProvider =
    AsyncNotifierProvider<AnalyticsController, AnalyticsSummary>(
  AnalyticsController.new,
);

/// Pure aggregator — exposed as a static so unit tests can exercise it
/// without spinning up Riverpod.
abstract final class AnalyticsAggregator {
  /// Aggregates [transactions] (already filtered or unfiltered) into an
  /// [AnalyticsSummary] for [period] in [currency].
  ///
  /// Transactions whose `occurredAt` lies outside `[period.from, period.to)`
  /// are skipped. Soft-deleted, transfer, and adjustment rows are excluded —
  /// only income/expense entries contribute to the summary.
  ///
  /// Mismatched-currency transactions are skipped (a future revision will
  /// FX-convert; for MVP we only sum exact matches).
  static AnalyticsSummary aggregate({
    required List<Transaction> transactions,
    required AnalyticsPeriod period,
    required Currency currency,
  }) {
    Money income = Money.zero(currency);
    Money expense = Money.zero(currency);
    int count = 0;

    // Category buckets keyed by category ULID string (null → empty key).
    final Map<String, _CategoryAccumulator> byCategory =
        <String, _CategoryAccumulator>{};

    // Weekday buckets — index 0..6 == Mon..Sun.
    final List<_TimeAccumulator> byWeekday = List<_TimeAccumulator>.generate(
      7,
      (int i) => _TimeAccumulator(currency: currency),
      growable: false,
    );

    // Cashflow buckets, keyed by bucket-start (local midnight) ISO string.
    final Map<DateTime, _TimeAccumulator> cashflowMap =
        <DateTime, _TimeAccumulator>{};

    final int bucketDays = period.bucketDays;

    for (final Transaction tx in transactions) {
      if (tx.deletedAt != null) continue;
      if (tx.type != TransactionType.income &&
          tx.type != TransactionType.expense) {
        continue;
      }
      if (tx.amount.currency != currency) continue;
      final DateTime when = tx.occurredAt.toLocal();
      if (when.isBefore(period.from)) continue;
      if (!when.isBefore(period.to)) continue;

      count++;

      // Totals.
      if (tx.type == TransactionType.income) {
        income = income + tx.amount;
      } else {
        expense = expense + tx.amount;
      }

      // By category (expenses only — income breakdown is out of scope MVP).
      if (tx.type == TransactionType.expense) {
        final String key = tx.categoryId?.value ?? '';
        final _CategoryAccumulator acc = byCategory.putIfAbsent(
          key,
          () => _CategoryAccumulator(
            categoryId: tx.categoryId,
            currency: currency,
          ),
        );
        acc.add(tx.amount);
      }

      // Weekday bucket.
      final int weekdayIdx = when.weekday - 1; // 1..7 → 0..6
      final _TimeAccumulator weekdayBucket = byWeekday[weekdayIdx];
      if (tx.type == TransactionType.income) {
        weekdayBucket.addIncome(tx.amount);
      } else {
        weekdayBucket.addExpense(tx.amount);
      }

      // Cashflow bucket start.
      final DateTime bucketStart = _bucketStart(when, period, bucketDays);
      final _TimeAccumulator cfBucket = cashflowMap.putIfAbsent(
        bucketStart,
        () => _TimeAccumulator(currency: currency),
      );
      if (tx.type == TransactionType.income) {
        cfBucket.addIncome(tx.amount);
      } else {
        cfBucket.addExpense(tx.amount);
      }
    }

    if (count == 0) {
      return AnalyticsSummary.empty(period, currency);
    }

    // Category buckets, sorted by amount descending.
    final List<AnalyticsCategoryBucket> categoryBuckets = byCategory.values
        .map((_CategoryAccumulator a) {
      final double pct =
          expense.isZero ? 0 : _ratio(a.total.minor, expense.minor);
      return AnalyticsCategoryBucket(
        categoryId: a.categoryId,
        amount: a.total,
        percent: pct,
        transactionCount: a.count,
      );
    }).toList(growable: false)
      ..sort((AnalyticsCategoryBucket a, AnalyticsCategoryBucket b) =>
          b.amount.compareTo(a.amount));

    // Weekday list (always 7 entries, anchored to ISO Mon..Sun).
    final DateTime weekdayAnchor = DateTime(2024, 1, 1); // Monday.
    final List<AnalyticsTimeBucket> weekdayBuckets =
        List<AnalyticsTimeBucket>.generate(7, (int i) {
      final _TimeAccumulator a = byWeekday[i];
      return AnalyticsTimeBucket(
        bucketStart: weekdayAnchor.add(Duration(days: i)),
        income: a.income,
        expense: a.expense,
      );
    }, growable: false);

    // Cashflow list, sorted chronologically.
    final List<AnalyticsTimeBucket> cashflowBuckets = cashflowMap.entries
        .map((MapEntry<DateTime, _TimeAccumulator> e) => AnalyticsTimeBucket(
              bucketStart: e.key,
              income: e.value.income,
              expense: e.value.expense,
            ))
        .toList(growable: false)
      ..sort((AnalyticsTimeBucket a, AnalyticsTimeBucket b) =>
          a.bucketStart.compareTo(b.bucketStart));

    return AnalyticsSummary(
      period: period,
      currency: currency,
      totalIncome: income,
      totalExpense: expense,
      byCategory: categoryBuckets,
      byWeekday: weekdayBuckets,
      cashflow: cashflowBuckets,
      transactionCount: count,
    );
  }

  static DateTime _bucketStart(
    DateTime when,
    AnalyticsPeriod period,
    int bucketDays,
  ) {
    final DateTime dayMidnight = DateTime(when.year, when.month, when.day);
    if (bucketDays <= 1) return dayMidnight;
    final int daysSincePeriodStart = dayMidnight.difference(period.from).inDays;
    final int bucketIndex = daysSincePeriodStart ~/ bucketDays;
    return period.from.add(Duration(days: bucketIndex * bucketDays));
  }

  static double _ratio(BigInt part, BigInt whole) {
    if (whole == BigInt.zero) return 0;
    // Convert via 6-decimal scaled ratio to avoid huge BigInt → double loss.
    final BigInt scale = BigInt.from(1000000);
    final BigInt scaled = (part * scale) ~/ whole;
    return scaled.toInt() / 1000000.0;
  }
}

class _CategoryAccumulator {
  _CategoryAccumulator({required this.categoryId, required Currency currency})
      : total = Money.zero(currency);

  final Ulid? categoryId;
  Money total;
  int count = 0;

  void add(Money amount) {
    total = total + amount;
    count++;
  }
}

class _TimeAccumulator {
  _TimeAccumulator({required Currency currency})
      : income = Money.zero(currency),
        expense = Money.zero(currency);

  Money income;
  Money expense;

  void addIncome(Money m) => income = income + m;
  void addExpense(Money m) => expense = expense + m;
}
