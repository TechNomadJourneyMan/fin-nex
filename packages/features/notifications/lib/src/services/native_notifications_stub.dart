// Web-side stub for the conditional import in `notifications_service.dart`.
//
// On Web there is no native notification plugin, so this throws. It is never
// reached at runtime because the provider returns `NotificationsService.noop()`
// when `kIsWeb`, but it must exist so the conditional import type-checks.

import 'notifications_service.dart';

/// Web stub — local notifications are unavailable in the browser.
NotificationsService createNativeNotificationsService() {
  throw UnsupportedError(
    'Native notifications are unavailable on Web. Use '
    'NotificationsService.noop() instead.',
  );
}
