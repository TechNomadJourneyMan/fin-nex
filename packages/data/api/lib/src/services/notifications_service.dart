import 'package:dio/dio.dart';

import '../dto/notification_dto.dart';
import '../dto/pagination_dto.dart';
import '_dio_helpers.dart';

/// Typed client for `/notifications` and `/notifications/preferences`.
class NotificationsService {
  /// Default constructor.
  NotificationsService(this._dio);

  final Dio _dio;

  /// List notifications.
  Future<PagedDto<NotificationDto>> list({
    String? cursor,
    int limit = 50,
    bool unreadOnly = false,
  }) =>
      DioServiceHelpers.guard(() async {
        final res = await _dio.get<Map<String, dynamic>>(
          '/notifications',
          queryParameters: <String, dynamic>{
            if (cursor != null) 'cursor': cursor,
            'limit': limit,
            'unread_only': unreadOnly,
          },
        );
        return PagedDto.fromJson<NotificationDto>(
          res.data ?? const <String, dynamic>{},
          NotificationDto.fromJson,
        );
      });

  /// Mark a single notification as read.
  Future<void> markRead(String id) => DioServiceHelpers.guard(() async {
        await _dio.patch<void>('/notifications/$id/read');
      });

  /// Mark every notification as read.
  Future<int> markAllRead() => DioServiceHelpers.guard(() async {
        final res = await _dio.post<Map<String, dynamic>>(
          '/notifications/mark-all-read',
        );
        return (res.data?['marked'] as num?)?.toInt() ?? 0;
      });

  /// Fetch notification preferences.
  Future<NotificationPreferencesDto> preferences() =>
      DioServiceHelpers.guard(() async {
        final res = await _dio.get<Map<String, dynamic>>(
          '/notifications/preferences',
        );
        return NotificationPreferencesDto.fromJson(
          res.data ?? const <String, dynamic>{},
        );
      });

  /// Update notification preferences.
  Future<NotificationPreferencesDto> updatePreferences(
    NotificationPreferencesDto preferences,
  ) =>
      DioServiceHelpers.guard(() async {
        final res = await _dio.patch<Map<String, dynamic>>(
          '/notifications/preferences',
          data: preferences.toJson(),
        );
        return NotificationPreferencesDto.fromJson(
          res.data ?? const <String, dynamic>{},
        );
      });
}
