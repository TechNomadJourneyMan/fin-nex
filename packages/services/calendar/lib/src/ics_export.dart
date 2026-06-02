// Pure iCalendar (.ics) serialization for Pocket Flow events.
//
// Produces an RFC 5545 VCALENDAR document from a list of [PfCalendarEvent]s so
// upcoming payment reminders can be exported and imported by any calendar app
// (Apple Calendar, Google Calendar, Outlook, …). No platform dependencies —
// fully unit-testable.

import 'models.dart';

/// Serializes Pocket Flow calendar events into an RFC 5545 iCalendar document.
class IcsExporter {
  /// Creates an exporter.
  ///
  /// [productId] is written as the PRODID and [calendarName] as the
  /// X-WR-CALNAME so importing apps show a friendly name.
  const IcsExporter({
    this.productId = '-//Pocket Flow//Payments//EN',
    this.calendarName = 'Pocket Flow — Upcoming payments',
  });

  /// PRODID written into the calendar header.
  final String productId;

  /// Display name for the exported calendar.
  final String calendarName;

  /// Builds the full .ics document for [events].
  ///
  /// [now] stamps each event's DTSTAMP; defaults to [DateTime.now] in UTC.
  /// All-day events are written with VALUE=DATE; timed events use UTC `Z`
  /// times so the result is unambiguous across importers.
  String build(List<PfCalendarEvent> events, {DateTime? now}) {
    final stamp = _formatUtc((now ?? DateTime.now()).toUtc());
    final b = StringBuffer()
      ..writeln('BEGIN:VCALENDAR')
      ..writeln('VERSION:2.0')
      ..writeln('PRODID:$productId')
      ..writeln('CALSCALE:GREGORIAN')
      ..writeln('METHOD:PUBLISH')
      ..writeln('X-WR-CALNAME:${_escape(calendarName)}');

    var seq = 0;
    for (final e in events) {
      b
        ..writeln('BEGIN:VEVENT')
        ..writeln('UID:${_uidFor(e, seq)}')
        ..writeln('DTSTAMP:$stamp');
      if (e.allDay) {
        b
          ..writeln('DTSTART;VALUE=DATE:${_formatDate(e.start)}')
          ..writeln('DTEND;VALUE=DATE:${_formatDate(e.end)}');
      } else {
        b
          ..writeln('DTSTART:${_formatUtc(e.start.toUtc())}')
          ..writeln('DTEND:${_formatUtc(e.end.toUtc())}');
      }
      b.writeln('SUMMARY:${_escape(e.title)}');
      final desc = e.description;
      if (desc != null && desc.isNotEmpty) {
        b.writeln('DESCRIPTION:${_escape(desc)}');
      }
      // Lead-time reminders → VALARM blocks.
      for (final r in e.reminders) {
        b
          ..writeln('BEGIN:VALARM')
          ..writeln('ACTION:DISPLAY')
          ..writeln('DESCRIPTION:${_escape(e.title)}')
          ..writeln('TRIGGER:${_formatTrigger(r)}')
          ..writeln('END:VALARM');
      }
      b.writeln('END:VEVENT');
      seq++;
    }

    b.write('END:VCALENDAR');
    // RFC 5545 requires CRLF line endings.
    return b.toString().replaceAll('\n', '\r\n');
  }

  String _uidFor(PfCalendarEvent e, int seq) {
    final base = e.sourceId ?? 'event-$seq';
    return '$base@pocketflow.kz';
  }

  static String _two(int v) => v.toString().padLeft(2, '0');

  static String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}${_two(d.month)}${_two(d.day)}';

  static String _formatUtc(DateTime d) =>
      '${_formatDate(d)}T${_two(d.hour)}${_two(d.minute)}${_two(d.second)}Z';

  /// Negative duration trigger relative to event start (e.g. `-P1D`,
  /// `-PT9H`). A zero lead time is written as `PT0S`.
  static String _formatTrigger(Duration d) {
    if (d == Duration.zero) return 'PT0S';
    final days = d.inDays;
    final hours = d.inHours % 24;
    final minutes = d.inMinutes % 60;
    final sb = StringBuffer('-P');
    if (days > 0) sb.write('${days}D');
    if (hours > 0 || minutes > 0) {
      sb.write('T');
      if (hours > 0) sb.write('${hours}H');
      if (minutes > 0) sb.write('${minutes}M');
    }
    return sb.toString();
  }

  /// Escapes RFC 5545 special characters in TEXT values.
  static String _escape(String s) => s
      .replaceAll(r'\', r'\\')
      .replaceAll(';', r'\;')
      .replaceAll(',', r'\,')
      .replaceAll('\n', r'\n');
}
