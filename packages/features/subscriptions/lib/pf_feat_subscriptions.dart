// Public API for the PocketFlow subscriptions manager feature module (F-04).
//
// Exposes pages, widgets, providers and the local contract the UI is written
// against (overridden by `pf_domain` in app composition).

library pf_feat_subscriptions;

export 'src/data/in_memory_detected_subscriptions_repository.dart';
export 'src/domain/detected_subscription.dart';
export 'src/domain/detected_subscriptions_repository.dart';
export 'src/pages/subscription_detail_page.dart';
export 'src/pages/subscriptions_manager_page.dart';
export 'src/providers.dart';
export 'src/reminders.dart';
export 'src/subscriptions_format.dart';
export 'src/widgets/brand_icon.dart';
export 'src/widgets/subscription_card.dart';
export 'src/widgets/upcoming_calendar_strip.dart';
