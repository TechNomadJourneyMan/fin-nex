// Push notifications transport — abstraction.
//
// • iOS / Android: use FirebasePushService (requires firebase_messaging
//   wired into the platform projects).
// • Web: WebNoopPushService — no-op stream, no token. The in-app
//   NotificationCenter still works against the local InMemoryNotifications
//   repository.
//
// Wire the concrete implementation at app boot. The default provider in
// app_data picks the right one for the current target.

import 'dart:async';

import 'package:flutter/foundation.dart';

/// Minimal push-message envelope. Concrete impls map their platform
/// payload into this shape before pushing to the stream.
class PushMessage {
  const PushMessage({
    required this.title,
    required this.body,
    this.payload = const <String, dynamic>{},
  });

  final String title;
  final String body;
  final Map<String, dynamic> payload;
}

/// Push transport contract.
abstract interface class PushService {
  /// Initialises the transport (requests permissions, registers token).
  /// Safe to call multiple times.
  Future<void> initialize();

  /// Stream of foreground messages. Backgrounded messages route via the
  /// system notification panel (handled by the OS, not this stream).
  Stream<PushMessage> get onMessage;

  /// Device push token (FCM / APNS) or null when unavailable.
  Future<String?> get token;
}

/// Web build: nothing to do. Returns an empty stream.
class WebNoopPushService implements PushService {
  WebNoopPushService();

  final StreamController<PushMessage> _ctrl =
      StreamController<PushMessage>.broadcast();

  @override
  Future<void> initialize() async {
    // No-op. (Firebase Web Messaging is possible but needs separate setup
    // and isn't part of the Web preview scope.)
  }

  @override
  Stream<PushMessage> get onMessage => _ctrl.stream;

  @override
  Future<String?> get token async => null;
}

/// Native build stub. The real implementation calls FirebaseMessaging
/// inside a guard so the Web bundle never touches the dep.
class FirebasePushService implements PushService {
  FirebasePushService();

  @override
  Future<void> initialize() async {
    throw UnimplementedError(
      'FirebasePushService requires firebase_core + firebase_messaging '
      'wired into apps/finnex/ios and apps/finnex/android. For Web '
      'preview we use WebNoopPushService.',
    );
  }

  @override
  Stream<PushMessage> get onMessage =>
      const Stream<PushMessage>.empty();

  @override
  Future<String?> get token async => null;
}

/// Convenience: picks the right implementation for the current target.
PushService defaultPushService() {
  if (kIsWeb) return WebNoopPushService();
  return FirebasePushService();
}
