import 'package:equatable/equatable.dart';

/// Sealed hierarchy of domain-level failure types.
///
/// Use exhaustively (`switch`) in presentation/data layers to map errors to
/// user-visible copy or retry logic.
sealed class Failure extends Equatable {
  /// Human-readable diagnostic. Not localized — translate at the UI boundary.
  const Failure(this.message, {this.cause});

  /// Short message for logs / surfaces.
  final String message;

  /// Optional originating exception or detail blob.
  final Object? cause;

  @override
  List<Object?> get props => <Object?>[message, cause];

  @override
  String toString() => '$runtimeType($message)';
}

/// The device is offline or a network request timed out.
class NetworkFailure extends Failure {
  /// Default constructor.
  const NetworkFailure(super.message, {super.cause});
}

/// The backend returned a 5xx or unexpected payload.
class ServerFailure extends Failure {
  /// [statusCode] is the HTTP status when known, otherwise -1.
  const ServerFailure(super.message, {this.statusCode = -1, super.cause});

  /// HTTP status code, or -1 if not applicable.
  final int statusCode;

  @override
  List<Object?> get props => <Object?>[message, cause, statusCode];
}

/// Local validation rejected the input.
class ValidationFailure extends Failure {
  /// [fieldErrors] maps a field name to a list of error keys.
  const ValidationFailure(super.message, {this.fieldErrors = const <String, List<String>>{}, super.cause});

  /// Field-level error map (field → list of error keys).
  final Map<String, List<String>> fieldErrors;

  @override
  List<Object?> get props => <Object?>[message, cause, fieldErrors];
}

/// The user is unauthenticated or the token expired.
class AuthFailure extends Failure {
  /// Default constructor.
  const AuthFailure(super.message, {super.cause});
}

/// A sync push collided with a server-side concurrent edit.
class SyncConflictFailure extends Failure {
  /// [entityType] and [entityId] identify the conflicting row.
  const SyncConflictFailure(
    super.message, {
    required this.entityType,
    required this.entityId,
    super.cause,
  });

  /// Logical entity table, e.g. `'transactions'`.
  final String entityType;

  /// Conflicting entity's ULID.
  final String entityId;

  @override
  List<Object?> get props => <Object?>[message, cause, entityType, entityId];
}

/// Catch-all for unmodeled errors. Avoid in new code.
class UnknownFailure extends Failure {
  /// Default constructor.
  const UnknownFailure(super.message, {super.cause});
}
