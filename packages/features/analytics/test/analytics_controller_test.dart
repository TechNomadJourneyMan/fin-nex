// Unit tests for the pure AnalyticsAggregator that powers
// AnalyticsController. The aggregator is exercised directly so the tests do
// not need a Riverpod container.

import 'package:flutter_test/flutter_test.dart';
import 'package:pf_domain/pf_domain.dart';
import 'package:pf_feat_analytics/analytics.dart';

void main() {
  group('AnalyticsAggregator.aggregate', () {
    const Currency currency = Currency.kzt;

    final Ulid userId = _ulid('A');
    final Ulid accountId = _ulid('B');
    final Ulid catFood = _ulid('F');
    final Ulid catRent = _ulid('R');
    final Ulid catSalary = _ulid('S');

    final DateTime now = DateTime(2025, 3, 15, 12);
    final AnalyticsPeriod monthPeriod =
        AnalyticsPeriod.of(AnalyticsPeriodKind.month, now: now);

    List<Transaction> fixture() => <Transaction>[
          _tx(
            id: 't1',
            userId: userId,
            accountId: accountId,
            type: TransactionType.expense,
            amount: Money.major(1000, currency),
            occurredAt: DateTime(2025, 3, 3, 9),
            categoryId: catFood,
          ),
          _tx(
            id: 't2',
            userId: userId,
            accountId: accountId,
            type: TransactionType.expense,
            amount: Money.major(2500, currency),
            occurredAt: DateTime(2025, 3, 5, 11),
            categoryId: catFood,
          ),
          _tx(
            id: 't3',
            userId: userId,
            accountId: accountId,
            type: TransactionType.expense,
            amount: Money.major(15000, currency),
            occurredAt: DateTime(2025, 3, 1, 10),
            categoryId: catRent,
          ),
          _tx(
            id: 't4',
            userId: userId,
            accountId: accountId,
            type: TransactionType.income,
            amount: Money.major(80000, currency),
            occurredAt: DateTime(2025, 3, 2, 9),
            categoryId: catSalary,
          ),
          // Transfer — must be ignored.
          _tx(
            id: 't5',
            userId: userId,
            accountId: accountId,
            type: TransactionType.transfer,
            amount: Money.major(5000, currency),
            occurredAt: DateTime(2025, 3, 4, 9),
            categoryId: null,
          ),
          // Soft-deleted — must be ignored.
          _tx(
            id: 't6',
            userId: userId,
            accountId: accountId,
            type: TransactionType.expense,
            amount: Money.major(9999, currency),
            occurredAt: DateTime(2025, 3, 10, 9),
            categoryId: catFood,
            deletedAt: DateTime(2025, 3, 11),
          ),
          // Outside period — must be ignored.
          _tx(
            id: 't7',
            userId: userId,
            accountId: accountId,
            type: TransactionType.expense,
            amount: Money.major(7777, currency),
            occurredAt: DateTime(2025, 2, 28, 9),
            categoryId: catFood,
          ),
        ];

    test('computes income, expense, and net totals', () {
      final AnalyticsSummary s = AnalyticsAggregator.aggregate(
        transactions: fixture(),
        period: monthPeriod,
        currency: currency,
      );
      expect(s.totalIncome, Money.major(80000, currency));
      expect(s.totalExpense, Money.major(18500, currency));
      expect(s.netFlow, Money.major(61500, currency));
      // 3 expenses + 1 income = 4 contributing transactions.
      expect(s.transactionCount, 4);
      // hasSparseData fires because count < 7.
      expect(s.hasSparseData, isTrue);
      expect(s.isEmpty, isFalse);
    });

    test('breaks down expenses by category, sorted desc', () {
      final AnalyticsSummary s = AnalyticsAggregator.aggregate(
        transactions: fixture(),
        period: monthPeriod,
        currency: currency,
      );
      expect(s.byCategory.length, 2);
      // Rent is the largest bucket.
      expect(s.byCategory.first.categoryId, catRent);
      expect(s.byCategory.first.amount, Money.major(15000, currency));
      // Percent shares sum to (approximately) 1.0.
      final double pctSum = s.byCategory.fold<double>(
        0,
        (double acc, AnalyticsCategoryBucket b) => acc + b.percent,
      );
      expect(pctSum, closeTo(1.0, 0.0001));
      // Food is second.
      expect(s.byCategory[1].categoryId, catFood);
      expect(s.byCategory[1].amount, Money.major(3500, currency));
      expect(s.byCategory[1].transactionCount, 2);
    });

    test('produces 7 weekday buckets and chronological cashflow', () {
      final AnalyticsSummary s = AnalyticsAggregator.aggregate(
        transactions: fixture(),
        period: monthPeriod,
        currency: currency,
      );
      expect(s.byWeekday.length, 7);
      expect(s.cashflow, isNotEmpty);
      for (int i = 1; i < s.cashflow.length; i++) {
        expect(
          s.cashflow[i].bucketStart.isAfter(s.cashflow[i - 1].bucketStart),
          isTrue,
        );
      }
    });

    test('returns an empty summary when no transactions contribute', () {
      final AnalyticsSummary s = AnalyticsAggregator.aggregate(
        transactions: const <Transaction>[],
        period: monthPeriod,
        currency: currency,
      );
      expect(s.isEmpty, isTrue);
      expect(s.totalIncome.isZero, isTrue);
      expect(s.totalExpense.isZero, isTrue);
      expect(s.byCategory, isEmpty);
      expect(s.cashflow, isEmpty);
    });

    test('skips currency-mismatched rows', () {
      final List<Transaction> txs = <Transaction>[
        _tx(
          id: 'x1',
          userId: userId,
          accountId: accountId,
          type: TransactionType.expense,
          amount: Money.major(100, Currency.usd),
          occurredAt: DateTime(2025, 3, 7),
          categoryId: catFood,
        ),
      ];
      final AnalyticsSummary s = AnalyticsAggregator.aggregate(
        transactions: txs,
        period: monthPeriod,
        currency: currency,
      );
      expect(s.transactionCount, 0);
      expect(s.totalExpense.isZero, isTrue);
    });
  });

  group('AnalyticsPeriod', () {
    test('month period spans an exact calendar month', () {
      final AnalyticsPeriod p = AnalyticsPeriod.of(
        AnalyticsPeriodKind.month,
        now: DateTime(2025, 3, 15),
      );
      expect(p.from, DateTime(2025, 3, 1));
      expect(p.to, DateTime(2025, 4, 1));
    });

    test('week period is Mon-anchored', () {
      // 2025-03-15 is a Saturday.
      final AnalyticsPeriod p = AnalyticsPeriod.of(
        AnalyticsPeriodKind.week,
        now: DateTime(2025, 3, 15),
      );
      expect(p.from.weekday, DateTime.monday);
      expect(p.to.difference(p.from).inDays, 7);
    });

    test('year period spans the calendar year', () {
      final AnalyticsPeriod p = AnalyticsPeriod.of(
        AnalyticsPeriodKind.year,
        now: DateTime(2025, 7, 4),
      );
      expect(p.from, DateTime(2025, 1, 1));
      expect(p.to, DateTime(2026, 1, 1));
      expect(p.bucketDays, 30);
    });
  });
}

Ulid _ulid(String seed) {
  // ULID is 26 chars of Crockford base-32. Pad the seed deterministically.
  const String alphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';
  final StringBuffer b = StringBuffer();
  for (int i = 0; i < 26; i++) {
    final int idx = (seed.codeUnitAt(i % seed.length) + i) % alphabet.length;
    b.write(alphabet[idx]);
  }
  return Ulid(b.toString());
}

Transaction _tx({
  required String id,
  required Ulid userId,
  required Ulid accountId,
  required TransactionType type,
  required Money amount,
  required DateTime occurredAt,
  Ulid? categoryId,
  DateTime? deletedAt,
}) {
  return Transaction(
    id: _ulid(id.padRight(4, 'X')),
    userId: userId,
    accountId: accountId,
    type: type,
    amount: amount,
    occurredAt: occurredAt,
    createdAt: occurredAt,
    updatedAt: occurredAt,
    source: 'manual',
    attachmentIds: const <Ulid>[],
    tagIds: const <Ulid>[],
    categoryId: categoryId,
    deletedAt: deletedAt,
  );
}
