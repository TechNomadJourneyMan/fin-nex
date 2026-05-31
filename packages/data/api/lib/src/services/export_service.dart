import 'package:dio/dio.dart';

import '../dto/export_dto.dart';
import '_dio_helpers.dart';

/// Typed client for `/export/*`.
class ExportService {
  /// Default constructor.
  ExportService(this._dio);

  final Dio _dio;

  /// Enqueue a new export job.
  Future<ExportJobDto> request(ExportRequestRequest request) =>
      DioServiceHelpers.guard(() async {
        final res = await _dio.post<Map<String, dynamic>>(
          '/export/request',
          data: request.toJson(),
        );
        return ExportJobDto.fromJson(res.data ?? const <String, dynamic>{});
      });

  /// Poll the status of an export job.
  Future<ExportJobDto> status(String jobId) =>
      DioServiceHelpers.guard(() async {
        final res = await _dio.get<Map<String, dynamic>>(
          '/export/$jobId/status',
        );
        return ExportJobDto.fromJson(res.data ?? const <String, dynamic>{});
      });

  /// Returns the signed download URL via a 302 redirect's `Location` header.
  Future<String> downloadUrl(String jobId) =>
      DioServiceHelpers.guard(() async {
        final res = await _dio.get<dynamic>(
          '/export/$jobId/download',
          options: Options(
            followRedirects: false,
            // Treat 302 as a success — extract the Location header.
            validateStatus: (int? code) => code != null && code < 400,
          ),
        );
        final location = res.headers.value('location');
        if (location != null) return location;
        // Some servers may return JSON `{download_url: ...}` directly.
        final body = res.data;
        if (body is Map<String, dynamic> && body['download_url'] is String) {
          return body['download_url'] as String;
        }
        throw StateError('Export download URL missing in response');
      });
}
