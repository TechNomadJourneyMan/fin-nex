// Bridges budgets to calendar reminder events.
//
// When a budget period is ending (within the last 3 days), optionally creates
// an all-day "Budget '<name>' ends <date>" reminder via the shared
// [PfReminderService]. Idempotent: keyed by the budget id, so re-syncing never
// duplicates. Budgets are immutable domain objects with no calendar-id field,
// so we rely on look-up-by-source-id for removal rather than threading an id
// through the entity.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pf_calendar/pf_calendar.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_domain/domain.dart';

/// SharedPreferences key for the "budget reminders" toggle.
const String kBudgetRemindersKey = 'pf_reminders_budgets';

/// Number of days before a budget's [Budget.endsOn] within which the reminder
/// is considered relevant ("period ending").
const int kBudgetEndingWindowDays = 3;

/// Stable calendar source id for [budget]'s end-of-period reminder.
String budgetReminderSourceId(Budget budget) => 'budget:${budget.id.value}';

/// Whether [budget] is in its final [kBudgetEndingWindowDays] relative to
/// [now]. Returns false when the budget has no end date or has already ended.
bool isBudgetEnding(Budget budget, {DateTime? now}) {
  final endsOn = budget.endsOn;
  if (endsOn == null) return false;
  final today = (now ?? DateTime.now()).toLocal();
  final end = endsOn.toLocal();
  final daysLeft = DateTime(end.year, end.month, end.day)
      .difference(DateTime(today.year, today.month, today.day))
      .inDays;
  return daysLeft >= 0 && daysLeft <= kBudgetEndingWindowDays;
}

/// Builds the all-day reminder spec for [budget]'s end of period.
PfReminderSpec buildBudgetReminder(
  Budget budget,
  AppL10n l10n, {
  String locale = 'en',
}) {
  final end = (budget.endsOn ?? budget.startsOn).toLocal();
  final endDate = DateTime(end.year, end.month, end.day);
  return PfReminderSpec(
    sourceId: budgetReminderSourceId(budget),
    title: l10n.budgetReminderTitle(
      budget.name,
      DateFormat.yMMMMd(locale).format(endDate),
    ),
    date: endDate,
    reminders: const <Duration>[Duration(days: 1)],
  );
}

/// Reconciles budget end-of-period reminders with the current settings.
class BudgetRemindersSync {
  /// Creates a sync helper.
  BudgetRemindersSync({
    required PfReminderService reminderService,
    required this.calendarId,
    required this.enabled,
    required this.l10n,
    this.locale = 'en',
  }) : _reminders = reminderService;

  final PfReminderService _reminders;

  /// Target calendar id, or null when no calendar is connected.
  final String? calendarId;

  /// Whether budget reminders are turned on.
  final bool enabled;

  /// Localizations used to build the reminder title.
  final AppL10n l10n;

  /// Locale tag used to format the end date.
  final String locale;

  /// Ensures the reminder for [budget] reflects current settings: present when
  /// enabled, a calendar is connected and the period is ending; removed
  /// otherwise. Idempotent.
  Future<void> sync(Budget budget, {DateTime? now}) async {
    final calId = calendarId;
    if (calId == null) return;

    final shouldExist = enabled &&
        budget.deletedAt == null &&
        budget.isActive &&
        isBudgetEnding(budget, now: now);

    if (!shouldExist) {
      await _reminders.remove(calId, budgetReminderSourceId(budget));
      return;
    }
    await _reminders.sync(calId, buildBudgetReminder(budget, l10n, locale: locale));
  }

  /// Removes [budget]'s reminder (used on delete / toggle-off).
  Future<void> remove(Budget budget) async {
    final calId = calendarId;
    if (calId == null) return;
    await _reminders.remove(calId, budgetReminderSourceId(budget));
  }
}

/// Whether budget reminders are enabled. Defaults to `false` (OFF); overridden
/// in app composition from the settings toggle.
final budgetRemindersEnabledProvider = Provider<bool>((ref) => false);

/// The connected calendar id, or null. Overridden in app composition.
final budgetRemindersCalendarIdProvider = Provider<String?>((ref) => null);

/// Locale tag used for reminder titles. Overridden in app composition.
final budgetRemindersLocaleProvider = Provider<String>((ref) => 'en');
