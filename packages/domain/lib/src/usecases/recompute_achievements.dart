import '../entities/streak.dart';
import '../values/money.dart';

/// Stable machine keys for the F-08 seed achievement catalog.
///
/// These must match the `key` column of the seeded `achievements` rows.
class AchievementKeys {
  const AchievementKeys._();

  /// Logged the very first transaction.
  static const String firstTransaction = 'first_transaction';

  /// Maintained a 7-day logging streak.
  static const String streak7 = 'streak_7';

  /// Maintained a 30-day logging streak.
  static const String streak30 = 'streak_30';

  /// Created the first budget.
  static const String firstBudget = 'first_budget';

  /// Stayed under every active budget for a full month.
  static const String underBudgetMonth = 'under_budget_month';

  /// Detected three or more subscriptions.
  static const String subscriptionsDetected = 'subscriptions_detected_3';

  /// Saved at least 10% of income within a month.
  static const String saved10Percent = 'saved_10_percent';

  /// Created the first shared workspace (F-06).
  static const String firstWorkspace = 'first_workspace';

  /// Every key in catalog order.
  static const List<String> all = <String>[
    firstTransaction,
    streak7,
    streak30,
    firstBudget,
    underBudgetMonth,
    subscriptionsDetected,
    saved10Percent,
    firstWorkspace,
  ];
}

/// Immutable snapshot of recent user state used to evaluate achievement rules.
///
/// The caller assembles this from the local repositories (transactions,
/// budgets, subscriptions, streak, workspaces). All money values for the
/// income/expense pair must share a currency.
class AchievementSnapshot {
  /// Default constructor.
  const AchievementSnapshot({
    required this.transactionCount,
    required this.budgetCount,
    required this.streak,
    required this.subscriptionCount,
    required this.monthIncome,
    required this.monthExpense,
    this.budgetsTrackedThisMonth = false,
    this.allBudgetsUnderThisMonth = false,
    this.workspaceCount = 0,
    this.supportsWorkspaces = false,
  });

  /// Total non-deleted transactions logged by the user.
  final int transactionCount;

  /// Total active budgets configured by the user.
  final int budgetCount;

  /// The user's current streak record.
  final Streak streak;

  /// Number of distinct detected subscriptions.
  final int subscriptionCount;

  /// Income booked in the current calendar month.
  final Money monthIncome;

  /// Expense booked in the current calendar month.
  final Money monthExpense;

  /// Whether at least one budget was active for the full elapsed month.
  ///
  /// Guards the "stayed under budget" rule so it can't fire with no budgets.
  final bool budgetsTrackedThisMonth;

  /// Whether every active budget stayed under its cap for the month.
  final bool allBudgetsUnderThisMonth;

  /// Number of shared workspaces the user owns (F-06).
  final int workspaceCount;

  /// Whether the build supports the F-06 workspace fields at all. When false
  /// the workspace rule is skipped entirely.
  final bool supportsWorkspaces;

  /// Saved fraction of income this month in `[−∞, 1]`; `0` when no income.
  double get monthSavingsRate {
    if (monthIncome.isZero || monthIncome.isNegative) {
      return 0;
    }
    final saved = monthIncome.minor - monthExpense.minor;
    return saved / monthIncome.minor;
  }
}

/// Pure rule engine for the gamification achievements (F-08).
///
/// Given a [AchievementSnapshot] and the set of already-unlocked achievement
/// keys, returns the keys that should be newly unlocked. The engine is
/// deterministic and side-effect free so the data layer can persist the
/// results and the domain tests can assert each rule in isolation.
class RecomputeAchievements {
  /// Default constructor.
  const RecomputeAchievements();

  /// Evaluates every rule and returns the keys to unlock that are not already
  /// present in [alreadyUnlocked].
  List<String> call(
    AchievementSnapshot snapshot, {
    Set<String> alreadyUnlocked = const <String>{},
  }) {
    final unlocked = <String>[];

    void grant(String key, {required bool when}) {
      if (when && !alreadyUnlocked.contains(key)) {
        unlocked.add(key);
      }
    }

    // Onboarding.
    grant(
      AchievementKeys.firstTransaction,
      when: snapshot.transactionCount >= 1,
    );
    grant(
      AchievementKeys.firstBudget,
      when: snapshot.budgetCount >= 1,
    );

    // Consistency (streaks).
    grant(
      AchievementKeys.streak7,
      when: snapshot.streak.longestStreakDays >= 7 ||
          snapshot.streak.currentStreakDays >= 7,
    );
    grant(
      AchievementKeys.streak30,
      when: snapshot.streak.longestStreakDays >= 30 ||
          snapshot.streak.currentStreakDays >= 30,
    );

    // Budgeting discipline.
    grant(
      AchievementKeys.underBudgetMonth,
      when:
          snapshot.budgetsTrackedThisMonth && snapshot.allBudgetsUnderThisMonth,
    );

    // Subscriptions insight.
    grant(
      AchievementKeys.subscriptionsDetected,
      when: snapshot.subscriptionCount >= 3,
    );

    // Saving rate.
    grant(
      AchievementKeys.saved10Percent,
      when: snapshot.monthSavingsRate >= 0.10,
    );

    // Collaboration (F-06) — guarded behind feature support.
    grant(
      AchievementKeys.firstWorkspace,
      when: snapshot.supportsWorkspaces && snapshot.workspaceCount >= 1,
    );

    return unlocked;
  }
}
