import 'dart:math';

import 'package:dio/dio.dart';

/// Adds a UUID v4 `X-Idempotency-Key` header to every POST that does not
/// already specify one. Callers can opt out by setting
/// `options.extra['skipIdempotency'] = true` or providing the header up-front.
class IdempotencyInterceptor extends Interceptor {
  /// Default constructor; an optional [random] makes the generator testable.
  IdempotencyInterceptor({Random? random}) : _random = random ?? Random.secure();

  final Random _random;

  /// Header name.
  static const String headerName = 'X-Idempotency-Key';

  /// Extra key callers can set to opt out (rarely needed).
  static const String skipExtraKey = 'skipIdempotency';

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (options.method.toUpperCase() == 'POST' &&
        options.extra[skipExtraKey] != true &&
        !options.headers.containsKey(headerName)) {
      options.headers[headerName] = _uuidV4();
    }
    handler.next(options);
  }

  String _uuidV4() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    // Variant + version bits per RFC 4122 §4.4.
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    String hex(int byte) => byte.toRadixString(16).padLeft(2, '0');
    final h = bytes.map(hex).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-'
        '${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20, 32)}';
  }
}
