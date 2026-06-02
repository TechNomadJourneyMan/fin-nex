import 'package:flutter/material.dart' show DateTimeRange;

import 'calendar_service.dart';
import 'models.dart';

/// In-memory [CalendarService] used by tests and as the safe default in the
/// Riverpod provider so headless analyze / test runs never touch native APIs
/// or the network.
class StubCalendarService implements CalendarService {
  /// Creates a stub, optionally seeded with [calendars].
  StubCalendarService({List<PfCalendar>? calendars})
      : _calendars = calendars ??
            const <PfCalendar>[
              PfCalendar(
                id: 'stub-primary',
                name: 'Pocket Flow (stub)',
                accountName: 'local',
              ),
            ];

  final List<PfCalendar> _calendars;

  /// calendarId -> (eventId -> event)
  final Map<String, Map<String, PfCalendarEvent>> _events =
      <String, Map<String, PfCalendarEvent>>{};

  bool _granted = false;
  int _seq = 0;

  @override
  Future<bool> requestPermission() async {
    _granted = true;
    return true;
  }

  @override
  Future<List<PfCalendar>> calendars() async =>
      List<PfCalendar>.unmodifiable(_calendars);

  @override
  Future<String?> createEvent(String calendarId, PfCalendarEvent e) async {
    if (!_granted) return null;
    final id = e.id ?? 'stub-event-${_seq++}';
    final stored = e.copyWith(id: id);
    (_events[calendarId] ??= <String, PfCalendarEvent>{})[id] = stored;
    return id;
  }

  @override
  Future<void> deleteEvent(String calendarId, String eventId) async {
    _events[calendarId]?.remove(eventId);
  }

  @override
  Future<List<PfCalendarEvent>> eventsInRange(
    String calId,
    DateTimeRange r,
  ) async {
    final events = _events[calId];
    if (events == null) return const <PfCalendarEvent>[];
    return events.values
        .where((e) => e.start.isBefore(r.end) && e.end.isAfter(r.start))
        .toList(growable: false);
  }
}
