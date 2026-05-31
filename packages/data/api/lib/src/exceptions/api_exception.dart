import '../dto/error_dto.dart';

/// Typed exception thrown by services when the backend returns a non-2xx
/// response. Wraps a parsed RFC 9457 [ProblemDetailsDto] when available.
class ApiException implements Exception {
  /// Default constructor.
  ApiException({
    required this.statusCode,
    required this.code,
    required this.message,
    this.problem,
    this.cause,
  });

  /// HTTP status code (e.g. 422). `-1` if no response was received.
  final int statusCode;

  /// Machine-readable, stable error code from the backend catalog.
  final String code;

  /// Human-readable message (untranslated; UI should translate via [code]).
  final String message;

  /// Parsed problem document, when the server returned one.
  final ProblemDetailsDto? problem;

  /// Underlying cause (Dio error, parse error, etc.).
  final Object? cause;

  @override
  String toString() => 'ApiException($statusCode, $code, $message)';
}

/// Thrown when the device is offline or the request timed out before a
/// response was received.
class ApiNetworkException extends ApiException {
  /// Default constructor.
  ApiNetworkException(String message, {Object? cause})
      : super(
          statusCode: -1,
          code: 'NETWORK',
          message: message,
          cause: cause,
        );
}

/// Thrown when access has been revoked or the refresh flow failed.
class ApiAuthException extends ApiException {
  /// Default constructor.
  ApiAuthException({
    required super.statusCode,
    required super.code,
    required super.message,
    super.problem,
    super.cause,
  });
}

/// Thrown when a sync push is rejected because of a server-side concurrent
/// edit (HTTP 409 with sync codes).
class ApiSyncConflictException extends ApiException {
  /// Default constructor.
  ApiSyncConflictException({
    required super.statusCode,
    required super.code,
    required super.message,
    required this.entity,
    required this.entityId,
    super.problem,
    super.cause,
  });

  /// Logical entity name, e.g. `transaction`.
  final String entity;

  /// Conflicting entity id.
  final String entityId;
}
