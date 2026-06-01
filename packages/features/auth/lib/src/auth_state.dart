// Auth state model for the auth feature.

import 'package:pf_domain/pf_domain.dart';

/// Sealed hierarchy describing the auth controller's lifecycle.
sealed class AuthState {
  /// Default constructor.
  const AuthState();
}

/// No active session.
class Unauthenticated extends AuthState {
  /// Default constructor.
  const Unauthenticated();
}

/// A network operation (sign-in / sign-up / OTP) is in flight.
class Authenticating extends AuthState {
  /// Default constructor.
  const Authenticating();
}

/// A user is signed in.
class Authenticated extends AuthState {
  /// Default constructor.
  const Authenticated(this.user);

  /// The signed-in user.
  final User user;
}

/// An error occurred during the last auth operation.
class AuthError extends AuthState {
  /// Default constructor.
  const AuthError(this.failure);

  /// The underlying failure.
  final Failure failure;
}
