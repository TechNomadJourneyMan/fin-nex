import 'package:flutter/material.dart' show DateTimeRange;
import 'package:meta/meta.dart';

import 'calendar_service.dart';
import 'models.dart';

/// A platform-agnostic description of a reminder Pocket Flow wants on the
/// calendar, derived from a domain object (a subscription, a budget, …).
///
/// Pure data: feature packages build one of these from their own entities and
/// hand it to [PfReminderService], so the event-building rules live in exactly
/// one place and both features stay decoupled from `pf_calendar` internals.
@immutable
class PfReminderSpec {
  /// Creates a reminder spec.
  const PfReminderSpec({
    required this.sourceId,
    required this.title,
    required this.date,
    this.description,
    this.reminders = const <Duration>[],
  });

  /// Stable id of the originating Pocket Flow entity (e.g. a subscription id).
  ///
  /// Used as the [PfCalendarEvent.sourceId] so re-syncing is idempotent and
  /// the event can be looked up / removed later.
  final String sourceId;

  /// Event title (e.g. "Netflix — $9.99").
  final String title;

  /// Calendar day the event lands on (time component is ignored; the event is
  /// created as an all-day event spanning this date).
  final DateTime date;

  /// Optional longer notes.
  final String? description;

  /// Lead-time reminders before the event (e.g. `[Duration(days: 1)]`).
  final List<Duration> reminders;

  /// Builds the all-day [PfCalendarEvent] this spec describes.
  ///
  /// The event spans the local calendar day of [date]; `start` is midnight and
  /// `end` is midnight the following day, matching the all-day convention used
  /// by both the device and Google backends.
  PfCalendarEvent toEvent() {
    final day = DateTime(date.year, date.month, date.day);
    return PfCalendarEvent(
      title: title,
      description: description,
      start: day,
      end: day.add(const Duration(days: 1)),
      allDay: true,
      reminders: reminders,
      sourceId: sourceId,
    );
  }
}

/// Centralises creating, updating and removing Pocket Flow reminder events on
/// the user's calendar.
///
/// Every method keys off [PfReminderSpec.sourceId] (stored on the created
/// [PfCalendarEvent.sourceId]) so re-syncing the same domain object never
/// duplicates: an existing event for that source is reused/replaced, and
/// removal is by source id.
class PfReminderService {
  /// Creates a reminder service over [service].
  PfReminderService(this._service);

  final CalendarService _service;

  /// How far ahead [_existingFor] scans for previously-created events when
  /// looking one up by source id. Reminder events are near-future (a billing
  /// date, a period end) so a generous window is enough.
  static const Duration _scanWindow = Duration(days: 400);

  /// Ensures exactly one calendar event exists in [calendarId] for [spec].
  ///
  /// Idempotent: if an event with the same [PfReminderSpec.sourceId] already
  /// exists it is deleted and recreated (so title / date / reminder changes
  /// propagate) rather than duplicated. Returns the resulting event id, or
  /// `null` if the backend refused to create it (e.g. no permission).
  Future<String?> sync(String calendarId, PfReminderSpec spec) async {
    await _removeExisting(calendarId, spec.sourceId);
    return _service.createEvent(calendarId, spec.toEvent());
  }

  /// Removes any event in [calendarId] previously created for [sourceId].
  ///
  /// No-op when none is found, so callers can call this unconditionally on
  /// delete / toggle-off.
  Future<void> remove(String calendarId, String sourceId) =>
      _removeExisting(calendarId, sourceId);

  /// Removes a specific event id when known (the fast path used when the
  /// caller has persisted the calendar event id on its own record).
  Future<void> removeById(String calendarId, String eventId) =>
      _service.deleteEvent(calendarId, eventId);

  Future<void> _removeExisting(String calendarId, String sourceId) async {
    final existing = await _existingFor(calendarId, sourceId);
    for (final e in existing) {
      final id = e.id;
      if (id != null) {
        await _service.deleteEvent(calendarId, id);
      }
    }
  }

  Future<List<PfCalendarEvent>> _existingFor(
    String calendarId,
    String sourceId,
  ) async {
    final now = DateTime.now();
    final range = DateTimeRange(
      start: now.subtract(_scanWindow),
      end: now.add(_scanWindow),
    );
    final events = await _service.eventsInRange(calendarId, range);
    return events.where((e) => e.sourceId == sourceId).toList(growable: false);
  }
}
