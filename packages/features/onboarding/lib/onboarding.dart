/// Public API for FinNex onboarding feature module.
///
/// Re-exports pages, controllers, providers, and routes used by the host
/// app to wire the first-run experience.
library onboarding;

export 'src/controllers/onboarding_controller.dart';
export 'src/pages/first_transaction_prompt_page.dart';
export 'src/pages/grant_permissions_page.dart';
export 'src/pages/setup_first_account_page.dart';
export 'src/pages/value_props_page.dart';
export 'src/pages/welcome_page.dart';
export 'src/providers.dart';
export 'src/onboarding_routes.dart';
