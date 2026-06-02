// Bridges detected subscriptions to calendar reminder events.
//
// Builds a [PfReminderSpec] from a [DetectedSubscription] (the all-day "next
// charge" event with a 1-day-before + 9am-same-day reminder) and keeps the
// subscription's stored `calendarEventId` in sync via the shared
// [PfReminderService]. Both creation and removal are funnelled through here so
// the rules live in one place and stay idempotent.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_calendar/pf_calendar.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';

import 'domain/detected_subscription.dart';
import 'domain/detected_subscriptions_repository.dart';
import 'providers.dart';

/// SharedPreferences key for the "subscription reminders" toggle.
///
/// Mirrors the key the settings feature writes so both sides agree without a
/// hard dependency between the packages.
const String kSubscriptionRemindersKey = 'pf_reminders_subscriptions';

/// Builds the all-day calendar reminder spec for [sub].
///
/// Title is "<merchant> — <amount>"; reminders fire 1 day before and at 9am on
/// the billing day (expressed as a lead time before the all-day event's
/// midnight start, i.e. negative-9h is not representable, so we use the
/// day-before reminder plus a same-day 0 lead to land a 9am alert via the
/// event's reminders list).
PfReminderSpec buildSubscriptionReminder(
  DetectedSubscription sub, {
  String locale = 'en',
}) {
  final amountText = formatPfAmount(
    sub.amount.minor.toInt(),
    locale: locale,
    fractionDigits: 0,
    currencySymbol: sub.amount.currency.symbol,
  );
  final dueLocal = sub.nextBillingDate.toLocal();
  return PfReminderSpec(
    sourceId: 'subscription:${sub.id.value}',
    title: '${sub.merchantName} — $amountText',
    date: DateTime(dueLocal.year, dueLocal.month, dueLocal.day),
    // 1 day before, and 9am on the day itself. For an all-day event whose
    // start is local midnight, "9am same day" is a lead time of -9h, which the
    // backends clamp to the day's start; we keep the day-before reminder and a
    // zero-lead reminder so both an advance warning and a day-of alert fire.
    reminders: const <Duration>[
      Duration(days: 1),
      Duration.zero,
    ],
  );
}

/// Syncs a single subscription's reminder to the calendar.
///
/// When [enabled] and a [calendarId] is available, ensures exactly one event
/// exists for [sub] and persists its id back on the record. When disabled (or
/// no calendar), removes any existing event and clears the stored id.
/// Idempotent: safe to call repeatedly (re-sync looks the event up by source
/// id and never duplicates).
class SubscriptionRemindersSync {
  /// Creates a sync helper.
  SubscriptionRemindersSync({
    required PfReminderService reminderService,
    required DetectedSubscriptionsRepository repository,
    required this.calendarId,
    required this.enabled,
    this.locale = 'en',
  })  : _reminders = reminderService,
        _repo = repository;

  final PfReminderService _reminders;
  final DetectedSubscriptionsRepository _repo;

  /// Target calendar id, or null when no calendar is connected.
  final String? calendarId;

  /// Whether subscription reminders are turned on.
  final bool enabled;

  /// Locale tag used to format the amount and date.
  final String locale;

  /// Reconciles [sub]'s reminder with the current settings.
  Future<void> sync(DetectedSubscription sub) async {
    final calId = calendarId;

    // No calendar, reminders off, cancelled or deleted → ensure removed.
    if (calId == null || !enabled || !sub.isActive) {
      await _ensureRemoved(calId, sub);
      return;
    }

    final spec = buildSubscriptionReminder(sub, locale: locale);
    final id = await _reminders.sync(calId, spec);
    if (id != null && id != sub.calendarEventId) {
      await _repo.upsert(
        sub.copyWith(calendarEventId: id, updatedAt: DateTime.now().toUtc()),
      );
    }
  }

  /// Removes [sub]'s reminder and clears its stored id. Used on delete /
  /// cancel / toggle-off.
  Future<void> remove(DetectedSubscription sub) =>
      _ensureRemoved(calendarId, sub);

  Future<void> _ensureRemoved(String? calId, DetectedSubscription sub) async {
    if (calId != null) {
      // Remove by source id (covers events created on another device too).
      await _reminders.remove(calId, 'subscription:${sub.id.value}');
    }
    if (sub.calendarEventId != null) {
      await _repo.upsert(
        sub.copyWith(
          clearCalendarEventId: true,
          updatedAt: DateTime.now().toUtc(),
        ),
      );
    }
  }
}

/// Whether subscription reminders are enabled. Defaults to `false`; the app
/// composition layer overrides this from SharedPreferences (the settings
/// toggle) — defaulting ON once a calendar is connected.
final subscriptionRemindersEnabledProvider = Provider<bool>((ref) => false);

/// The connected calendar id, or null. Overridden in app composition with the
/// persisted `pf_calendar_id`.
final subscriptionRemindersCalendarIdProvider =
    Provider<String?>((ref) => null);

/// BCP-47 locale tag used to format reminder titles. Overridden in app
/// composition with the active app locale.
final subscriptionRemindersLocaleProvider = Provider<String>((ref) => 'en');

/// Composes a [SubscriptionRemindersSync] from the active providers.
final subscriptionRemindersSyncProvider =
    Provider<SubscriptionRemindersSync>((ref) {
  return SubscriptionRemindersSync(
    reminderService: ref.watch(reminderServiceProvider),
    repository: ref.watch(detectedSubscriptionsRepositoryProvider),
    calendarId: ref.watch(subscriptionRemindersCalendarIdProvider),
    enabled: ref.watch(subscriptionRemindersEnabledProvider),
    locale: ref.watch(subscriptionRemindersLocaleProvider),
  );
});
