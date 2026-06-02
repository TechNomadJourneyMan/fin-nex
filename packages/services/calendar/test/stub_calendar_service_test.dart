import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_test/flutter_test.dart';
import 'package:pf_calendar/pf_calendar.dart';

void main() {
  group('StubCalendarService', () {
    test('round-trip: create -> list -> delete', () async {
      final svc = StubCalendarService();
      expect(await svc.requestPermission(), isTrue);

      final cals = await svc.calendars();
      expect(cals, isNotEmpty);
      final calId = cals.first.id;

      final now = DateTime(2026, 6, 2, 9);
      final event = PfCalendarEvent(
        title: 'Netflix renews',
        start: now,
        end: now.add(const Duration(hours: 1)),
        reminders: const <Duration>[Duration(days: 1)],
        sourceId: 'sub-42',
      );

      final id = await svc.createEvent(calId, event);
      expect(id, isNotNull);

      final range = DateTimeRange(
        start: now.subtract(const Duration(days: 1)),
        end: now.add(const Duration(days: 1)),
      );
      var found = await svc.eventsInRange(calId, range);
      expect(found, hasLength(1));
      expect(found.single.id, id);
      expect(found.single.title, 'Netflix renews');
      expect(found.single.sourceId, 'sub-42');

      await svc.deleteEvent(calId, id!);
      found = await svc.eventsInRange(calId, range);
      expect(found, isEmpty);
    });

    test('createEvent returns null before permission granted', () async {
      final svc = StubCalendarService();
      final id = await svc.createEvent(
        'stub-primary',
        PfCalendarEvent(
          title: 'x',
          start: DateTime(2026),
          end: DateTime(2026, 1, 1, 1),
        ),
      );
      expect(id, isNull);
    });

    test('eventsInRange excludes events outside the window', () async {
      final svc = StubCalendarService();
      await svc.requestPermission();
      final cals = await svc.calendars();
      final calId = cals.first.id;
      final base = DateTime(2026, 6, 2, 9);
      await svc.createEvent(
        calId,
        PfCalendarEvent(
          title: 'far',
          start: base.add(const Duration(days: 30)),
          end: base.add(const Duration(days: 30, hours: 1)),
        ),
      );
      final found = await svc.eventsInRange(
        calId,
        DateTimeRange(start: base, end: base.add(const Duration(days: 1))),
      );
      expect(found, isEmpty);
    });
  });
}
