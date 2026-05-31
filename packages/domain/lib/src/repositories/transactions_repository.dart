import '../entities/transaction.dart';
import '../values/ulid.dart';

/// Filter set for listing transactions.
class TransactionFilter {
  /// Default constructor.
  const TransactionFilter({
    this.from,
    this.to,
    this.accountIds = const <Ulid>[],
    this.categoryIds = const <Ulid>[],
    this.types = const <String>[],
    this.searchText,
    this.limit,
    this.offset,
  });

  /// Inclusive lower bound on `occurredAt`.
  final DateTime? from;

  /// Exclusive upper bound on `occurredAt`.
  final DateTime? to;

  /// Restrict to these accounts (empty = all).
  final List<Ulid> accountIds;

  /// Restrict to these categories (empty = all).
  final List<Ulid> categoryIds;

  /// Restrict to these transaction-type codes.
  final List<String> types;

  /// Free-text search on description.
  final String? searchText;

  /// Maximum number of rows.
  final int? limit;

  /// Offset for paging.
  final int? offset;
}

/// Persistence and query contract for [Transaction].
abstract interface class TransactionsRepository {
  /// Returns a stream of all live transactions for [userId].
  Stream<List<Transaction>> watchAll(Ulid userId);

  /// Returns transactions matching [filter] for [userId].
  Future<List<Transaction>> list(Ulid userId, TransactionFilter filter);

  /// Returns the transaction with [id], or `null` if missing.
  Future<Transaction?> getById(Ulid id);

  /// Inserts or updates [tx].
  Future<void> upsert(Transaction tx);

  /// Soft-deletes [id].
  Future<void> softDelete(Ulid id);
}
