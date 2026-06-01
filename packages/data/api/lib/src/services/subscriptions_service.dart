import 'package:dio/dio.dart';

import '../dto/subscription_dto.dart';
import '_dio_helpers.dart';

/// Typed client for `/subscriptions/*`.
class SubscriptionsService {
  /// Default constructor.
  SubscriptionsService(this._dio);

  final Dio _dio;

  /// Fetch the current user's subscription state.
  Future<SubscriptionDto> me() => DioServiceHelpers.guard(() async {
        final res = await _dio.get<Map<String, dynamic>>('/subscriptions/me');
        return SubscriptionDto.fromJson(res.data ?? const <String, dynamic>{});
      });

  /// Validate a store receipt and obtain the updated subscription state.
  Future<SubscriptionDto> validateReceipt(ValidateReceiptRequest request) =>
      DioServiceHelpers.guard(() async {
        final res = await _dio.post<Map<String, dynamic>>(
          '/subscriptions/validate-receipt',
          data: request.toJson(),
        );
        return SubscriptionDto.fromJson(res.data ?? const <String, dynamic>{});
      });

  /// Restore a subscription on a new device.
  Future<SubscriptionDto> restore() => DioServiceHelpers.guard(() async {
        final res = await _dio.post<Map<String, dynamic>>(
          '/subscriptions/restore',
        );
        return SubscriptionDto.fromJson(res.data ?? const <String, dynamic>{});
      });
}
