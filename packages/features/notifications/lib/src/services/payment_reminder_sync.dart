// Reconciles the pure [PaymentReminderScheduler] output against the platform
// [NotificationsService].
//
// The in-app counterpart to the calendar reminder sync: calendar events are
// the shared/system surface, these local notifications are the in-app nudge.
// Both derive from the same upcoming-payments list. This class is thin and
// side-effecting; the scheduling *math* lives in [PaymentReminderScheduler] and
// is unit-tested without any platform calls.

import '../models/notification_type.dart';
import '../scheduler/payment_reminder.dart';
import 'notifications_service.dart';

/// Drives local payment-reminder notifications from a list of upcoming
/// payments.
class PaymentReminderSync {
  /// Creates a sync helper.
  const PaymentReminderSync({
    required NotificationsService service,
    this.scheduler = const PaymentReminderScheduler(),
    this.enabled = true,
  }) : _service = service;

  final NotificationsService _service;

  /// Pure scheduling policy.
  final PaymentReminderScheduler scheduler;

  /// Master switch (the "Payment push reminders" setting). When false this
  /// cancels everything and schedules nothing.
  final bool enabled;

  /// Rebuilds the local notification set for [inputs].
  ///
  /// Cancels every previously scheduled payment reminder (by deterministic id)
  /// then schedules the fresh set, so the result is idempotent and reflects
  /// added / removed / re-dated payments. When [enabled] is false it only
  /// cancels.
  Future<void> sync(
    List<PaymentReminderInput> inputs, {
    required DateTime now,
    PaymentReminderCopy? copy,
  }) async {
    await _service.init();

    // Cancel both reminder slots for every input first so stale notifications
    // for removed/cancelled payments don't linger.
    for (final input in inputs) {
      await _service.cancel(
        PaymentReminderScheduler.notificationId(input.sourceId, offset: 0),
      );
      await _service.cancel(
        PaymentReminderScheduler.notificationId(input.sourceId, offset: 1),
      );
    }

    if (!enabled) return;

    final planned = scheduler.schedule(inputs, now: now, copy: copy);
    for (final n in planned) {
      await _service.schedule(
        NotificationDisplay(
          id: n.id,
          type: NotificationPreferenceType.dailyReminder,
          title: n.title,
          body: n.body,
          payload: n.sourceId,
        ),
        n.when,
      );
    }
  }

  /// Cancels every payment reminder for [sourceIds] (e.g. on delete).
  Future<void> cancelFor(Iterable<String> sourceIds) async {
    for (final id in sourceIds) {
      await _service
          .cancel(PaymentReminderScheduler.notificationId(id, offset: 0));
      await _service
          .cancel(PaymentReminderScheduler.notificationId(id, offset: 1));
    }
  }
}
