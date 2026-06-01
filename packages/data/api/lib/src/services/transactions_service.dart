import 'package:dio/dio.dart';

import '../dto/pagination_dto.dart';
import '../dto/transaction_dto.dart';
import '_dio_helpers.dart';

/// Typed client for `/transactions`.
class TransactionsService {
  /// Default constructor.
  TransactionsService(this._dio);

  final Dio _dio;

  /// List transactions with optional filters + cursor pagination.
  Future<PagedDto<TransactionDto>> list({
    String? cursor,
    int limit = 50,
    DateTime? from,
    DateTime? to,
    List<String>? accountIds,
    List<String>? categoryIds,
    String? type,
    int? minAmount,
    int? maxAmount,
    String? query,
    String? source,
    String? order,
  }) =>
      DioServiceHelpers.guard(() async {
        final qp = <String, dynamic>{
          if (cursor != null) 'cursor': cursor,
          'limit': limit,
          if (from != null) 'from': from.toUtc().toIso8601String(),
          if (to != null) 'to': to.toUtc().toIso8601String(),
          if (accountIds != null && accountIds.isNotEmpty)
            'account_id': accountIds,
          if (categoryIds != null && categoryIds.isNotEmpty)
            'category_id': categoryIds,
          if (type != null) 'type': type,
          if (minAmount != null) 'min_amount': minAmount,
          if (maxAmount != null) 'max_amount': maxAmount,
          if (query != null) 'query': query,
          if (source != null) 'source': source,
          if (order != null) 'order': order,
        };
        final res = await _dio.get<Map<String, dynamic>>(
          '/transactions',
          queryParameters: qp,
        );
        return PagedDto.fromJson<TransactionDto>(
          res.data ?? const <String, dynamic>{},
          TransactionDto.fromJson,
        );
      });

  /// Fetch a single transaction.
  Future<TransactionDto> get(String id) => DioServiceHelpers.guard(() async {
        final res = await _dio.get<Map<String, dynamic>>('/transactions/$id');
        return TransactionDto.fromJson(res.data ?? const <String, dynamic>{});
      });

  /// Create a transaction.
  Future<TransactionDto> create(CreateTransactionRequest request) =>
      DioServiceHelpers.guard(() async {
        final res = await _dio.post<Map<String, dynamic>>(
          '/transactions',
          data: request.toJson(),
        );
        return TransactionDto.fromJson(res.data ?? const <String, dynamic>{});
      });

  /// Patch a transaction. [ifMatch] applies optimistic concurrency.
  Future<TransactionDto> update(
    String id,
    UpdateTransactionRequest request, {
    String? ifMatch,
  }) =>
      DioServiceHelpers.guard(() async {
        final res = await _dio.patch<Map<String, dynamic>>(
          '/transactions/$id',
          data: request.toJson(),
          options: DioServiceHelpers.ifMatch(ifMatch),
        );
        return TransactionDto.fromJson(res.data ?? const <String, dynamic>{});
      });

  /// Soft-delete a transaction.
  Future<void> delete(String id, {String? ifMatch}) =>
      DioServiceHelpers.guard(() async {
        await _dio.delete<void>(
          '/transactions/$id',
          options: DioServiceHelpers.ifMatch(ifMatch),
        );
      });

  /// Bulk-create up to 1000 transactions.
  Future<BulkCreateResponse> bulkCreate(
          BulkCreateTransactionsRequest request) =>
      DioServiceHelpers.guard(() async {
        final res = await _dio.post<Map<String, dynamic>>(
          '/transactions/bulk',
          data: request.toJson(),
        );
        return BulkCreateResponse.fromJson(
          res.data ?? const <String, dynamic>{},
        );
      });
}
