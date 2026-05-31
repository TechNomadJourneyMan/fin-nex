// Riverpod providers for the auth feature.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fnx_domain/fnx_domain.dart';

import 'auth_state.dart';
import 'controllers/auth_controller.dart';
import 'stub_auth_repository.dart';
import 'token_storage.dart';

/// Provides the [TokenStorage] singleton. Override in tests.
final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

/// Provides the [AuthRepository] implementation.
///
/// Defaults to [StubAuthRepository]. The app should override with the real
/// impl from `fnx_data_api` once wiring is complete. TODO(F-AUTH-WEB).
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return StubAuthRepository();
});

/// Provides the [AuthController].
final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthState>(AuthController.new);

/// Resolves the current [User] from [authControllerProvider], or `null`.
final currentUserProvider = Provider<User?>((ref) {
  final state = ref.watch(authControllerProvider);
  return state.maybeWhen(
    data: (s) => s is Authenticated ? s.user : null,
    orElse: () => null,
  );
});
