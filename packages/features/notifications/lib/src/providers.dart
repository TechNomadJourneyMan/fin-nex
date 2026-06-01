import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_domain/domain.dart';

import 'controllers/notifications_controller.dart';
import 'models/notification_preferences.dart';
import 'services/notifications_service.dart';

/// Active user id; expected to be overridden by the app shell.
final notificationsUserIdProvider = Provider<Ulid>((ref) {
  throw UnimplementedError(
    'notificationsUserIdProvider must be overridden at the app level.',
  );
});

/// Backing repository for notifications. Defaults to an in-memory stub so the
/// feature is independently runnable.
final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => InMemoryNotificationsRepository(),
);

/// Platform-aware notifications delivery service.
final notificationsServiceProvider = Provider<NotificationsService>((ref) {
  if (kIsWeb) {
    return NotificationsService.noop();
  }
  return NotificationsService.native();
});

/// Notifications-center state.
final notificationsControllerProvider =
    StateNotifierProvider<NotificationsController, NotificationsState>((ref) {
  return NotificationsController(
    repository: ref.watch(notificationsRepositoryProvider),
    userId: ref.watch(notificationsUserIdProvider),
  );
});

/// Per-type preference toggles. App layer should hydrate from settings storage.
final notificationPreferencesProvider =
    StateNotifierProvider<PreferencesController, NotificationPreferences>(
        (ref) {
  return PreferencesController(
    service: ref.watch(notificationsServiceProvider),
  );
});
