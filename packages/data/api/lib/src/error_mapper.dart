import 'package:fnx_domain/fnx_domain.dart';

import 'exceptions/api_exception.dart';

/// Maps an [ApiException] to a domain-layer [Failure] subclass.
Failure failureFromApiException(ApiException error) {
  if (error is ApiNetworkException) {
    return NetworkFailure(error.message, cause: error);
  }
  if (error is ApiAuthException) {
    return AuthFailure(error.message, cause: error);
  }
  if (error is ApiSyncConflictException) {
    return SyncConflictFailure(
      error.message,
      entityType: error.entity,
      entityId: error.entityId,
      cause: error,
    );
  }
  final status = error.statusCode;
  if (status == 422 || status == 400) {
    final fieldErrors = <String, List<String>>{};
    final problem = error.problem;
    if (problem != null) {
      for (final fe in problem.errors) {
        fieldErrors.putIfAbsent(fe.field, () => <String>[]).add(fe.code);
      }
    }
    return ValidationFailure(
      error.message,
      fieldErrors: fieldErrors,
      cause: error,
    );
  }
  if (status == 401 || status == 403) {
    return AuthFailure(error.message, cause: error);
  }
  if (status >= 500 || status == -1) {
    return ServerFailure(
      error.message,
      statusCode: status,
      cause: error,
    );
  }
  return ServerFailure(error.message, statusCode: status, cause: error);
}
