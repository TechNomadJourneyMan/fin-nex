import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'calendar_service.dart';
import 'stub_calendar_service.dart';

/// The active [CalendarService].
///
/// Defaults to [StubCalendarService] so tests and headless analyze never hit
/// native APIs or the network. The app overrides this at the root with
/// `createCalendarService()` (web → Google, mobile → device).
final calendarServiceProvider = Provider<CalendarService>((ref) {
  return StubCalendarService();
});
