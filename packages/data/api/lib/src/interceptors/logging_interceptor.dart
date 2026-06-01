import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Lightweight request/response logger that only emits in debug builds.
/// Sensitive headers (Authorization, idempotency keys, push tokens) are
/// redacted.
class LoggingInterceptor extends Interceptor {
  /// Default constructor.
  LoggingInterceptor();

  static const Set<String> _redactedHeaders = <String>{
    'authorization',
    'x-idempotency-key',
    'x-env-token',
    'cookie',
    'set-cookie',
  };

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      final headers = _redact(options.headers);
      debugPrint('[pf_api] -> ${options.method} ${options.uri} '
          'headers=$headers');
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      debugPrint('[pf_api] <- ${response.statusCode} '
          '${response.requestOptions.uri}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('[pf_api] xx ${err.response?.statusCode ?? '-'} '
          '${err.requestOptions.uri} ${err.message}');
    }
    handler.next(err);
  }

  Map<String, dynamic> _redact(Map<String, dynamic> headers) {
    final out = <String, dynamic>{};
    headers.forEach((String k, dynamic v) {
      if (_redactedHeaders.contains(k.toLowerCase())) {
        out[k] = '<redacted>';
      } else {
        out[k] = v;
      }
    });
    return out;
  }
}
