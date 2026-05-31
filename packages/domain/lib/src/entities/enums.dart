/// Logical kinds of an account.
enum AccountType {
  cash,
  debitCard,
  creditCard,
  bankAccount,
  savings,
  wallet,
  crypto,
  investment,
  other;

  /// Wire/code value used in the database (`snake_case`).
  String get code {
    switch (this) {
      case AccountType.cash:
        return 'cash';
      case AccountType.debitCard:
        return 'debit_card';
      case AccountType.creditCard:
        return 'credit_card';
      case AccountType.bankAccount:
        return 'bank_account';
      case AccountType.savings:
        return 'savings';
      case AccountType.wallet:
        return 'wallet';
      case AccountType.crypto:
        return 'crypto';
      case AccountType.investment:
        return 'investment';
      case AccountType.other:
        return 'other';
    }
  }

  /// Parses a database code into the corresponding [AccountType].
  static AccountType parse(String code) {
    for (final t in AccountType.values) {
      if (t.code == code) {
        return t;
      }
    }
    throw ArgumentError.value(code, 'code', 'Unknown account type');
  }
}

/// Tenancy kind of a [Workspace] — Personal vs Business (PRD F-06).
enum WorkspaceType {
  personal,
  business;

  /// Wire code.
  String get code => name;

  /// Parses a database code.
  static WorkspaceType parse(String code) {
    for (final t in WorkspaceType.values) {
      if (t.code == code) {
        return t;
      }
    }
    throw ArgumentError.value(code, 'code', 'Unknown workspace type');
  }
}

/// Direction/kind of a transaction.
enum TransactionType {
  expense,
  income,
  transfer,
  adjustment;

  /// Wire code.
  String get code => name;

  /// Parses a database code.
  static TransactionType parse(String code) {
    for (final t in TransactionType.values) {
      if (t.code == code) {
        return t;
      }
    }
    throw ArgumentError.value(code, 'code', 'Unknown transaction type');
  }
}

/// Classification used by both categories and transactions.
enum CategoryType {
  expense,
  income,
  transfer,
  adjustment;

  /// Wire code.
  String get code => name;

  /// Parses a database code.
  static CategoryType parse(String code) {
    for (final t in CategoryType.values) {
      if (t.code == code) {
        return t;
      }
    }
    throw ArgumentError.value(code, 'code', 'Unknown category type');
  }
}

/// Period over which a budget or limit recurs.
enum BudgetPeriod {
  weekly,
  monthly,
  quarterly,
  yearly,
  custom;

  /// Wire code.
  String get code => name;

  /// Parses a database code.
  static BudgetPeriod parse(String code) {
    for (final p in BudgetPeriod.values) {
      if (p.code == code) {
        return p;
      }
    }
    throw ArgumentError.value(code, 'code', 'Unknown budget period');
  }
}

/// Severity of a limit alert reaction.
enum LimitSeverity {
  soft,
  warning,
  hard;

  /// Wire code.
  String get code => name;

  /// Parses a database code.
  static LimitSeverity parse(String code) {
    for (final p in LimitSeverity.values) {
      if (p.code == code) {
        return p;
      }
    }
    throw ArgumentError.value(code, 'code', 'Unknown severity');
  }
}

/// Subscription tier for the current user.
enum SubscriptionTier {
  free,
  plus,
  family,
  edu;

  /// Wire code.
  String get code => name;

  /// Parses a database code.
  static SubscriptionTier parse(String code) {
    for (final p in SubscriptionTier.values) {
      if (p.code == code) {
        return p;
      }
    }
    throw ArgumentError.value(code, 'code', 'Unknown subscription tier');
  }
}

/// Severity of an in-app insight card.
enum InsightSeverity {
  info,
  tip,
  warning,
  celebration;

  /// Wire code.
  String get code => name;

  /// Parses a database code.
  static InsightSeverity parse(String code) {
    for (final p in InsightSeverity.values) {
      if (p.code == code) {
        return p;
      }
    }
    throw ArgumentError.value(code, 'code', 'Unknown insight severity');
  }
}

/// Notification kinds emitted by the system.
enum NotificationKind {
  limitWarning,
  limitExceeded,
  budgetAlert,
  recurringDue,
  dailyReminder,
  weeklySummary,
  insight,
  streak,
  referral,
  system,
  marketing;

  /// Wire code (`snake_case`).
  String get code {
    switch (this) {
      case NotificationKind.limitWarning:
        return 'limit_warning';
      case NotificationKind.limitExceeded:
        return 'limit_exceeded';
      case NotificationKind.budgetAlert:
        return 'budget_alert';
      case NotificationKind.recurringDue:
        return 'recurring_due';
      case NotificationKind.dailyReminder:
        return 'daily_reminder';
      case NotificationKind.weeklySummary:
        return 'weekly_summary';
      case NotificationKind.insight:
        return 'insight';
      case NotificationKind.streak:
        return 'streak';
      case NotificationKind.referral:
        return 'referral';
      case NotificationKind.system:
        return 'system';
      case NotificationKind.marketing:
        return 'marketing';
    }
  }

  /// Parses a database code.
  static NotificationKind parse(String code) {
    for (final k in NotificationKind.values) {
      if (k.code == code) {
        return k;
      }
    }
    throw ArgumentError.value(code, 'code', 'Unknown notification kind');
  }
}

/// Bucket label for an [Achievement] (F-08 Gamification).
enum AchievementCategory {
  /// Logging discipline (streaks).
  consistency,

  /// Budgeting milestones.
  budgeting,

  /// Saving / investing milestones.
  savings,

  /// Onboarding and first-time actions.
  exploration,

  /// Misc / special events.
  special;

  /// Wire code.
  String get code => name;

  /// Parses a database code, defaulting to [special] for unknown codes.
  static AchievementCategory parse(String code) {
    for (final c in AchievementCategory.values) {
      if (c.code == code) return c;
    }
    return AchievementCategory.special;
  }
}
