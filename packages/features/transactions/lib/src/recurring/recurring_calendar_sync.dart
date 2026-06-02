// Bridges recurring rules to calendar reminder events.
//
// Each rule optionally creates a single "next occurrence" reminder event that
// is refreshed on every materialisation / edit. Built on the shared
// [PfReminderService] so creation + removal are idempotent and keyed by the
// rule's source id. Mirrors the subscriptions reminder bridge.

import 'package:pf_calendar/pf_calendar.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';
import 'package:pf_domain/pf_domain.dart';

import 'recurring_source.dart';

/// Builds the all-day "next occurrence" reminder spec for [rule].
///
/// Title is "<description or type> — <amount>"; reminders fire 1 day before and
/// on the day itself. Lands on the rule's [RecurringRule.nextRunAt] local day.
PfReminderSpec buildRecurringReminder(
  RecurringRule rule, {
  String locale = 'en',
}) {
  final String amountText = formatPfAmount(
    rule.amount.minor.toInt(),
    locale: locale,
    fractionDigits: 0,
    currencySymbol: rule.amount.currency.symbol,
  );
  final String label =
      (rule.description != null && rule.description!.trim().isNotEmpty)
          ? rule.description!.trim()
          : rule.type.code;
  final DateTime dueLocal = rule.nextRunAt.toLocal();
  return PfReminderSpec(
    sourceId: recurringSourceId(rule.id),
    title: '$label — $amountText',
    date: DateTime(dueLocal.year, dueLocal.month, dueLocal.day),
    reminders: const <Duration>[
      Duration(days: 1),
      Duration.zero,
    ],
  );
}

/// Reconciles a single recurring rule's reminder with the calendar.
///
/// When [enabled] and a [calendarId] is available and the rule wants calendar
/// sync (its `calendarEventId` is non-null, used here as the opt-in flag),
/// ensures exactly one event exists for the rule and persists its id back.
/// Otherwise removes any existing event. Idempotent.
class RecurringCalendarSync {
  /// Creates a sync helper.
  RecurringCalendarSync({
    required PfReminderService reminderService,
    required RecurringRulesRepository repository,
    required this.calendarId,
    required this.enabled,
    this.locale = 'en',
  })  : _reminders = reminderService,
        _repo = repository;

  final PfReminderService _reminders;
  final RecurringRulesRepository _repo;

  /// Target calendar id, or null when no calendar is connected.
  final String? calendarId;

  /// Whether recurring reminders are turned on globally.
  final bool enabled;

  /// Locale tag used to format the amount.
  final String locale;

  /// Reconciles [rule]'s reminder. [wantsSync] is the rule editor toggle.
  Future<void> sync(RecurringRule rule, {required bool wantsSync}) async {
    final String? calId = calendarId;
    if (calId == null || !enabled || !wantsSync || rule.paused) {
      await _ensureRemoved(calId, rule);
      return;
    }
    final PfReminderSpec spec = buildRecurringReminder(rule, locale: locale);
    final String? id = await _reminders.sync(calId, spec);
    if (id != null && id != rule.calendarEventId) {
      await _repo.upsert(
        rule.copyWith(calendarEventId: id, updatedAt: DateTime.now().toUtc()),
      );
    }
  }

  /// Removes [rule]'s reminder and clears its stored id.
  Future<void> remove(RecurringRule rule) => _ensureRemoved(calendarId, rule);

  Future<void> _ensureRemoved(String? calId, RecurringRule rule) async {
    if (calId != null) {
      await _reminders.remove(calId, recurringSourceId(rule.id));
    }
    if (rule.calendarEventId != null) {
      await _repo.upsert(
        rule.copyWith(
          clearCalendarEventId: true,
          updatedAt: DateTime.now().toUtc(),
        ),
      );
    }
  }
}
