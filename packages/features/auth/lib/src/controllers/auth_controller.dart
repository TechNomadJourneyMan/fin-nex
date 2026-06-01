// Auth controller — drives sign-in / sign-out lifecycle.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_domain/pf_domain.dart';

import '../auth_state.dart';
import '../providers.dart';
import '../token_storage.dart';

/// OAuth provider variants supported by the controller.
enum OAuthProvider {
  /// Apple Sign-In.
  apple,

  /// Google Sign-In.
  google,
}

/// AsyncNotifier that owns the [AuthState] lifecycle.
class AuthController extends AsyncNotifier<AuthState> {
  /// Default constructor.
  AuthController();

  late AuthRepository _repository;
  late TokenStorage _tokens;

  @override
  Future<AuthState> build() async {
    _repository = ref.read(authRepositoryProvider);
    _tokens = ref.read(tokenStorageProvider);
    final user = await _repository.currentUser();
    if (user == null) {
      return const Unauthenticated();
    }
    return Authenticated(user);
  }

  Future<void> _run(Future<AuthSession> Function() op) async {
    state = const AsyncValue<AuthState>.data(Authenticating());
    try {
      final session = await op();
      await _tokens.writeTokens(
        access: session.accessToken,
        refresh: session.refreshToken,
        expiresAt: session.expiresAt,
      );
      state = AsyncValue<AuthState>.data(Authenticated(session.user));
    } on Failure catch (f, st) {
      state = AsyncValue<AuthState>.error(f, st);
    } catch (e, st) {
      state = AsyncValue<AuthState>.error(
        UnknownFailure(e.toString(), cause: e),
        st,
      );
    }
  }

  /// Email + password sign-in.
  Future<void> signInEmail({
    required String email,
    required String password,
  }) =>
      _run(
        () => _repository.signInWithEmail(email: email, password: password),
      );

  /// OAuth sign-in (Apple or Google).
  Future<void> signInOAuth(OAuthProvider provider) => _run(() {
        switch (provider) {
          case OAuthProvider.apple:
            // TODO(F-AUTH-WEB): real identity token via sign_in_with_apple.
            return _repository.signInWithApple(identityToken: 'stub');
          case OAuthProvider.google:
            // TODO(F-AUTH-WEB): real id_token via google_sign_in.
            return _repository.signInWithGoogle(idToken: 'stub');
        }
      });

  /// Sends an OTP to [identifier] (phone in E.164 or email).
  Future<void> requestOtp(String identifier) async {
    state = const AsyncValue<AuthState>.data(Authenticating());
    try {
      await _repository.requestOtp(identifier: identifier);
      state = const AsyncValue<AuthState>.data(Unauthenticated());
    } on Failure catch (f, st) {
      state = AsyncValue<AuthState>.error(f, st);
    } catch (e, st) {
      state = AsyncValue<AuthState>.error(
        UnknownFailure(e.toString(), cause: e),
        st,
      );
    }
  }

  /// Verifies the supplied [code] for [identifier].
  Future<void> verifyOtp({
    required String identifier,
    required String code,
  }) =>
      _run(
        () => _repository.verifyOtp(identifier: identifier, code: code),
      );

  /// Ends the current session and clears local tokens.
  Future<void> signOut() async {
    await _repository.signOut();
    await _tokens.clear();
    state = const AsyncValue<AuthState>.data(Unauthenticated());
  }

  /// Marks the account for deletion (30-day cool-off per PRD §15).
  Future<void> deleteAccount() async {
    state = const AsyncValue<AuthState>.data(Authenticating());
    try {
      await _repository.requestAccountDeletion();
      await _tokens.clear();
      state = const AsyncValue<AuthState>.data(Unauthenticated());
    } on Failure catch (f, st) {
      state = AsyncValue<AuthState>.error(f, st);
    } catch (e, st) {
      state = AsyncValue<AuthState>.error(
        UnknownFailure(e.toString(), cause: e),
        st,
      );
    }
  }
}
