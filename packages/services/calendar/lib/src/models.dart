import 'package:meta/meta.dart';

/// A single calendar entry Pocket Flow can create (a payment reminder, a
/// subscription renewal, etc.).
///
/// Pure-Dart value type with no platform dependencies so it can be passed
/// across every [CalendarService] backend and exercised in headless tests.
@immutable
class PfCalendarEvent {
  /// Creates a calendar event.
  const PfCalendarEvent({
    this.id,
    required this.title,
    this.description,
    required this.start,
    required this.end,
    this.allDay = false,
    this.reminders = const <Duration>[],
    this.sourceId,
  });

  /// Backend-assigned event id. `null` before the event is created.
  final String? id;

  /// Event title (e.g. "Netflix renews").
  final String title;

  /// Optional longer description / notes.
  final String? description;

  /// Event start.
  final DateTime start;

  /// Event end.
  final DateTime end;

  /// Whether this is an all-day event.
  final bool allDay;

  /// Reminders expressed as a lead time *before* [start]
  /// (e.g. `Duration(days: 1)` → "remind 1 day before").
  final List<Duration> reminders;

  /// Opaque id linking this event back to the Pocket Flow entity that
  /// created it (a subscription id, a budget id, …). Used for idempotent
  /// sync and de-duplication in later phases.
  final String? sourceId;

  /// Returns a copy with the given fields replaced.
  PfCalendarEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? start,
    DateTime? end,
    bool? allDay,
    List<Duration>? reminders,
    String? sourceId,
  }) {
    return PfCalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      start: start ?? this.start,
      end: end ?? this.end,
      allDay: allDay ?? this.allDay,
      reminders: reminders ?? this.reminders,
      sourceId: sourceId ?? this.sourceId,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PfCalendarEvent &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.start == start &&
        other.end == end &&
        other.allDay == allDay &&
        other.sourceId == sourceId &&
        _listEquals(other.reminders, reminders);
  }

  @override
  int get hashCode => Object.hash(
        id,
        title,
        description,
        start,
        end,
        allDay,
        sourceId,
        Object.hashAll(reminders),
      );

  @override
  String toString() =>
      'PfCalendarEvent(id: $id, title: $title, start: $start, end: $end)';
}

/// A calendar the user can write events to.
@immutable
class PfCalendar {
  /// Creates a calendar descriptor.
  const PfCalendar({
    required this.id,
    required this.name,
    this.accountName,
    this.isWritable = true,
  });

  /// Backend calendar id.
  final String id;

  /// Display name (e.g. "Personal", "Family").
  final String name;

  /// Owning account (e.g. a Google address, "iCloud").
  final String? accountName;

  /// Whether Pocket Flow may create/delete events in this calendar.
  final bool isWritable;

  @override
  bool operator ==(Object other) {
    return other is PfCalendar &&
        other.id == id &&
        other.name == name &&
        other.accountName == accountName &&
        other.isWritable == isWritable;
  }

  @override
  int get hashCode => Object.hash(id, name, accountName, isWritable);

  @override
  String toString() =>
      'PfCalendar(id: $id, name: $name, account: $accountName)';
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
