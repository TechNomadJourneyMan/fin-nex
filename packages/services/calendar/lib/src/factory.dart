import 'package:flutter/foundation.dart' show kIsWeb;

import 'calendar_service.dart';
import 'device_calendar_service.dart';
import 'google_calendar_service.dart';

/// Builds the platform-appropriate [CalendarService].
///
///  * Web → [GoogleCalendarService] (Calendar API over OAuth).
///  * Mobile / other → [DeviceCalendarService] (EventKit / Calendar Provider),
///    which already surfaces synced Google & Apple accounts on-device.
///
/// [isWeb] is overridable purely so the factory can be unit-tested without a
/// web build; it defaults to the real [kIsWeb].
CalendarService createCalendarService({bool isWeb = kIsWeb}) {
  return isWeb ? GoogleCalendarService() : DeviceCalendarService();
}
