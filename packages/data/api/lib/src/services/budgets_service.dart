import 'package:dio/dio.dart';

import '../dto/budget_dto.dart';
import '_dio_helpers.dart';

/// Typed client for `/budgets`.
class BudgetsService {
  /// Default constructor.
  BudgetsService(this._dio);

  final Dio _dio;

  /// List budgets.
  Future<List<BudgetDto>> list({String? period, String? status}) =>
      DioServiceHelpers.guard(() async {
        final res = await _dio.get<Map<String, dynamic>>(
          '/budgets',
          queryParameters: <String, dynamic>{
            if (period != null) 'period': period,
            if (status != null) 'status': status,
          },
        );
        final data = (res.data?['data'] as List<dynamic>?) ?? const <dynamic>[];
        return data
            .map((dynamic e) => BudgetDto.fromJson(e as Map<String, dynamic>))
            .toList(growable: false);
      });

  /// Create a budget.
  Future<BudgetDto> create(CreateBudgetRequest request) =>
      DioServiceHelpers.guard(() async {
        final res = await _dio.post<Map<String, dynamic>>(
          '/budgets',
          data: request.toJson(),
        );
        return BudgetDto.fromJson(res.data ?? const <String, dynamic>{});
      });

  /// Fetch budget progress for the current period.
  Future<BudgetProgressDto> progress(String id) =>
      DioServiceHelpers.guard(() async {
        final res =
            await _dio.get<Map<String, dynamic>>('/budgets/$id/progress');
        return BudgetProgressDto.fromJson(
          res.data ?? const <String, dynamic>{},
        );
      });

  /// Delete a budget.
  Future<void> delete(String id, {String? ifMatch}) =>
      DioServiceHelpers.guard(() async {
        await _dio.delete<void>(
          '/budgets/$id',
          options: DioServiceHelpers.ifMatch(ifMatch),
        );
      });
}
