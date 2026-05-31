import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Programmable [HttpClientAdapter] for tests. Routes are matched by
/// `(METHOD, path)` and respond with the queued handler's response.
class MockHttpAdapter implements HttpClientAdapter {
  /// Default constructor.
  MockHttpAdapter();

  final List<RecordedRequest> _recorded = <RecordedRequest>[];
  final List<_Route> _routes = <_Route>[];

  /// Recorded requests in order.
  List<RecordedRequest> get recorded => _recorded;

  /// Register a handler for `(method, path)`. Handlers are matched FIFO.
  void onRequest(
    String method,
    String path,
    FutureOr<MockResponse> Function(RecordedRequest request) handler,
  ) {
    _routes.add(_Route(method.toUpperCase(), path, handler));
  }

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    Map<String, dynamic>? bodyJson;
    if (options.data is Map<String, dynamic>) {
      bodyJson = options.data as Map<String, dynamic>;
    } else if (options.data is String) {
      try {
        bodyJson = jsonDecode(options.data as String) as Map<String, dynamic>;
      } catch (_) {
        bodyJson = null;
      }
    }
    final recorded = RecordedRequest(
      method: options.method.toUpperCase(),
      path: options.path,
      headers: Map<String, dynamic>.from(options.headers),
      query: Map<String, dynamic>.from(options.queryParameters),
      body: bodyJson,
    );
    _recorded.add(recorded);

    for (final route in _routes) {
      if (route.method == recorded.method && route.path == recorded.path) {
        final response = await route.handler(recorded);
        final bytes = utf8.encode(response.body);
        return ResponseBody.fromBytes(
          bytes,
          response.statusCode,
          headers: <String, List<String>>{
            'content-type': <String>[response.contentType],
            ...response.headers,
          },
        );
      }
    }
    return ResponseBody.fromString(
      jsonEncode(<String, dynamic>{
        'type': 'about:blank',
        'title': 'Not Found',
        'status': 404,
        'code': 'NOT_FOUND',
        'detail': 'No mock route for ${recorded.method} ${recorded.path}',
        'trace_id': 'test',
      }),
      404,
      headers: <String, List<String>>{
        'content-type': <String>['application/problem+json'],
      },
    );
  }
}

/// A captured request.
class RecordedRequest {
  /// Default constructor.
  RecordedRequest({
    required this.method,
    required this.path,
    required this.headers,
    required this.query,
    required this.body,
  });

  /// HTTP method.
  final String method;

  /// Request path.
  final String path;

  /// Headers map.
  final Map<String, dynamic> headers;

  /// Query parameters.
  final Map<String, dynamic> query;

  /// JSON-decoded body, when applicable.
  final Map<String, dynamic>? body;
}

/// Helper to construct a mock response.
class MockResponse {
  /// Default constructor.
  MockResponse({
    required this.statusCode,
    required this.body,
    this.contentType = 'application/json; charset=utf-8',
    this.headers = const <String, List<String>>{},
  });

  /// JSON helper.
  factory MockResponse.json(int status, Object json) => MockResponse(
        statusCode: status,
        body: jsonEncode(json),
      );

  /// Problem-details helper.
  factory MockResponse.problem(
    int status,
    String code,
    String detail,
  ) =>
      MockResponse(
        statusCode: status,
        contentType: 'application/problem+json',
        body: jsonEncode(<String, dynamic>{
          'type': 'https://api.finnex.kz/problems/${code.toLowerCase()}',
          'title': code,
          'status': status,
          'code': code,
          'detail': detail,
          'trace_id': 'test',
        }),
      );

  /// HTTP status code.
  final int statusCode;

  /// Body.
  final String body;

  /// Content-Type.
  final String contentType;

  /// Extra response headers.
  final Map<String, List<String>> headers;
}

class _Route {
  _Route(this.method, this.path, this.handler);

  final String method;
  final String path;
  final FutureOr<MockResponse> Function(RecordedRequest) handler;
}
