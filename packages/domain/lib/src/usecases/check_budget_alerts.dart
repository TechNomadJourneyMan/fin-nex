import '../entities/budget.dart';
import '../repositories/analytics_repository.dart';
import '../repositories/budgets_repository.dart';
import '../values/money.dart';
import '../values/ulid.dart';

/// One row in the budget-alerts table.
class BudgetAlert {
  /// Default constructor.
  const BudgetAlert({
    required this.budget,
    required this.spent,
    required this.percent,
    required this.threshold,
  });

  /// The budget that triggered.
  final Budget budget;

  /// Amount spent within the budget scope and period.
  final Money spent;

  /// `spent / amount` clamped to `[0, 2]`.
  final double percent;

  /// The threshold that fired, e.g. 80.
  final int threshold;
}

/// Walks the user's active budgets and returns ones that crossed an alert
/// threshold.
class CheckBudgetAlerts {
  /// Default constructor.
  const CheckBudgetAlerts(this._budgets, this._analytics);

  final BudgetsRepository _budgets;
  final AnalyticsRepository _analytics;

  /// Invokes the use case for the current calendar period.
  Future<List<BudgetAlert>> call(
    Ulid userId, {
    required DateTime now,
  }) async {
    final budgets = await _budgets.listBudgets(userId);
    final alerts = <BudgetAlert>[];
    for (final b in budgets) {
      if (!b.isActive) {
        continue;
      }
      final slices = await _analytics.categoryBreakdown(
        userId,
        from: b.startsOn,
        to: b.endsOn ?? now,
      );
      Money spent = Money.zero(b.amount.currency);
      for (final s in slices) {
        if (b.categoryIds.isEmpty || b.categoryIds.contains(s.categoryId)) {
          if (s.amount.currency == b.amount.currency) {
            spent = spent + s.amount;
          }
        }
      }
      final pct = b.amount.isZero
          ? 0.0
          : spent.minor.toDouble() / b.amount.minor.toDouble();
      for (final t in b.alertThresholds) {
        if (pct * 100 >= t) {
          alerts.add(
            BudgetAlert(
              budget: b,
              spent: spent,
              percent: pct,
              threshold: t,
            ),
          );
          break;
        }
      }
    }
    return alerts;
  }
}
