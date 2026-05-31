import '../entities/user.dart';

/// Authenticated session token bundle.
class AuthSession {
  /// Default constructor.
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.user,
  });

  /// Short-lived bearer token.
  final String accessToken;

  /// Long-lived refresh token.
  final String refreshToken;

  /// [accessToken] expiry moment.
  final DateTime expiresAt;

  /// Authenticated user.
  final User user;
}

/// Authentication operations.
abstract interface class AuthRepository {
  /// Stream of the currently authenticated user (null when signed-out).
  Stream<User?> watchCurrentUser();

  /// Returns the currently signed-in user, or null.
  Future<User?> currentUser();

  /// Email + password sign-in.
  Future<AuthSession> signInWithEmail({
    required String email,
    required String password,
  });

  /// Apple Sign-In with an opaque platform identity token.
  Future<AuthSession> signInWithApple({required String identityToken});

  /// Google Sign-In with an OAuth id token.
  Future<AuthSession> signInWithGoogle({required String idToken});

  /// Requests a one-time-code via email or SMS.
  Future<void> requestOtp({required String identifier});

  /// Exchanges an OTP for a session.
  Future<AuthSession> verifyOtp({
    required String identifier,
    required String code,
  });

  /// Ends the current session.
  Future<void> signOut();

  /// Marks the account for deletion (30-day cool-off, see PRD §15).
  Future<void> requestAccountDeletion();
}
