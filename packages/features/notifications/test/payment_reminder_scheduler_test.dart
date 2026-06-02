import 'package:flutter_test/flutter_test.dart';
import 'package:pf_feat_notifications/pf_feat_notifications.dart';

void main() {
  PaymentReminderInput input(String id, DateTime due, {String title = 'X'}) =>
      PaymentReminderInput(
        sourceId: id,
        title: title,
        amountLabel: '100',
        dueDate: due,
      );

  group('PaymentReminderScheduler', () {
    test('emits a day-before and due-day reminder for one payment', () {
      const scheduler = PaymentReminderScheduler();
      final now = DateTime(2026, 6, 1, 8);
      final out = scheduler.schedule(
        [input('subscription:a', DateTime(2026, 6, 10))],
        now: now,
      );

      expect(out, hasLength(2));
      // Sorted by fire time: day-before (Jun 9, 9am) then due-day (Jun 10, 9am).
      expect(out[0].when, DateTime(2026, 6, 9, 9));
      expect(out[1].when, DateTime(2026, 6, 10, 9));
      expect(out[0].sourceId, 'subscription:a');
    });

    test('drops candidates whose fire time is already in the past', () {
      const scheduler = PaymentReminderScheduler();
      // Now is on the due day at 10am — the 9am due-day reminder is in the past,
      // and the day-before reminder (yesterday) too. Both dropped.
      final now = DateTime(2026, 6, 10, 10);
      final out = scheduler.schedule(
        [input('subscription:a', DateTime(2026, 6, 10))],
        now: now,
      );
      expect(out, isEmpty);
    });

    test('day-before reminder can be disabled', () {
      const scheduler = PaymentReminderScheduler(dayBefore: false);
      final out = scheduler.schedule(
        [input('subscription:a', DateTime(2026, 6, 10))],
        now: DateTime(2026, 6, 1),
      );
      expect(out, hasLength(1));
      expect(out.single.when, DateTime(2026, 6, 10, 9));
    });

    test('enforces the per-day cap, keeping the earliest', () {
      // Three payments all due the same day → 3 due-day reminders at 9am plus
      // 3 day-before reminders. maxPerDay=2 keeps 2 per calendar day.
      const scheduler = PaymentReminderScheduler(maxPerDay: 2);
      final due = DateTime(2026, 6, 10);
      final out = scheduler.schedule(
        [
          input('subscription:a', due),
          input('subscription:b', due),
          input('subscription:c', due),
        ],
        now: DateTime(2026, 6, 1),
      );

      // Group by local day.
      final byDay = <String, int>{};
      for (final n in out) {
        final k = '${n.when.year}-${n.when.month}-${n.when.day}';
        byDay[k] = (byDay[k] ?? 0) + 1;
      }
      for (final count in byDay.values) {
        expect(count, lessThanOrEqualTo(2));
      }
    });

    test('shifts reminders out of quiet hours', () {
      // Reminder hour inside the quiet window (22:00–08:00) → shifted to 08:00.
      const scheduler = PaymentReminderScheduler(
        reminderHour: 23,
        quietHours: QuietHours(),
        dayBefore: false,
      );
      final out = scheduler.schedule(
        [input('subscription:a', DateTime(2026, 6, 10))],
        now: DateTime(2026, 6, 1),
      );
      expect(out, hasLength(1));
      // 23:00 wraps past midnight → exits at 08:00 the next day.
      expect(out.single.when, DateTime(2026, 6, 11, 8));
    });

    test('notification ids are stable and distinct per source/offset', () {
      final a0 =
          PaymentReminderScheduler.notificationId('subscription:a', offset: 0);
      final a1 =
          PaymentReminderScheduler.notificationId('subscription:a', offset: 1);
      final b0 =
          PaymentReminderScheduler.notificationId('subscription:b', offset: 0);
      expect(a0, isNot(a1));
      expect(a0, isNot(b0));
      // Stable across calls.
      expect(
        a0,
        PaymentReminderScheduler.notificationId('subscription:a', offset: 0),
      );
      expect(a0, greaterThanOrEqualTo(0));
    });

    test('fills the localised copy templates', () {
      const scheduler = PaymentReminderScheduler(dayBefore: false);
      final out = scheduler.schedule(
        [input('subscription:a', DateTime(2026, 6, 10), title: 'Netflix')],
        now: DateTime(2026, 6, 1),
        copy: const PaymentReminderCopy(
          dayBeforeTitle: 'd',
          dayBeforeBody: '{title} {amount}',
          dueTodayTitle: 'Due',
          dueTodayBody: '{title} owes {amount}',
        ),
      );
      expect(out.single.title, 'Due');
      expect(out.single.body, 'Netflix owes 100');
    });
  });

  group('QuietHours', () {
    test('non-wrapping window', () {
      const q = QuietHours(startHour: 1, endHour: 6);
      expect(q.contains(DateTime(2026, 1, 1, 3)), isTrue);
      expect(q.contains(DateTime(2026, 1, 1, 7)), isFalse);
      expect(q.shift(DateTime(2026, 1, 1, 3)), DateTime(2026, 1, 1, 6));
    });

    test('disabled window never shifts', () {
      const q = QuietHours.disabled();
      final t = DateTime(2026, 1, 1, 2);
      expect(q.contains(t), isFalse);
      expect(q.shift(t), t);
    });
  });
}
