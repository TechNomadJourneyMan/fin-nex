import '../values/money.dart';
import '../values/ulid.dart';

/// Aggregate snapshot for the dashboard header.
class DashboardSummary {
  /// Default constructor.
  const DashboardSummary({
    required this.netWorth,
    required this.incomeMonth,
    required this.expenseMonth,
    required this.savingsRate,
  });

  /// Total balance across includeInTotal accounts (in primary currency).
  final Money netWorth;

  /// Income in the current month.
  final Money incomeMonth;

  /// Expense in the current month.
  final Money expenseMonth;

  /// (income - expense) / income, clamped to [-1, 1].
  final double savingsRate;
}

/// A single slice in a category-breakdown pie/donut.
class CategoryBreakdownSlice {
  /// Default constructor.
  const CategoryBreakdownSlice({
    required this.categoryId,
    required this.amount,
    required this.percent,
  });

  /// Category ULID.
  final Ulid categoryId;

  /// Total spend in the period.
  final Money amount;

  /// Share of period total in `[0, 1]`.
  final double percent;
}

/// A single bucket in a cashflow time series.
class CashflowBucket {
  /// Default constructor.
  const CashflowBucket({
    required this.bucketStart,
    required this.income,
    required this.expense,
  });

  /// Inclusive bucket start.
  final DateTime bucketStart;

  /// Income in bucket.
  final Money income;

  /// Expense in bucket.
  final Money expense;

  /// Net = income - expense.
  Money get net => income - expense;
}

/// Pure-read aggregate queries for charts and dashboards.
abstract interface class AnalyticsRepository {
  /// Returns the dashboard summary for [userId] over the current month.
  Future<DashboardSummary> dashboardSummary(Ulid userId);

  /// Returns category breakdown for [userId] in `[from, to)`.
  Future<List<CategoryBreakdownSlice>> categoryBreakdown(
    Ulid userId, {
    required DateTime from,
    required DateTime to,
  });

  /// Returns time-bucketed cashflow for [userId].
  ///
  /// [bucketDays] controls bucket size (1 = daily, 7 = weekly, 30 = monthly).
  Future<List<CashflowBucket>> cashflow(
    Ulid userId, {
    required DateTime from,
    required DateTime to,
    required int bucketDays,
  });
}
