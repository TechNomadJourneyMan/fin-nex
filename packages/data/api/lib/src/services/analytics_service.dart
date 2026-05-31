import 'package:dio/dio.dart';

import '../dto/analytics_summary_dto.dart';
import '_dio_helpers.dart';

/// Typed client for `/analytics/*`.
class AnalyticsService {
  /// Default constructor.
  AnalyticsService(this._dio);

  final Dio _dio;

  /// Aggregate summary over a range.
  Future<AnalyticsSummaryDto> summary({
    required String from,
    required String to,
    String groupBy = 'day',
    List<String>? accountIds,
    String? currency,
  }) =>
      DioServiceHelpers.guard(() async {
        final res = await _dio.get<Map<String, dynamic>>(
          '/analytics/summary',
          queryParameters: <String, dynamic>{
            'from': from,
            'to': to,
            'group_by': groupBy,
            if (accountIds != null && accountIds.isNotEmpty)
              'account_ids': accountIds,
            if (currency != null) 'currency': currency,
          },
        );
        return AnalyticsSummaryDto.fromJson(
          res.data ?? const <String, dynamic>{},
        );
      });

  /// Breakdown by category.
  Future<AnalyticsByCategoryDto> byCategory({
    required String from,
    required String to,
    String kind = 'expense',
    int top = 10,
  }) =>
      DioServiceHelpers.guard(() async {
        final res = await _dio.get<Map<String, dynamic>>(
          '/analytics/by-category',
          queryParameters: <String, dynamic>{
            'from': from,
            'to': to,
            'kind': kind,
            'top': top,
          },
        );
        return AnalyticsByCategoryDto.fromJson(
          res.data ?? const <String, dynamic>{},
        );
      });

  /// Cashflow time series.
  Future<CashflowDto> cashflow({
    required String from,
    required String to,
    String groupBy = 'day',
  }) =>
      DioServiceHelpers.guard(() async {
        final res = await _dio.get<Map<String, dynamic>>(
          '/analytics/cashflow',
          queryParameters: <String, dynamic>{
            'from': from,
            'to': to,
            'group_by': groupBy,
          },
        );
        return CashflowDto.fromJson(res.data ?? const <String, dynamic>{});
      });
}
