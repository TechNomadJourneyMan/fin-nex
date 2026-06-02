import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_test/flutter_test.dart';
import 'package:pf_calendar/pf_calendar.dart';

void main() {
  group('PfReminderService', () {
    late StubCalendarService stub;
    late PfReminderService reminders;
    const calId = 'stub-primary';

    DateTimeRange wideRange() => DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 365)),
          end: DateTime.now().add(const Duration(days: 365)),
        );

    setUp(() async {
      stub = StubCalendarService();
      await stub.requestPermission();
      reminders = PfReminderService(stub);
    });

    PfReminderSpec spec({String sourceId = 'subscription:abc'}) {
      final due = DateTime.now().add(const Duration(days: 5));
      return PfReminderSpec(
        sourceId: sourceId,
        title: 'Netflix — 1 990 ₸',
        date: due,
        reminders: const <Duration>[Duration(days: 1), Duration.zero],
      );
    }

    test('sync creates exactly one all-day event keyed by sourceId', () async {
      final id = await reminders.sync(calId, spec());
      expect(id, isNotNull);

      final events = await stub.eventsInRange(calId, wideRange());
      expect(events, hasLength(1));
      expect(events.single.allDay, isTrue);
      expect(events.single.sourceId, 'subscription:abc');
      expect(events.single.title, 'Netflix — 1 990 ₸');
      expect(events.single.reminders, const <Duration>[
        Duration(days: 1),
        Duration.zero,
      ]);
    });

    test('re-syncing the same source is idempotent (no duplicate)', () async {
      await reminders.sync(calId, spec());
      await reminders.sync(calId, spec());
      await reminders.sync(calId, spec());

      final events = await stub.eventsInRange(calId, wideRange());
      expect(events, hasLength(1));
    });

    test('remove deletes the event by source id', () async {
      await reminders.sync(calId, spec());
      await reminders.remove(calId, 'subscription:abc');

      final events = await stub.eventsInRange(calId, wideRange());
      expect(events, isEmpty);
    });

    test('different source ids produce separate events', () async {
      await reminders.sync(calId, spec(sourceId: 'subscription:a'));
      await reminders.sync(calId, spec(sourceId: 'budget:b'));

      final events = await stub.eventsInRange(calId, wideRange());
      expect(events, hasLength(2));
    });
  });

  group('PfReminderSpec.toEvent', () {
    test('builds an all-day event spanning the local day of date', () {
      final spec = PfReminderSpec(
        sourceId: 'x',
        title: 't',
        date: DateTime(2026, 6, 30, 13, 45),
      );
      final e = spec.toEvent();
      expect(e.allDay, isTrue);
      expect(e.start, DateTime(2026, 6, 30));
      expect(e.end, DateTime(2026, 7, 1));
      expect(e.sourceId, 'x');
    });
  });
}
