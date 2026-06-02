import 'package:flutter/material.dart' show DateTimeRange;

import 'models.dart';

/// Platform-agnostic contract for reading and writing calendar events.
///
/// Backends:
///  * [DeviceCalendarService] — EventKit (iOS) / Calendar Provider (Android).
///    Surfaces both Apple and Google accounts synced on-device.
///  * [GoogleCalendarService] — Google Calendar API over OAuth (web + mobile).
///  * [StubCalendarService] — in-memory, used by tests and headless analyze.
///
/// All methods are best-effort: implementations should swallow recoverable
/// platform errors and surface them as empty results / `null` ids rather than
/// throwing, so callers in later phases can degrade gracefully.
abstract class CalendarService {
  /// Requests the OS / OAuth permission needed to read & write calendars.
  ///
  /// Returns `true` when access was granted.
  Future<bool> requestPermission();

  /// Lists the calendars available to the current user.
  Future<List<PfCalendar>> calendars();

  /// Creates [e] in [calendarId]. Returns the new event id, or `null` on
  /// failure.
  Future<String?> createEvent(String calendarId, PfCalendarEvent e);

  /// Deletes [eventId] from [calendarId].
  Future<void> deleteEvent(String calendarId, String eventId);

  /// Returns the events in [calId] overlapping [r].
  Future<List<PfCalendarEvent>> eventsInRange(String calId, DateTimeRange r);
}
