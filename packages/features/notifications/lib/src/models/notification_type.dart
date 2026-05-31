/// Granular notification toggle types exposed in the preferences page.
///
/// These are the user-facing categories. They are a superset of
/// [NotificationKind] from the domain so that preferences can be grouped
/// at a higher level than the wire codes.
enum NotificationPreferenceType {
  /// Daily nudge to log expenses.
  dailyReminder,

  /// Weekly recap email/push.
  weeklyRecap,

  /// Monthly financial report.
  monthlyReport,

  /// Approaching or exceeding a budget limit.
  limitWarning,

  /// New insight available.
  insight,

  /// Sync failure or conflict.
  syncError;

  /// Stable string key suitable for persistence.
  String get key {
    switch (this) {
      case NotificationPreferenceType.dailyReminder:
        return 'daily_reminder';
      case NotificationPreferenceType.weeklyRecap:
        return 'weekly_recap';
      case NotificationPreferenceType.monthlyReport:
        return 'monthly_report';
      case NotificationPreferenceType.limitWarning:
        return 'limit_warning';
      case NotificationPreferenceType.insight:
        return 'insight';
      case NotificationPreferenceType.syncError:
        return 'sync_error';
    }
  }

  /// Reverse lookup from [key].
  static NotificationPreferenceType parse(String key) {
    for (final t in NotificationPreferenceType.values) {
      if (t.key == key) {
        return t;
      }
    }
    throw ArgumentError.value(key, 'key', 'Unknown notification type');
  }
}
