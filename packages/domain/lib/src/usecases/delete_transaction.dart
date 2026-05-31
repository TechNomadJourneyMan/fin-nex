import '../repositories/transactions_repository.dart';
import '../values/ulid.dart';

/// Soft-deletes a transaction (moves it to the trash for 30 days).
class DeleteTransaction {
  /// Default constructor.
  const DeleteTransaction(this._repo);

  final TransactionsRepository _repo;

  /// Invokes the use case.
  Future<void> call(Ulid id) => _repo.softDelete(id);
}
