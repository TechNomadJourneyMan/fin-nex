import 'package:pf_domain/domain.dart';

import 'rule_context.dart';

/// Signature of an insight rule. Each rule is a pure function over [RuleContext]
/// that returns `null` when no insight is warranted.
typedef InsightRule = Insight? Function(RuleContext ctx);

/// Stable per-rule keys (used for dismissal suppression and analytics).
abstract final class InsightRuleKeys {
  /// "Spent X% more than last week on category Y".
  static const String weekOverWeekSpike = 'week_over_week_spike';

  /// "Approaching budget limit (>= 80%)".
  static const String budgetWarning = 'budget_warning';

  /// "Budget exceeded (>= 100%)".
  static const String budgetExceeded = 'budget_exceeded';

  /// "Top spending category this week".
  static const String topCategoryWeek = 'top_category_week';

  /// "Longest streak ever".
  static const String longestStreak = 'longest_streak';

  /// "Current streak is X days".
  static const String currentStreak = 'current_streak';

  /// "Saved money compared to last week".
  static const String saveOpportunity = 'save_opportunity';

  /// "Income vs expense balance positive this month".
  static const String surplusMonth = 'surplus_month';

  /// "Income vs expense balance negative this month".
  static const String deficitMonth = 'deficit_month';

  /// "Subscription detected: same merchant N times monthly".
  static const String subscriptionDetected = 'subscription_detected';

  /// "No transactions logged in N days".
  static const String inactivityWarning = 'inactivity_warning';

  /// "Largest single expense this month".
  static const String largestExpense = 'largest_expense';

  /// "Average daily spend this week vs last week".
  static const String dailyAverageChange = 'daily_average_change';

  /// "Weekend spend is X% of total".
  static const String weekendShare = 'weekend_share';

  /// "Category Y is X% of total expenses".
  static const String categoryShare = 'category_share';

  /// "New category started being used this week".
  static const String newCategoryUsage = 'new_category_usage';

  /// "Consecutive days under budget".
  static const String underBudgetStreak = 'under_budget_streak';

  /// "First income recorded this period".
  static const String firstIncome = 'first_income';

  /// "Cash flow positive trend".
  static const String cashflowTrend = 'cashflow_trend';

  /// "Forecast: at current pace, will exceed budget by month-end".
  static const String budgetForecast = 'budget_forecast';
}

/// Pure helpers shared by the rules.
abstract final class _Calc {
  static DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime startOfWeek(DateTime d) {
    // Treats Monday as the first day of the week.
    final dayOfWeek = d.weekday; // 1..7
    final delta = dayOfWeek - DateTime.monday;
    return startOfDay(d.subtract(Duration(days: delta)));
  }

  static DateTime startOfMonth(DateTime d) => DateTime(d.year, d.month, 1);

  static Iterable<Transaction> expensesBetween(
    Iterable<Transaction> tx,
    DateTime startInclusive,
    DateTime endExclusive,
  ) sync* {
    for (final t in tx) {
      if (t.type != TransactionType.expense) {
        continue;
      }
      if (t.deletedAt != null) {
        continue;
      }
      if (t.occurredAt.isBefore(startInclusive)) {
        continue;
      }
      if (!t.occurredAt.isBefore(endExclusive)) {
        continue;
      }
      yield t;
    }
  }

  static BigInt sumMinor(Iterable<Transaction> tx) {
    var sum = BigInt.zero;
    for (final t in tx) {
      sum += t.amount.minor;
    }
    return sum;
  }

}

Insight _build({
  required RuleContext ctx,
  required String ruleKey,
  required String title,
  required String body,
  required InsightSeverity severity,
  double? score,
  Map<String, dynamic> payload = const <String, dynamic>{},
}) {
  return Insight(
    id: Ulid.now(),
    userId: ctx.userId,
    kind: ruleKey,
    title: title,
    body: body,
    severity: severity,
    generatedAt: ctx.currentDate,
    expiresAt: ctx.currentDate.add(const Duration(days: 14)),
    payload: payload,
    score: score,
  );
}

// ---- Individual rules --------------------------------------------------- //

/// Week-over-week spending spike (any category).
Insight? weekOverWeekSpikeRule(RuleContext ctx) {
  if (ctx.isSuppressed(InsightRuleKeys.weekOverWeekSpike)) {
    return null;
  }
  final now = ctx.currentDate;
  final thisWeekStart = _Calc.startOfWeek(now);
  final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));

  final thisWeek = _Calc.sumMinor(
    _Calc.expensesBetween(ctx.transactions, thisWeekStart, now),
  );
  final lastWeek = _Calc.sumMinor(
    _Calc.expensesBetween(ctx.transactions, lastWeekStart, thisWeekStart),
  );

  if (lastWeek == BigInt.zero) {
    return null;
  }
  final ratio = thisWeek.toDouble() / lastWeek.toDouble();
  if (ratio < 1.25) {
    return null;
  }
  final pct = ((ratio - 1) * 100).round();
  return _build(
    ctx: ctx,
    ruleKey: InsightRuleKeys.weekOverWeekSpike,
    title: 'Spending is up $pct% this week',
    body:
        "You're spending $pct% more than last week. Tap to see the biggest categories.",
    severity: InsightSeverity.warning,
    score: pct.toDouble().clamp(0, 100),
    payload: <String, dynamic>{'pct': pct, 'ratio': ratio},
  );
}

/// Approaching a budget limit (>= 80%, < 100%).
Insight? budgetWarningRule(RuleContext ctx) {
  if (ctx.isSuppressed(InsightRuleKeys.budgetWarning)) {
    return null;
  }
  for (final b in ctx.budgets) {
    if (!b.isActive) {
      continue;
    }
    final start = b.startsOn.isBefore(ctx.currentDate) ? b.startsOn : null;
    if (start == null) {
      continue;
    }
    final spent = _Calc.sumMinor(
      _Calc.expensesBetween(ctx.transactions, start, ctx.currentDate)
          .where((t) =>
              b.categoryIds.isEmpty || b.categoryIds.contains(t.categoryId)),
    );
    if (b.amount.minor == BigInt.zero) {
      continue;
    }
    final used = spent.toDouble() / b.amount.minor.toDouble();
    if (used < 0.8 || used >= 1) {
      continue;
    }
    final pct = (used * 100).round();
    return _build(
      ctx: ctx,
      ruleKey: InsightRuleKeys.budgetWarning,
      title: 'Budget "${b.name}" at $pct%',
      body: "You're approaching the limit. Consider slowing down.",
      severity: InsightSeverity.warning,
      payload: <String, dynamic>{'budget_id': b.id.value, 'used': used},
    );
  }
  return null;
}

/// Budget exceeded (>= 100%).
Insight? budgetExceededRule(RuleContext ctx) {
  if (ctx.isSuppressed(InsightRuleKeys.budgetExceeded)) {
    return null;
  }
  for (final b in ctx.budgets) {
    if (!b.isActive) {
      continue;
    }
    final start = b.startsOn;
    final spent = _Calc.sumMinor(
      _Calc.expensesBetween(ctx.transactions, start, ctx.currentDate)
          .where((t) =>
              b.categoryIds.isEmpty || b.categoryIds.contains(t.categoryId)),
    );
    if (b.amount.minor == BigInt.zero) {
      continue;
    }
    if (spent < b.amount.minor) {
      continue;
    }
    final pct = (spent.toDouble() / b.amount.minor.toDouble() * 100).round();
    return _build(
      ctx: ctx,
      ruleKey: InsightRuleKeys.budgetExceeded,
      title: 'Budget "${b.name}" exceeded',
      body: 'You spent $pct% of this budget.',
      severity: InsightSeverity.warning,
      payload: <String, dynamic>{'budget_id': b.id.value, 'pct': pct},
    );
  }
  return null;
}

/// Top spending category this week.
Insight? topCategoryWeekRule(RuleContext ctx) {
  if (ctx.isSuppressed(InsightRuleKeys.topCategoryWeek)) {
    return null;
  }
  final start = _Calc.startOfWeek(ctx.currentDate);
  final perCategory = <Ulid, BigInt>{};
  for (final t in _Calc.expensesBetween(
    ctx.transactions,
    start,
    ctx.currentDate,
  )) {
    final c = t.categoryId;
    if (c == null) {
      continue;
    }
    perCategory[c] = (perCategory[c] ?? BigInt.zero) + t.amount.minor;
  }
  if (perCategory.isEmpty) {
    return null;
  }
  final sorted = perCategory.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final top = sorted.first;
  return _build(
    ctx: ctx,
    ruleKey: InsightRuleKeys.topCategoryWeek,
    title: 'Top category this week: ${ctx.categoryName(top.key)}',
    body: 'Your highest spend this week was in ${ctx.categoryName(top.key)}.',
    severity: InsightSeverity.info,
    payload: <String, dynamic>{'category_id': top.key.value},
  );
}

/// Longest-ever streak surfaced as a celebration.
Insight? longestStreakRule(RuleContext ctx) {
  if (ctx.isSuppressed(InsightRuleKeys.longestStreak)) {
    return null;
  }
  final streak = ctx.streak;
  if (streak == null || streak.longestStreakDays < 7) {
    return null;
  }
  if (streak.currentStreakDays != streak.longestStreakDays) {
    return null;
  }
  return _build(
    ctx: ctx,
    ruleKey: InsightRuleKeys.longestStreak,
    title: 'New record: ${streak.longestStreakDays}-day streak!',
    body: 'You just hit your longest tracking streak. Keep it going!',
    severity: InsightSeverity.celebration,
    payload: <String, dynamic>{'days': streak.longestStreakDays},
  );
}

/// Current streak (>= 3 days) as an encouragement.
Insight? currentStreakRule(RuleContext ctx) {
  if (ctx.isSuppressed(InsightRuleKeys.currentStreak)) {
    return null;
  }
  final streak = ctx.streak;
  if (streak == null || streak.currentStreakDays < 3) {
    return null;
  }
  if (streak.currentStreakDays == streak.longestStreakDays) {
    return null; // handled by longestStreakRule
  }
  return _build(
    ctx: ctx,
    ruleKey: InsightRuleKeys.currentStreak,
    title: '${streak.currentStreakDays}-day streak',
    body: 'Log today to keep your streak alive.',
    severity: InsightSeverity.tip,
    payload: <String, dynamic>{'days': streak.currentStreakDays},
  );
}

/// Save opportunity: spent less than last week.
Insight? saveOpportunityRule(RuleContext ctx) {
  if (ctx.isSuppressed(InsightRuleKeys.saveOpportunity)) {
    return null;
  }
  final now = ctx.currentDate;
  final thisWeekStart = _Calc.startOfWeek(now);
  final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
  final thisWeek = _Calc.sumMinor(
    _Calc.expensesBetween(ctx.transactions, thisWeekStart, now),
  );
  final lastWeek = _Calc.sumMinor(
    _Calc.expensesBetween(ctx.transactions, lastWeekStart, thisWeekStart),
  );
  if (lastWeek == BigInt.zero || thisWeek >= lastWeek) {
    return null;
  }
  final diff = lastWeek - thisWeek;
  final pct = (diff.toDouble() / lastWeek.toDouble() * 100).round();
  if (pct < 10) {
    return null;
  }
  return _build(
    ctx: ctx,
    ruleKey: InsightRuleKeys.saveOpportunity,
    title: 'Spending down $pct% this week',
    body: "Nice — you're spending less than last week. Consider stashing the difference.",
    severity: InsightSeverity.celebration,
    payload: <String, dynamic>{'pct': pct},
  );
}

/// Positive cash flow this month.
Insight? surplusMonthRule(RuleContext ctx) {
  if (ctx.isSuppressed(InsightRuleKeys.surplusMonth)) {
    return null;
  }
  final start = _Calc.startOfMonth(ctx.currentDate);
  var income = BigInt.zero;
  var expense = BigInt.zero;
  for (final t in ctx.transactions) {
    if (t.deletedAt != null) {
      continue;
    }
    if (t.occurredAt.isBefore(start)) {
      continue;
    }
    if (t.occurredAt.isAfter(ctx.currentDate)) {
      continue;
    }
    if (t.type == TransactionType.income) {
      income += t.amount.minor;
    } else if (t.type == TransactionType.expense) {
      expense += t.amount.minor;
    }
  }
  if (income == BigInt.zero || expense >= income) {
    return null;
  }
  final surplus = income - expense;
  final pct = (surplus.toDouble() / income.toDouble() * 100).round();
  return _build(
    ctx: ctx,
    ruleKey: InsightRuleKeys.surplusMonth,
    title: '$pct% surplus this month',
    body: "You've spent less than you've earned. Great pace!",
    severity: InsightSeverity.celebration,
    payload: <String, dynamic>{'pct': pct},
  );
}

/// Negative cash flow this month.
Insight? deficitMonthRule(RuleContext ctx) {
  if (ctx.isSuppressed(InsightRuleKeys.deficitMonth)) {
    return null;
  }
  final start = _Calc.startOfMonth(ctx.currentDate);
  var income = BigInt.zero;
  var expense = BigInt.zero;
  for (final t in ctx.transactions) {
    if (t.deletedAt != null) {
      continue;
    }
    if (t.occurredAt.isBefore(start)) {
      continue;
    }
    if (t.occurredAt.isAfter(ctx.currentDate)) {
      continue;
    }
    if (t.type == TransactionType.income) {
      income += t.amount.minor;
    } else if (t.type == TransactionType.expense) {
      expense += t.amount.minor;
    }
  }
  if (expense <= income) {
    return null;
  }
  final deficit = expense - income;
  return _build(
    ctx: ctx,
    ruleKey: InsightRuleKeys.deficitMonth,
    title: 'Spending more than earning',
    body:
        "This month your expenses are higher than your income. Time to review categories.",
    severity: InsightSeverity.warning,
    payload: <String, dynamic>{'deficit_minor': deficit.toString()},
  );
}

/// Subscription detector: same description seen >= 2 months in a row.
Insight? subscriptionDetectedRule(RuleContext ctx) {
  if (ctx.isSuppressed(InsightRuleKeys.subscriptionDetected)) {
    return null;
  }
  final byDescription = <String, List<Transaction>>{};
  for (final t in ctx.transactions) {
    if (t.type != TransactionType.expense || t.deletedAt != null) {
      continue;
    }
    final d = t.description?.trim().toLowerCase();
    if (d == null || d.isEmpty) {
      continue;
    }
    byDescription.putIfAbsent(d, () => <Transaction>[]).add(t);
  }
  for (final entry in byDescription.entries) {
    if (entry.value.length < 2) {
      continue;
    }
    final months = entry.value
        .map((t) => '${t.occurredAt.year}-${t.occurredAt.month}')
        .toSet();
    if (months.length < 2) {
      continue;
    }
    return _build(
      ctx: ctx,
      ruleKey: InsightRuleKeys.subscriptionDetected,
      title: 'Possible subscription detected',
      body:
          '"${entry.value.first.description}" appears in ${months.length} different months.',
      severity: InsightSeverity.tip,
      payload: <String, dynamic>{'months': months.length},
    );
  }
  return null;
}

/// No transactions in N days.
Insight? inactivityRule(RuleContext ctx) {
  if (ctx.isSuppressed(InsightRuleKeys.inactivityWarning)) {
    return null;
  }
  if (ctx.transactions.isEmpty) {
    return null;
  }
  final last = ctx.transactions
      .where((t) => t.deletedAt == null)
      .map((t) => t.occurredAt)
      .fold<DateTime?>(null,
          (acc, d) => acc == null || d.isAfter(acc) ? d : acc);
  if (last == null) {
    return null;
  }
  final days = ctx.currentDate.difference(last).inDays;
  if (days < 5) {
    return null;
  }
  return _build(
    ctx: ctx,
    ruleKey: InsightRuleKeys.inactivityWarning,
    title: "It's been $days days since your last entry",
    body: 'Track a transaction to keep your data fresh.',
    severity: InsightSeverity.tip,
    payload: <String, dynamic>{'days_idle': days},
  );
}

/// Largest single expense this month.
Insight? largestExpenseRule(RuleContext ctx) {
  if (ctx.isSuppressed(InsightRuleKeys.largestExpense)) {
    return null;
  }
  final start = _Calc.startOfMonth(ctx.currentDate);
  Transaction? largest;
  for (final t in _Calc.expensesBetween(
    ctx.transactions,
    start,
    ctx.currentDate,
  )) {
    if (largest == null || t.amount.minor > largest.amount.minor) {
      largest = t;
    }
  }
  if (largest == null) {
    return null;
  }
  return _build(
    ctx: ctx,
    ruleKey: InsightRuleKeys.largestExpense,
    title: 'Largest expense this month',
    body:
        '${ctx.categoryName(largest.categoryId)} stood out as your biggest single charge.',
    severity: InsightSeverity.info,
    payload: <String, dynamic>{
      'transaction_id': largest.id.value,
      'minor': largest.amount.minor.toString(),
    },
  );
}

/// Daily average comparison this week vs last week.
Insight? dailyAverageChangeRule(RuleContext ctx) {
  if (ctx.isSuppressed(InsightRuleKeys.dailyAverageChange)) {
    return null;
  }
  final now = ctx.currentDate;
  final thisWeekStart = _Calc.startOfWeek(now);
  final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
  final daysThis = now.difference(thisWeekStart).inDays.clamp(1, 7);
  final thisAvg = _Calc.sumMinor(
        _Calc.expensesBetween(ctx.transactions, thisWeekStart, now),
      ).toDouble() /
      daysThis;
  final lastAvg = _Calc.sumMinor(
        _Calc.expensesBetween(ctx.transactions, lastWeekStart, thisWeekStart),
      ).toDouble() /
      7;
  if (lastAvg == 0) {
    return null;
  }
  final delta = (thisAvg - lastAvg) / lastAvg;
  if (delta.abs() < 0.2) {
    return null;
  }
  final pct = (delta.abs() * 100).round();
  final up = delta > 0;
  return _build(
    ctx: ctx,
    ruleKey: InsightRuleKeys.dailyAverageChange,
    title: up
        ? 'Daily spend up $pct% vs last week'
        : 'Daily spend down $pct% vs last week',
    body: 'Your average daily spending shifted noticeably this week.',
    severity: up ? InsightSeverity.warning : InsightSeverity.celebration,
    payload: <String, dynamic>{'pct': pct, 'direction': up ? 'up' : 'down'},
  );
}

/// Share of weekend spend in the current week.
Insight? weekendShareRule(RuleContext ctx) {
  if (ctx.isSuppressed(InsightRuleKeys.weekendShare)) {
    return null;
  }
  final start = _Calc.startOfWeek(ctx.currentDate);
  var weekendTotal = BigInt.zero;
  var weekTotal = BigInt.zero;
  for (final t in _Calc.expensesBetween(
    ctx.transactions,
    start,
    ctx.currentDate,
  )) {
    weekTotal += t.amount.minor;
    if (t.occurredAt.weekday == DateTime.saturday ||
        t.occurredAt.weekday == DateTime.sunday) {
      weekendTotal += t.amount.minor;
    }
  }
  if (weekTotal == BigInt.zero) {
    return null;
  }
  final share = weekendTotal.toDouble() / weekTotal.toDouble();
  if (share < 0.6) {
    return null;
  }
  final pct = (share * 100).round();
  return _build(
    ctx: ctx,
    ruleKey: InsightRuleKeys.weekendShare,
    title: '$pct% of your week was weekend spend',
    body:
        'Weekends are driving most of your spending. Look out for impulse buys.',
    severity: InsightSeverity.tip,
    payload: <String, dynamic>{'pct': pct},
  );
}

/// Share of the dominant category this month.
Insight? categoryShareRule(RuleContext ctx) {
  if (ctx.isSuppressed(InsightRuleKeys.categoryShare)) {
    return null;
  }
  final start = _Calc.startOfMonth(ctx.currentDate);
  final perCategory = <Ulid, BigInt>{};
  var total = BigInt.zero;
  for (final t in _Calc.expensesBetween(
    ctx.transactions,
    start,
    ctx.currentDate,
  )) {
    total += t.amount.minor;
    final c = t.categoryId;
    if (c == null) {
      continue;
    }
    perCategory[c] = (perCategory[c] ?? BigInt.zero) + t.amount.minor;
  }
  if (total == BigInt.zero) {
    return null;
  }
  final sorted = perCategory.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  if (sorted.isEmpty) {
    return null;
  }
  final top = sorted.first;
  final share = top.value.toDouble() / total.toDouble();
  if (share < 0.4) {
    return null;
  }
  final pct = (share * 100).round();
  return _build(
    ctx: ctx,
    ruleKey: InsightRuleKeys.categoryShare,
    title: '${ctx.categoryName(top.key)} is $pct% of your spend',
    body: 'One category dominates your spend this month.',
    severity: InsightSeverity.info,
    payload: <String, dynamic>{
      'category_id': top.key.value,
      'pct': pct,
    },
  );
}

/// New category seen for the first time this week.
Insight? newCategoryUsageRule(RuleContext ctx) {
  if (ctx.isSuppressed(InsightRuleKeys.newCategoryUsage)) {
    return null;
  }
  final start = _Calc.startOfWeek(ctx.currentDate);
  final priorCategories = <Ulid>{};
  final thisWeekCategories = <Ulid>{};
  for (final t in ctx.transactions) {
    if (t.type != TransactionType.expense || t.deletedAt != null) {
      continue;
    }
    final c = t.categoryId;
    if (c == null) {
      continue;
    }
    if (t.occurredAt.isBefore(start)) {
      priorCategories.add(c);
    } else if (!t.occurredAt.isAfter(ctx.currentDate)) {
      thisWeekCategories.add(c);
    }
  }
  final fresh = thisWeekCategories.difference(priorCategories);
  if (fresh.isEmpty) {
    return null;
  }
  final first = fresh.first;
  return _build(
    ctx: ctx,
    ruleKey: InsightRuleKeys.newCategoryUsage,
    title: 'New spending category: ${ctx.categoryName(first)}',
    body: 'You started using a new category this week.',
    severity: InsightSeverity.info,
    payload: <String, dynamic>{'category_id': first.value},
  );
}

/// Consecutive days under budget.
Insight? underBudgetStreakRule(RuleContext ctx) {
  if (ctx.isSuppressed(InsightRuleKeys.underBudgetStreak)) {
    return null;
  }
  if (ctx.budgets.isEmpty) {
    return null;
  }
  final budget = ctx.budgets.firstWhere(
    (b) => b.isActive,
    orElse: () => ctx.budgets.first,
  );
  if (!budget.isActive || budget.amount.minor == BigInt.zero) {
    return null;
  }
  // Daily target: monthly / 30, weekly / 7, etc. (rough heuristic).
  final daily = budget.amount.minor.toDouble() /
      (budget.period == BudgetPeriod.weekly
          ? 7
          : budget.period == BudgetPeriod.monthly
              ? 30
              : 1);
  var streak = 0;
  for (var i = 0; i < 14; i++) {
    final day = _Calc.startOfDay(
      ctx.currentDate.subtract(Duration(days: i)),
    );
    final nextDay = day.add(const Duration(days: 1));
    final spent = _Calc.sumMinor(
      _Calc.expensesBetween(ctx.transactions, day, nextDay),
    ).toDouble();
    if (spent <= daily) {
      streak += 1;
    } else {
      break;
    }
  }
  if (streak < 3) {
    return null;
  }
  return _build(
    ctx: ctx,
    ruleKey: InsightRuleKeys.underBudgetStreak,
    title: '$streak-day streak under budget',
    body: "Keep it up! You've stayed within your daily target.",
    severity: InsightSeverity.celebration,
    payload: <String, dynamic>{'days': streak, 'budget_id': budget.id.value},
  );
}

/// First income recorded this month.
Insight? firstIncomeRule(RuleContext ctx) {
  if (ctx.isSuppressed(InsightRuleKeys.firstIncome)) {
    return null;
  }
  final start = _Calc.startOfMonth(ctx.currentDate);
  Transaction? first;
  for (final t in ctx.transactions) {
    if (t.type != TransactionType.income || t.deletedAt != null) {
      continue;
    }
    if (t.occurredAt.isBefore(start)) {
      continue;
    }
    if (t.occurredAt.isAfter(ctx.currentDate)) {
      continue;
    }
    if (first == null || t.occurredAt.isBefore(first.occurredAt)) {
      first = t;
    }
  }
  if (first == null) {
    return null;
  }
  return _build(
    ctx: ctx,
    ruleKey: InsightRuleKeys.firstIncome,
    title: 'First income this month logged',
    body: 'Nice — your income for the month has started rolling in.',
    severity: InsightSeverity.info,
    payload: <String, dynamic>{'transaction_id': first.id.value},
  );
}

/// 4-week cash-flow trend (positive direction).
Insight? cashflowTrendRule(RuleContext ctx) {
  if (ctx.isSuppressed(InsightRuleKeys.cashflowTrend)) {
    return null;
  }
  final perWeek = <int>[];
  for (var i = 3; i >= 0; i--) {
    final weekStart = _Calc.startOfWeek(
      ctx.currentDate.subtract(Duration(days: 7 * i)),
    );
    final weekEnd = weekStart.add(const Duration(days: 7));
    var income = BigInt.zero;
    var expense = BigInt.zero;
    for (final t in ctx.transactions) {
      if (t.deletedAt != null) {
        continue;
      }
      if (t.occurredAt.isBefore(weekStart) ||
          !t.occurredAt.isBefore(weekEnd)) {
        continue;
      }
      if (t.type == TransactionType.income) {
        income += t.amount.minor;
      } else if (t.type == TransactionType.expense) {
        expense += t.amount.minor;
      }
    }
    perWeek.add((income - expense).toInt());
  }
  // Strictly increasing across 4 buckets and last bucket positive.
  if (perWeek.length < 4 || perWeek.last <= 0) {
    return null;
  }
  var increasing = true;
  for (var i = 1; i < perWeek.length; i++) {
    if (perWeek[i] <= perWeek[i - 1]) {
      increasing = false;
      break;
    }
  }
  if (!increasing) {
    return null;
  }
  return _build(
    ctx: ctx,
    ruleKey: InsightRuleKeys.cashflowTrend,
    title: 'Cash flow improving 4 weeks in a row',
    body: "You're trending in the right direction — keep going.",
    severity: InsightSeverity.celebration,
    payload: <String, dynamic>{'weeks': perWeek},
  );
}

/// Budget pace forecast: extrapolates current spend to month-end.
Insight? budgetForecastRule(RuleContext ctx) {
  if (ctx.isSuppressed(InsightRuleKeys.budgetForecast)) {
    return null;
  }
  for (final b in ctx.budgets) {
    if (!b.isActive ||
        b.amount.minor == BigInt.zero ||
        b.period != BudgetPeriod.monthly) {
      continue;
    }
    final start = _Calc.startOfMonth(ctx.currentDate);
    final daysElapsed =
        ctx.currentDate.difference(start).inDays.clamp(1, 31);
    final spent = _Calc.sumMinor(
      _Calc.expensesBetween(ctx.transactions, start, ctx.currentDate)
          .where((t) =>
              b.categoryIds.isEmpty || b.categoryIds.contains(t.categoryId)),
    );
    final lastDayOfMonth =
        DateTime(ctx.currentDate.year, ctx.currentDate.month + 1, 0).day;
    // Integer-only projection: spent * lastDayOfMonth / daysElapsed.
    final projectedBig =
        spent * BigInt.from(lastDayOfMonth) ~/ BigInt.from(daysElapsed);
    if (projectedBig <= b.amount.minor) {
      continue;
    }
    final over = projectedBig - b.amount.minor;
    return _build(
      ctx: ctx,
      ruleKey: InsightRuleKeys.budgetForecast,
      title: 'On pace to exceed "${b.name}"',
      body: 'At your current rate, you may go over budget this month.',
      severity: InsightSeverity.warning,
      payload: <String, dynamic>{
        'budget_id': b.id.value,
        'over_minor': over.toString(),
      },
    );
  }
  return null;
}

/// Canonical list of all twenty insight rules.
const List<InsightRule> kAllInsightRules = <InsightRule>[
  weekOverWeekSpikeRule,
  budgetWarningRule,
  budgetExceededRule,
  topCategoryWeekRule,
  longestStreakRule,
  currentStreakRule,
  saveOpportunityRule,
  surplusMonthRule,
  deficitMonthRule,
  subscriptionDetectedRule,
  inactivityRule,
  largestExpenseRule,
  dailyAverageChangeRule,
  weekendShareRule,
  categoryShareRule,
  newCategoryUsageRule,
  underBudgetStreakRule,
  firstIncomeRule,
  cashflowTrendRule,
  budgetForecastRule,
];
