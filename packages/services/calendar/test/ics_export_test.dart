import 'package:flutter_test/flutter_test.dart';
import 'package:pf_calendar/pf_calendar.dart';

void main() {
  group('IcsExporter', () {
    test('wraps events in a VCALENDAR with CRLF line endings', () {
      const exporter = IcsExporter();
      final ics = exporter.build(
        const <PfCalendarEvent>[],
        now: DateTime.utc(2026, 6, 1, 12),
      );
      expect(ics, startsWith('BEGIN:VCALENDAR'));
      expect(ics, endsWith('END:VCALENDAR'));
      expect(ics, contains('\r\n'));
      expect(ics, contains('PRODID:-//Pocket Flow//Payments//EN'));
    });

    test('serializes an all-day event with VALUE=DATE and an alarm', () {
      const exporter = IcsExporter();
      final event = PfCalendarEvent(
        title: 'Netflix — 4 990',
        start: DateTime(2026, 6, 10),
        end: DateTime(2026, 6, 11),
        allDay: true,
        reminders: const <Duration>[Duration(days: 1)],
        sourceId: 'subscription:abc',
      );
      final ics = exporter.build([event], now: DateTime.utc(2026, 6, 1));

      expect(ics, contains('BEGIN:VEVENT'));
      expect(ics, contains('UID:subscription:abc@pocketflow.kz'));
      expect(ics, contains('DTSTART;VALUE=DATE:20260610'));
      expect(ics, contains('DTEND;VALUE=DATE:20260611'));
      expect(ics, contains('SUMMARY:Netflix — 4 990'));
      expect(ics, contains('BEGIN:VALARM'));
      expect(ics, contains('TRIGGER:-P1D'));
    });

    test('escapes RFC 5545 special characters', () {
      const exporter = IcsExporter();
      final event = PfCalendarEvent(
        title: 'A; B, C',
        description: 'line1\nline2',
        start: DateTime(2026, 6, 10),
        end: DateTime(2026, 6, 11),
        allDay: true,
        sourceId: 's',
      );
      final ics = exporter.build([event]);
      expect(ics, contains(r'SUMMARY:A\; B\, C'));
      expect(ics, contains(r'DESCRIPTION:line1\nline2'));
    });

    test('zero-lead reminder uses PT0S trigger', () {
      const exporter = IcsExporter();
      final event = PfCalendarEvent(
        title: 'X',
        start: DateTime(2026, 6, 10),
        end: DateTime(2026, 6, 11),
        allDay: true,
        reminders: const <Duration>[Duration.zero],
        sourceId: 's',
      );
      final ics = exporter.build([event]);
      expect(ics, contains('TRIGGER:PT0S'));
    });
  });
}
