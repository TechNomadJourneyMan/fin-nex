import 'package:dio/dio.dart';

import '../dto/sync_dto.dart';
import '_dio_helpers.dart';

/// Typed client for `/sync/*`.
class SyncService {
  /// Default constructor.
  SyncService(this._dio);

  final Dio _dio;

  /// Push a batch of local changes to the server.
  Future<PushResponse> push(PushRequest request) =>
      DioServiceHelpers.guard(() async {
        final res = await _dio.post<Map<String, dynamic>>(
          '/sync/push',
          data: request.toJson(),
        );
        return PushResponse.fromJson(res.data ?? const <String, dynamic>{});
      });

  /// Pull remote changes since [sinceServerRevision] or [sinceCursor].
  Future<PullResponse> pull({
    int? sinceServerRevision,
    String? sinceCursor,
    List<String>? entities,
    int limit = 500,
  }) =>
      DioServiceHelpers.guard(() async {
        final res = await _dio.get<Map<String, dynamic>>(
          '/sync/pull',
          queryParameters: <String, dynamic>{
            if (sinceServerRevision != null) 'since': sinceServerRevision,
            if (sinceCursor != null) 'since_cursor': sinceCursor,
            if (entities != null && entities.isNotEmpty)
              'entities': entities.join(','),
            'limit': limit,
          },
        );
        return PullResponse.fromJson(res.data ?? const <String, dynamic>{});
      });

  /// Lightweight status probe.
  Future<Map<String, dynamic>> status() => DioServiceHelpers.guard(() async {
        final res = await _dio.get<Map<String, dynamic>>('/sync/status');
        return res.data ?? const <String, dynamic>{};
      });
}
