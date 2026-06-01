// Pure-Dart helpers that compute spend totals for a budget within its
// active period from a stream/list of transactions.
//
// Web-safe: no Flutter, no native bindings.

import 'package:pf_domain/domain.dart';

/// The closed/half-open `[start, end)` window that a [Budget] covers
/// "right now" relative to a reference [DateTime].
class BudgetPeriodWindow {
  /// Creates a window.
  const BudgetPeriodWindow({required this.start, required this.end});

  /// Inclusive lower bound.
  final DateTime start;

  /// Exclusive upper bound.
  final DateTime end;

  /// True if [t] falls inside `[start, end)`.
  bool contains(DateTime t) =>
      !t.isBefore(start) && t.isBefore(end);
}

/// Pure functions that compute budget progress.
class BudgetCalculator {
  /// Const constructor.
  const BudgetCalculator();

  /// Returns the current `[start, end)` window for [budget] relative to
  /// [now]. Implements the policy from `04_prd.md` (Budgets):
  ///
  /// - `weekly`   → ISO Monday week containing [now].
  /// - `monthly`  → calendar month containing [now].
  /// - `quarterly`→ calendar quarter containing [now].
  /// - `yearly`   → calendar year containing [now].
  /// - `custom`   → `[budget.startsOn, budget.endsOn)` or rolling 30-day
  ///                window starting at `budget.startsOn` if `endsOn` is null.
  BudgetPeriodWindow periodWindow(Budget budget, DateTime now) {
    final ref = now.toLocal();
    switch (budget.period) {
      case BudgetPeriod.weekly:
        // ISO week: Monday = 1, Sunday = 7.
        final startOfDay = DateTime(ref.year, ref.month, ref.day);
        final start =
            startOfDay.subtract(Duration(days: ref.weekday - 1));
        final end = start.add(const Duration(days: 7));
        return BudgetPeriodWindow(start: start, end: end);
      case BudgetPeriod.monthly:
        final start = DateTime(ref.year, ref.month, 1);
        final end = DateTime(ref.year, ref.month + 1, 1);
        return BudgetPeriodWindow(start: start, end: end);
      case BudgetPeriod.quarterly:
        final q = ((ref.month - 1) ~/ 3) * 3 + 1;
        final start = DateTime(ref.year, q, 1);
        final end = DateTime(ref.year, q + 3, 1);
        return BudgetPeriodWindow(start: start, end: end);
      case BudgetPeriod.yearly:
        final start = DateTime(ref.year, 1, 1);
        final end = DateTime(ref.year + 1, 1, 1);
        return BudgetPeriodWindow(start: start, end: end);
      case BudgetPeriod.custom:
        final start = budget.startsOn.toLocal();
        final end = budget.endsOn?.toLocal() ??
            start.add(const Duration(days: 30));
        return BudgetPeriodWindow(start: start, end: end);
    }
  }

  /// Filters [txs] to those that count against [budget]: occur inside its
  /// current [periodWindow], are non-deleted expense transactions, and
  /// match the budget's category / account scope (empty scope = all).
  Iterable<Transaction> applicableTransactions(
    Budget budget,
    Iterable<Transaction> txs, {
    DateTime? now,
  }) {
    final window = periodWindow(budget, now ?? DateTime.now());
    final cats = budget.categoryIds.toSet();
    final accts = budget.accountIds.toSet();
    return txs.where((t) {
      if (t.deletedAt != null) {
        return false;
      }
      if (t.type != TransactionType.expense) {
        return false;
      }
      if (!window.contains(t.occurredAt.toLocal())) {
        return false;
      }
      if (cats.isNotEmpty &&
          (t.categoryId == null || !cats.contains(t.categoryId))) {
        return false;
      }
      if (accts.isNotEmpty && !accts.contains(t.accountId)) {
        return false;
      }
      if (t.amount.currency != budget.amount.currency) {
        return false;
      }
      return true;
    });
  }

  /// Sums [applicableTransactions] for [budget] as [Money] in the budget's
  /// currency. Returns zero when no transactions match.
  Money spent(
    Budget budget,
    Iterable<Transaction> txs, {
    DateTime? now,
  }) {
    final initial = Money.zero(budget.amount.currency);
    return applicableTransactions(budget, txs, now: now)
        .fold<Money>(initial, (m, t) => m + t.amount);
  }

  /// Spend ratio (0–∞). 0 means nothing spent; values > 1 mean over budget.
  /// Returns 0 if the budget cap is zero or negative.
  double ratio(Budget budget, Iterable<Transaction> txs, {DateTime? now}) {
    if (budget.amount.minor <= BigInt.zero) {
      return 0;
    }
    final s = spent(budget, txs, now: now).minor;
    final cap = budget.amount.minor;
    return s / cap;
  }

  /// Highest alert threshold that has been hit by the current spend.
  /// Returns null when none of [Budget.alertThresholds] have been reached.
  int? hitThreshold(
    Budget budget,
    Iterable<Transaction> txs, {
    DateTime? now,
  }) {
    final pct = (ratio(budget, txs, now: now) * 100).floor();
    int? highest;
    for (final t in budget.alertThresholds) {
      if (pct >= t && (highest == null || t > highest)) {
        highest = t;
      }
    }
    return highest;
  }
}
