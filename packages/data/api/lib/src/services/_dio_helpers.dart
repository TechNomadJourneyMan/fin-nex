import 'package:dio/dio.dart';

import '../exceptions/api_exception.dart';

/// Internal helpers shared by service classes.
class DioServiceHelpers {
  const DioServiceHelpers._();

  /// Unwrap a [DioException] into our typed [ApiException].
  static Never rethrowAsApi(DioException err) {
    final error = err.error;
    if (error is ApiException) {
      throw error;
    }
    throw ApiException(
      statusCode: err.response?.statusCode ?? -1,
      code: 'UNKNOWN',
      message: err.message ?? 'Unknown error',
      cause: err,
    );
  }

  /// Run [body]; convert any [DioException] into an [ApiException].
  static Future<T> guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on DioException catch (e) {
      rethrowAsApi(e);
    }
  }

  /// Build an [Options] with the given `If-Match` header when not null.
  static Options? ifMatch(String? etag) {
    if (etag == null) return null;
    return Options(headers: <String, dynamic>{'If-Match': etag});
  }
}
