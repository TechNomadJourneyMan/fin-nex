import 'package:dio/dio.dart';

import '../interceptors/auth_interceptor.dart';
import '../interceptors/idempotency_interceptor.dart';
import '../interceptors/logging_interceptor.dart';
import '../interceptors/problem_details_interceptor.dart';
import '../interceptors/retry_interceptor.dart';
import 'api_config.dart';

/// Signature for obtaining the current access token, or `null` if signed out.
typedef AccessTokenProvider = Future<String?> Function();

/// Signature for refreshing the access token; should return a new token or
/// `null` to indicate the user must re-authenticate.
typedef TokenRefresher = Future<String?> Function();

/// Signature for obtaining the device id (ULID).
typedef DeviceIdProvider = Future<String> Function();

/// Builds a [Dio] instance pre-configured with the FinNex interceptor stack.
class DioFactory {
  const DioFactory._();

  /// Create a configured [Dio].
  static Dio create({
    required ApiConfig config,
    required AccessTokenProvider getAccessToken,
    required TokenRefresher onRefresh,
    required DeviceIdProvider getDeviceId,
    String acceptLanguage = 'ru-RU',
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: config.connectTimeout,
        receiveTimeout: config.receiveTimeout,
        sendTimeout: config.sendTimeout,
        contentType: 'application/json; charset=utf-8',
        responseType: ResponseType.json,
        headers: <String, dynamic>{
          'Accept': 'application/json',
          'Accept-Language': acceptLanguage,
          'X-Client-Version': config.clientVersion,
          if (config.envToken != null) 'X-Env-Token': config.envToken,
        },
        // Treat 4xx/5xx as responses (not exceptions) so our problem-details
        // interceptor can convert them into typed [ApiException]s uniformly.
        validateStatus: (int? code) => true,
      ),
    );

    dio.interceptors.addAll(<Interceptor>[
      _DeviceIdInterceptor(getDeviceId),
      IdempotencyInterceptor(),
      AuthInterceptor(
        getAccessToken: getAccessToken,
        onRefresh: onRefresh,
        dio: dio,
      ),
      RetryInterceptor(dio: dio),
      ProblemDetailsInterceptor(),
      LoggingInterceptor(),
    ]);

    return dio;
  }
}

/// Adds the required `X-Device-Id` header to every request.
class _DeviceIdInterceptor extends Interceptor {
  _DeviceIdInterceptor(this._getDeviceId);

  final DeviceIdProvider _getDeviceId;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!options.headers.containsKey('X-Device-Id')) {
      try {
        options.headers['X-Device-Id'] = await _getDeviceId();
      } catch (_) {
        // Best-effort; some endpoints (e.g. local mocks) accept missing id.
      }
    }
    handler.next(options);
  }
}
