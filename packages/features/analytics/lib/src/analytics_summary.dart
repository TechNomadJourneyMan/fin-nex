import 'package:equatable/equatable.dart';
import 'package:fnx_domain/fnx_domain.dart';

import 'state/analytics_period.dart';

/// A single category bucket in the analytics summary.
class AnalyticsCategoryBucket extends Equatable {
  /// Default constructor.
  const AnalyticsCategoryBucket({
    required this.categoryId,
    required this.amount,
    required this.percent,
    required this.transactionCount,
  });

  /// Category ULID; null indicates "Uncategorised".
  final Ulid? categoryId;

  /// Total spend in the period for this category.
  final Money amount;

  /// Share of period expense in `[0, 1]`.
  final double percent;

  /// Number of contributing transactions.
  final int transactionCount;

  @override
  List<Object?> get props =>
      <Object?>[categoryId, amount, percent, transactionCount];
}

/// A single time bucket — used for bar/line charts and the calendar heatmap.
class AnalyticsTimeBucket extends Equatable {
  /// Default constructor.
  const AnalyticsTimeBucket({
    required this.bucketStart,
    required this.income,
    required this.expense,
  });

  /// Inclusive bucket start (local midnight).
  final DateTime bucketStart;

  /// Income in the bucket.
  final Money income;

  /// Expense in the bucket.
  final Money expense;

  /// Signed net flow.
  Money get net => income - expense;

  @override
  List<Object?> get props => <Object?>[bucketStart, income, expense];
}

/// Pure value-type that drives the Analytics screen.
///
/// All amounts share [currency]. Empty periods yield an instance with
/// `transactionCount == 0` and zeroed totals so the UI can still render a
/// meaningful empty state.
class AnalyticsSummary extends Equatable {
  /// Default constructor.
  const AnalyticsSummary({
    required this.period,
    required this.currency,
    required this.totalIncome,
    required this.totalExpense,
    required this.byCategory,
    required this.byWeekday,
    required this.cashflow,
    required this.transactionCount,
  });

  /// Constructs an empty summary for [period] with [currency].
  factory AnalyticsSummary.empty(AnalyticsPeriod period, Currency currency) {
    return AnalyticsSummary(
      period: period,
      currency: currency,
      totalIncome: Money.zero(currency),
      totalExpense: Money.zero(currency),
      byCategory: const <AnalyticsCategoryBucket>[],
      byWeekday: const <AnalyticsTimeBucket>[],
      cashflow: const <AnalyticsTimeBucket>[],
      transactionCount: 0,
    );
  }

  /// Period the summary was computed for.
  final AnalyticsPeriod period;

  /// Currency of all monetary values.
  final Currency currency;

  /// Sum of income transactions.
  final Money totalIncome;

  /// Sum of expense transactions (positive magnitude).
  final Money totalExpense;

  /// Expense breakdown by category, sorted descending by amount.
  final List<AnalyticsCategoryBucket> byCategory;

  /// Bar-chart data — one bucket per weekday (Mon..Sun) for week-style
  /// periods, or one bucket per period segment otherwise.
  final List<AnalyticsTimeBucket> byWeekday;

  /// Line/area-chart data — chronological cashflow buckets.
  final List<AnalyticsTimeBucket> cashflow;

  /// Total contributing transactions.
  final int transactionCount;

  /// Net flow = income − expense.
  Money get netFlow => totalIncome - totalExpense;

  /// True if no transactions contributed to this summary.
  bool get isEmpty => transactionCount == 0;

  /// Heuristic for "very few transactions" — used to suppress noisy charts.
  bool get hasSparseData => transactionCount > 0 && transactionCount < 7;

  @override
  List<Object?> get props => <Object?>[
        period,
        currency,
        totalIncome,
        totalExpense,
        byCategory,
        byWeekday,
        cashflow,
        transactionCount,
      ];
}
