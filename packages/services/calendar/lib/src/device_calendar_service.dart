import 'dart:developer' as developer;

import 'package:device_calendar/device_calendar.dart' as dc;
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:timezone/timezone.dart' as tz;

import 'calendar_service.dart';
import 'models.dart';

/// [CalendarService] backed by the on-device calendar store via the
/// `device_calendar` plugin (EventKit on iOS, Calendar Provider on Android).
///
/// This is the default on mobile and surfaces *every* account the user has
/// synced on-device — including Google and iCloud — without any separate
/// OAuth flow.
class DeviceCalendarService implements CalendarService {
  /// Creates the service. [plugin] is injectable for tests.
  DeviceCalendarService({dc.DeviceCalendarPlugin? plugin})
      : _plugin = plugin ?? dc.DeviceCalendarPlugin();

  final dc.DeviceCalendarPlugin _plugin;

  @override
  Future<bool> requestPermission() async {
    try {
      var result = await _plugin.hasPermissions();
      if (result.isSuccess && (result.data ?? false)) return true;
      result = await _plugin.requestPermissions();
      return result.isSuccess && (result.data ?? false);
    } catch (e) {
      developer.log('Calendar permission failed: $e', name: 'pf_calendar');
      return false;
    }
  }

  @override
  Future<List<PfCalendar>> calendars() async {
    final result = await _plugin.retrieveCalendars();
    if (!result.isSuccess || result.data == null) {
      return const <PfCalendar>[];
    }
    return <PfCalendar>[
      for (final c in result.data!)
        PfCalendar(
          id: c.id ?? '',
          name: c.name ?? 'Calendar',
          accountName: c.accountName,
          isWritable: !(c.isReadOnly ?? false),
        ),
    ];
  }

  @override
  Future<String?> createEvent(String calendarId, PfCalendarEvent e) async {
    final location = tz.local;
    final event = dc.Event(
      calendarId,
      eventId: e.id,
      title: e.title,
      description: e.description,
      start: tz.TZDateTime.from(e.start, location),
      end: tz.TZDateTime.from(e.end, location),
      allDay: e.allDay,
      reminders: <dc.Reminder>[
        for (final r in e.reminders) dc.Reminder(minutes: r.inMinutes),
      ],
    );
    final result = await _plugin.createOrUpdateEvent(event);
    if (result != null && result.isSuccess) return result.data;
    return null;
  }

  @override
  Future<void> deleteEvent(String calendarId, String eventId) async {
    await _plugin.deleteEvent(calendarId, eventId);
  }

  @override
  Future<List<PfCalendarEvent>> eventsInRange(
    String calId,
    DateTimeRange r,
  ) async {
    final result = await _plugin.retrieveEvents(
      calId,
      dc.RetrieveEventsParams(startDate: r.start, endDate: r.end),
    );
    if (!result.isSuccess || result.data == null) {
      return const <PfCalendarEvent>[];
    }
    return <PfCalendarEvent>[
      for (final ev in result.data!)
        PfCalendarEvent(
          id: ev.eventId,
          title: ev.title ?? '',
          description: ev.description,
          start: ev.start ?? DateTime.now(),
          end: ev.end ?? ev.start ?? DateTime.now(),
          allDay: ev.allDay ?? false,
        ),
    ];
  }
}
