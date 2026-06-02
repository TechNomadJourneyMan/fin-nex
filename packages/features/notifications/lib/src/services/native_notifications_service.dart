// Native (iOS / Android) implementation of [NotificationsService] backed by
// `flutter_local_notifications` + `timezone`.
//
// This file is only imported through the conditional factory in
// `notifications_service.dart`, and every entry point is guarded so a Web build
// never resolves the native bindings. Scheduling uses TZ-aware times so DST and
// device-timezone changes are handled by the plugin.

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'notifications_service.dart';

/// Android channel id for payment / subscription reminders.
const String kPaymentsChannelId = 'payments';

/// Human-readable channel name (Android settings UI).
const String kPaymentsChannelName = 'Payment reminders';

/// Concrete native service. Constructed only off-web via
/// [NotificationsService.native].
class NativeNotificationsService implements NotificationsService {
  /// Creates the service. [plugin] is injectable for tests; production passes
  /// the default singleton.
  NativeNotificationsService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  @override
  Future<void> init() async {
    if (_initialized) return;
    // Load the timezone database and pin the local zone so zonedSchedule lands
    // on the right wall-clock time across DST.
    tzdata.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      // We request permission explicitly via [requestPermission]; don't prompt
      // at init time.
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
      macOS: darwinInit,
    );
    await _plugin.initialize(settings);

    // Pre-create the Android channel so reminders have a stable home.
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        kPaymentsChannelId,
        kPaymentsChannelName,
        description: 'Upcoming subscription and recurring payment reminders.',
        importance: Importance.defaultImportance,
      ),
    );

    _initialized = true;
  }

  @override
  Future<bool> requestPermission() async {
    await init();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    return false;
  }

  @override
  Future<void> show(NotificationDisplay display) async {
    await init();
    await _plugin.show(
      display.id,
      display.title,
      display.body,
      _details(),
      payload: display.payload,
    );
  }

  @override
  Future<void> schedule(NotificationDisplay display, DateTime when) async {
    await init();
    final tzWhen = tz.TZDateTime.from(when, tz.local);
    await _plugin.zonedSchedule(
      display.id,
      display.title,
      display.body,
      tzWhen,
      _details(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: display.payload,
    );
  }

  @override
  Future<void> cancel(int id) async {
    await init();
    await _plugin.cancel(id);
  }

  @override
  Future<void> cancelAll() async {
    await init();
    await _plugin.cancelAll();
  }

  NotificationDetails _details() {
    const android = AndroidNotificationDetails(
      kPaymentsChannelId,
      kPaymentsChannelName,
      channelDescription:
          'Upcoming subscription and recurring payment reminders.',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const darwin = DarwinNotificationDetails();
    return const NotificationDetails(
      android: android,
      iOS: darwin,
      macOS: darwin,
    );
  }
}

/// Factory used by [NotificationsService.native]; isolated here so the symbol
/// is only referenced from the native code path.
NotificationsService createNativeNotificationsService() {
  if (kIsWeb) {
    throw UnsupportedError('Native notifications are unavailable on Web.');
  }
  return NativeNotificationsService();
}
