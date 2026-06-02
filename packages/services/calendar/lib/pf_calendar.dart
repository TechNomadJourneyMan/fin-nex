/// Pocket Flow calendar abstraction.
///
/// A platform-agnostic [CalendarService] with device (EventKit / Calendar
/// Provider), Google Calendar API, and in-memory stub backends, plus a
/// Riverpod [calendarServiceProvider].
library pf_calendar;

export 'src/calendar_service.dart';
export 'src/device_calendar_service.dart';
export 'src/factory.dart';
export 'src/google_calendar_service.dart';
export 'src/models.dart';
export 'src/provider.dart';
export 'src/reminder_service.dart';
export 'src/stub_calendar_service.dart';
