import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_domain/domain.dart';

import 'controllers/notifications_controller.dart';
import 'models/notification_preferences.dart';
import 'scheduler/payment_reminder.dart';
import 'services/notifications_service.dart';
import 'services/payment_reminder_sync.dart';

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

/// Whether local payment-push reminders are enabled.
///
/// Defaults to ON on native, OFF on web (where the toggle is hidden and the
/// service is a no-op anyway). The app composition layer overrides this from
/// the settings toggle.
final paymentPushEnabledProvider = Provider<bool>((ref) => !kIsWeb);

/// Localised reminder copy. Overridden in app composition with the active
/// AppL10n strings; defaults to the English fallback.
final paymentReminderCopyProvider =
    Provider<PaymentReminderCopy>((ref) => PaymentReminderCopy.fallback());

/// Composes the [PaymentReminderSync] from the active service + toggle.
final paymentReminderSyncProvider = Provider<PaymentReminderSync>((ref) {
  return PaymentReminderSync(
    service: ref.watch(notificationsServiceProvider),
    enabled: ref.watch(paymentPushEnabledProvider),
  );
});
