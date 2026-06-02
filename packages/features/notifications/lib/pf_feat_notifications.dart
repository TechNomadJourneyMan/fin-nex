/// Public API for the PocketFlow notifications feature module.
///
/// Exposes the notifications center page, preferences page, the cross-platform
/// notifications service wrapper, and Riverpod providers used to wire the
/// feature into the app shell.
library pf_feat_notifications;

export 'src/controllers/notifications_controller.dart';
export 'src/models/notification_preferences.dart';
export 'src/models/notification_type.dart';
export 'src/pages/notification_preferences_page.dart';
export 'src/pages/notifications_center_page.dart';
export 'src/providers.dart';
export 'src/scheduler/payment_reminder.dart';
export 'src/services/notifications_service.dart';
export 'src/services/payment_reminder_sync.dart';
