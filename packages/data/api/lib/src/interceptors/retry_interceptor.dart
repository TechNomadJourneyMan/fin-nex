import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';

import '../exceptions/api_exception.dart';

/// Exponential-backoff retry with jitter for transient failures (5xx and
/// network errors). Limited to 3 attempts. Idempotent verbs (GET / HEAD /
/// DELETE / PUT) and POSTs carrying `X-Idempotency-Key` are eligible.
class RetryInterceptor extends Interceptor {
  /// Default constructor.
  RetryInterceptor({
    required Dio dio,
    this.maxAttempts = 3,
    this.baseDelay = const Duration(milliseconds: 250),
    this.maxDelay = const Duration(seconds: 8),
    Random? random,
  })  : _dio = dio,
        _random = random ?? Random();

  final Dio _dio;

  /// Total attempts including the initial request.
  final int maxAttempts;

  /// Starting backoff delay before jitter.
  final Duration baseDelay;

  /// Upper bound on the delay between attempts.
  final Duration maxDelay;

  final Random _random;

  static const String _attemptExtraKey = '__retry_attempt';

  /// Opt-out flag: set `options.extra['skipRetry'] = true` to disable.
  static const String skipExtraKey = 'skipRetry';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final attempt = (options.extra[_attemptExtraKey] as int?) ?? 1;
    if (!_shouldRetry(err, options, attempt)) {
      handler.next(err);
      return;
    }
    final delay = _computeDelay(attempt);
    await Future<void>.delayed(delay);
    try {
      final retried = await _dio.fetch<dynamic>(
        options
          ..extra[_attemptExtraKey] = attempt + 1,
      );
      handler.resolve(retried);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  bool _shouldRetry(DioException err, RequestOptions options, int attempt) {
    if (options.extra[skipExtraKey] == true) {
      return false;
    }
    if (attempt >= maxAttempts) {
      return false;
    }
    final method = options.method.toUpperCase();
    final isSafe = method == 'GET' ||
        method == 'HEAD' ||
        method == 'DELETE' ||
        method == 'PUT' ||
        (method == 'POST' &&
            options.headers.containsKey('X-Idempotency-Key'));
    if (!isSafe) {
      return false;
    }
    final apiErr = err.error;
    if (apiErr is ApiNetworkException) {
      return true;
    }
    final status = err.response?.statusCode ?? 0;
    if (status >= 500 && status != 501) {
      return true;
    }
    return false;
  }

  Duration _computeDelay(int attempt) {
    final exp = baseDelay.inMilliseconds * (1 << (attempt - 1));
    final capped = exp.clamp(baseDelay.inMilliseconds, maxDelay.inMilliseconds);
    final jitter = _random.nextInt(capped ~/ 2 + 1);
    return Duration(milliseconds: capped + jitter);
  }
}
