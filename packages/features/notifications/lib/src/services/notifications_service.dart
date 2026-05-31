import 'package:flutter/foundation.dart';

import '../models/notification_type.dart';

/// Display payload sent through the [NotificationsService].
@immutable
class NotificationDisplay {
  /// Default constructor.
  const NotificationDisplay({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.payload,
  });

  /// Local-channel id (unique per notification).
  final int id;

  /// Logical preference type.
  final NotificationPreferenceType type;

  /// Headline.
  final String title;

  /// Body text.
  final String body;

  /// Optional deep-link payload (route or json string).
  final String? payload;
}

/// Cross-platform wrapper around `flutter_local_notifications`.
///
/// On Web (or any platform where local notifications are unavailable) this
/// becomes a no-op that prints to the debug console. On supported native
/// platforms a real implementation can be wired via [NotificationsService.native].
abstract interface class NotificationsService {
  /// Default web/no-op implementation; safe to instantiate everywhere.
  factory NotificationsService.noop() = _NoopNotificationsService;

  /// Native implementation backed by `flutter_local_notifications`.
  ///
  /// Use this on iOS/Android only — calling it on Web throws an
  /// [UnsupportedError]. The concrete plugin class is lazily required so the
  /// Web build never needs to resolve native bindings.
  factory NotificationsService.native() {
    if (kIsWeb) {
      throw UnsupportedError(
        'NotificationsService.native() cannot be used on Web. '
        'Use NotificationsService.noop() instead.',
      );
    }
    return _NativeNotificationsService();
  }

  /// Initialises the underlying channel/categories. Must be awaited before
  /// the first [show] call.
  Future<void> init();

  /// Requests OS permission. Returns `true` when granted.
  Future<bool> requestPermission();

  /// Displays a notification immediately.
  Future<void> show(NotificationDisplay display);

  /// Schedules [display] for delivery at [when] (UTC).
  Future<void> schedule(NotificationDisplay display, DateTime when);

  /// Cancels a previously scheduled notification.
  Future<void> cancel(int id);

  /// Cancels every scheduled notification.
  Future<void> cancelAll();
}

class _NoopNotificationsService implements NotificationsService {
  _NoopNotificationsService();

  @override
  Future<void> init() async {
    debugPrint('[NotificationsService.noop] init()');
  }

  @override
  Future<bool> requestPermission() async {
    debugPrint('[NotificationsService.noop] requestPermission()');
    return true;
  }

  @override
  Future<void> show(NotificationDisplay display) async {
    debugPrint(
      '[NotificationsService.noop] show id=${display.id} '
      'type=${display.type.key} title=${display.title}',
    );
  }

  @override
  Future<void> schedule(NotificationDisplay display, DateTime when) async {
    debugPrint(
      '[NotificationsService.noop] schedule id=${display.id} when=$when '
      'type=${display.type.key}',
    );
  }

  @override
  Future<void> cancel(int id) async {
    debugPrint('[NotificationsService.noop] cancel id=$id');
  }

  @override
  Future<void> cancelAll() async {
    debugPrint('[NotificationsService.noop] cancelAll()');
  }
}

class _NativeNotificationsService implements NotificationsService {
  _NativeNotificationsService();

  // TODO(F-NOTIF): wire flutter_local_notifications plugin.
  // We avoid importing the package symbols at file scope so a Web build that
  // accidentally evaluates this class still has a chance to fail loudly at
  // `init` rather than during tree-shake.
  bool _initialized = false;

  @override
  Future<void> init() async {
    _initialized = true;
    debugPrint('[NotificationsService.native] init() stub');
  }

  @override
  Future<bool> requestPermission() async {
    _ensureInit();
    return true;
  }

  @override
  Future<void> show(NotificationDisplay display) async {
    _ensureInit();
    debugPrint(
      '[NotificationsService.native] show id=${display.id} '
      'title=${display.title}',
    );
  }

  @override
  Future<void> schedule(NotificationDisplay display, DateTime when) async {
    _ensureInit();
    debugPrint(
      '[NotificationsService.native] schedule id=${display.id} when=$when',
    );
  }

  @override
  Future<void> cancel(int id) async {
    _ensureInit();
    debugPrint('[NotificationsService.native] cancel id=$id');
  }

  @override
  Future<void> cancelAll() async {
    _ensureInit();
    debugPrint('[NotificationsService.native] cancelAll()');
  }

  void _ensureInit() {
    if (!_initialized) {
      throw StateError('NotificationsService.init() must be called first.');
    }
  }
}
