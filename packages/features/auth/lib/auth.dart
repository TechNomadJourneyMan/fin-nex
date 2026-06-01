/// PocketFlow auth feature — sign-in, sign-up, OTP, biometric, sessions, delete.
///
/// Mount [authRoutes] in the app router and override
/// [authRepositoryProvider] with the real impl from `pf_data_api`.
library auth;

export 'src/auth_routes.dart';
export 'src/auth_state.dart';
export 'src/controllers/auth_controller.dart';
export 'src/pages/biometric_unlock_page.dart';
export 'src/pages/delete_account_page.dart';
export 'src/pages/phone_otp_page.dart';
export 'src/pages/session_devices_page.dart';
export 'src/pages/sign_in_page.dart';
export 'src/pages/sign_up_page.dart';
export 'src/providers.dart';
export 'src/stub_auth_repository.dart';
export 'src/token_storage.dart';
