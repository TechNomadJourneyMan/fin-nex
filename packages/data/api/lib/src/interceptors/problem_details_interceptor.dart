import 'package:dio/dio.dart';

import '../dto/error_dto.dart';
import '../exceptions/api_exception.dart';

/// Converts non-2xx HTTP responses and Dio transport errors into typed
/// [ApiException]s, parsing RFC 9457 Problem Details documents when present.
class ProblemDetailsInterceptor extends Interceptor {
  /// Default constructor.
  ProblemDetailsInterceptor();

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final status = response.statusCode ?? 0;
    if (status >= 200 && status < 300) {
      handler.next(response);
      return;
    }
    final exception = _exceptionFromResponse(response);
    handler.reject(
      DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: exception,
        type: DioExceptionType.badResponse,
      ),
    );
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.error is ApiException) {
      handler.next(err);
      return;
    }
    final response = err.response;
    final ApiException exception;
    if (response != null) {
      exception = _exceptionFromResponse(response);
    } else {
      exception = _exceptionFromTransport(err);
    }
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        error: exception,
        type: err.type,
        stackTrace: err.stackTrace,
      ),
    );
  }

  ApiException _exceptionFromResponse(Response<dynamic> response) {
    final status = response.statusCode ?? -1;
    ProblemDetailsDto? problem;
    final body = response.data;
    if (body is Map<String, dynamic>) {
      try {
        problem = ProblemDetailsDto.fromJson(body);
      } catch (_) {
        problem = null;
      }
    }
    final code = problem?.code ?? _fallbackCode(status);
    final message = problem?.detail ?? problem?.title ?? 'HTTP $status';

    if (status == 401 || status == 403) {
      return ApiAuthException(
        statusCode: status,
        code: code,
        message: message,
        problem: problem,
      );
    }
    if (status == 409 &&
        (code == 'SYNC_VERSION_MISMATCH' || code == 'DUPLICATE_CLIENT_ID')) {
      return ApiSyncConflictException(
        statusCode: status,
        code: code,
        message: message,
        entity: 'unknown',
        entityId: '',
        problem: problem,
      );
    }
    return ApiException(
      statusCode: status,
      code: code,
      message: message,
      problem: problem,
    );
  }

  ApiException _exceptionFromTransport(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return ApiNetworkException(
          err.message ?? 'Network unavailable',
          cause: err,
        );
      case DioExceptionType.cancel:
        return ApiException(
          statusCode: -1,
          code: 'CANCELLED',
          message: 'Request cancelled',
          cause: err,
        );
      case DioExceptionType.badCertificate:
      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        return ApiException(
          statusCode: err.response?.statusCode ?? -1,
          code: 'UNKNOWN',
          message: err.message ?? 'Unknown error',
          cause: err,
        );
    }
  }

  String _fallbackCode(int status) {
    switch (status) {
      case 400:
        return 'BAD_REQUEST';
      case 401:
        return 'UNAUTHENTICATED';
      case 403:
        return 'FORBIDDEN';
      case 404:
        return 'NOT_FOUND';
      case 409:
        return 'CONFLICT';
      case 412:
        return 'PRECONDITION_FAILED';
      case 413:
        return 'REQUEST_BODY_TOO_LARGE';
      case 415:
        return 'UNSUPPORTED_MEDIA_TYPE';
      case 422:
        return 'VALIDATION_FAILED';
      case 426:
        return 'UPGRADE_REQUIRED';
      case 429:
        return 'RATE_LIMITED';
      case 500:
        return 'INTERNAL_ERROR';
      case 503:
        return 'SERVICE_UNAVAILABLE';
      case 504:
        return 'GATEWAY_TIMEOUT';
      default:
        return 'HTTP_$status';
    }
  }
}
