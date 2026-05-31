import 'package:dio/dio.dart';

import '../client/dio_factory.dart';

/// Adds `Authorization: Bearer <token>` to every request that does not opt out
/// (via `extra['skipAuth'] = true`). On 401 responses it calls [onRefresh]
/// exactly once and retries the original request.
class AuthInterceptor extends Interceptor {
  /// Default constructor.
  AuthInterceptor({
    required AccessTokenProvider getAccessToken,
    required TokenRefresher onRefresh,
    required Dio dio,
  })  : _getAccessToken = getAccessToken,
        _onRefresh = onRefresh,
        _dio = dio;

  final AccessTokenProvider _getAccessToken;
  final TokenRefresher _onRefresh;
  final Dio _dio;

  /// Mark a request as not requiring auth (e.g. sign-in).
  static const String skipAuthExtraKey = 'skipAuth';

  /// Internal flag preventing infinite refresh loops.
  static const String _retriedExtraKey = '__auth_retried';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[skipAuthExtraKey] != true) {
      final token = await _getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    if (response.statusCode == 401 &&
        response.requestOptions.extra[_retriedExtraKey] != true &&
        response.requestOptions.extra[skipAuthExtraKey] != true) {
      try {
        final newToken = await _onRefresh();
        if (newToken == null || newToken.isEmpty) {
          handler.next(response);
          return;
        }
        final retried = await _retryWithToken(
          response.requestOptions,
          newToken,
        );
        handler.resolve(retried);
        return;
      } catch (_) {
        handler.next(response);
        return;
      }
    }
    handler.next(response);
  }

  Future<Response<dynamic>> _retryWithToken(
    RequestOptions original,
    String token,
  ) {
    final headers = Map<String, dynamic>.from(original.headers)
      ..['Authorization'] = 'Bearer $token';
    final extra = Map<String, dynamic>.from(original.extra)
      ..[_retriedExtraKey] = true
      // We already set the freshly-refreshed token explicitly — prevent the
      // request-side AuthInterceptor from overwriting it with the stale one
      // still cached in the [AccessTokenProvider].
      ..[skipAuthExtraKey] = true;
    final options = Options(
      method: original.method,
      headers: headers,
      contentType: original.contentType,
      responseType: original.responseType,
      sendTimeout: original.sendTimeout,
      receiveTimeout: original.receiveTimeout,
      extra: extra,
    );
    return _dio.request<dynamic>(
      original.path,
      data: original.data,
      queryParameters: original.queryParameters,
      options: options,
      cancelToken: original.cancelToken,
    );
  }
}
