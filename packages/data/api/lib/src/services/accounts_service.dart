import 'package:dio/dio.dart';

import '../dto/account_dto.dart';
import '_dio_helpers.dart';

/// Typed client for `/accounts`.
class AccountsService {
  /// Default constructor.
  AccountsService(this._dio);

  final Dio _dio;

  /// List accounts.
  Future<List<AccountDto>> list({bool includeArchived = false}) =>
      DioServiceHelpers.guard(() async {
        final res = await _dio.get<Map<String, dynamic>>(
          '/accounts',
          queryParameters: <String, dynamic>{
            'include_archived': includeArchived,
          },
        );
        final data = (res.data?['data'] as List<dynamic>?) ?? const <dynamic>[];
        return data
            .map((dynamic e) => AccountDto.fromJson(e as Map<String, dynamic>))
            .toList(growable: false);
      });

  /// Fetch a single account.
  Future<AccountDto> get(String id) => DioServiceHelpers.guard(() async {
        final res = await _dio.get<Map<String, dynamic>>('/accounts/$id');
        return AccountDto.fromJson(res.data ?? const <String, dynamic>{});
      });

  /// Create an account.
  Future<AccountDto> create(CreateAccountRequest request) =>
      DioServiceHelpers.guard(() async {
        final res = await _dio.post<Map<String, dynamic>>(
          '/accounts',
          data: request.toJson(),
        );
        return AccountDto.fromJson(res.data ?? const <String, dynamic>{});
      });

  /// Patch an account.
  Future<AccountDto> update(
    String id,
    UpdateAccountRequest request, {
    String? ifMatch,
  }) =>
      DioServiceHelpers.guard(() async {
        final res = await _dio.patch<Map<String, dynamic>>(
          '/accounts/$id',
          data: request.toJson(),
          options: DioServiceHelpers.ifMatch(ifMatch),
        );
        return AccountDto.fromJson(res.data ?? const <String, dynamic>{});
      });

  /// Archive or hard-delete an account.
  Future<void> delete(String id, {bool force = false, String? ifMatch}) =>
      DioServiceHelpers.guard(() async {
        await _dio.delete<void>(
          '/accounts/$id',
          queryParameters: <String, dynamic>{if (force) 'force': true},
          options: DioServiceHelpers.ifMatch(ifMatch),
        );
      });
}
