import '../entities/transaction.dart';
import '../repositories/transactions_repository.dart';
import '../values/ulid.dart';

/// Lists transactions for [userId] with the supplied filter.
class ListTransactions {
  /// Default constructor.
  const ListTransactions(this._repo);

  final TransactionsRepository _repo;

  /// Invokes the use case.
  Future<List<Transaction>> call(
    Ulid userId, {
    TransactionFilter filter = const TransactionFilter(),
  }) =>
      _repo.list(userId, filter);
}
