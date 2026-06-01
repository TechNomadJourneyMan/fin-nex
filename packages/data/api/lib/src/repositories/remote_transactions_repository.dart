import '../dto/pagination_dto.dart';
import '../dto/transaction_dto.dart';
import '../services/transactions_service.dart';

/// Thin facade over [TransactionsService]. Sync-package repositories combine
/// this with the local Drift store to implement the full domain contract.
///
/// TODO(F-TX-01): swap to a domain-defined `TransactionsRepository` once it
/// lands in `pf_domain`.
class RemoteTransactionsRepository {
  /// Default constructor.
  RemoteTransactionsRepository(this._service);

  final TransactionsService _service;

  /// List remote transactions.
  Future<PagedDto<TransactionDto>> list({
    String? cursor,
    int limit = 50,
    DateTime? from,
    DateTime? to,
  }) =>
      _service.list(cursor: cursor, limit: limit, from: from, to: to);

  /// Fetch a single transaction.
  Future<TransactionDto> get(String id) => _service.get(id);

  /// Create.
  Future<TransactionDto> create(CreateTransactionRequest request) =>
      _service.create(request);

  /// Update.
  Future<TransactionDto> update(
    String id,
    UpdateTransactionRequest request, {
    String? ifMatch,
  }) =>
      _service.update(id, request, ifMatch: ifMatch);

  /// Delete.
  Future<void> delete(String id, {String? ifMatch}) =>
      _service.delete(id, ifMatch: ifMatch);

  /// Bulk-create.
  Future<BulkCreateResponse> bulkCreate(
    BulkCreateTransactionsRequest request,
  ) =>
      _service.bulkCreate(request);
}
