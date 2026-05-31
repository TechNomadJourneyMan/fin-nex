import '../entities/transaction.dart';
import '../failures/failure.dart';
import '../repositories/transactions_repository.dart';

/// Edits an existing [Transaction]. Bumps `updatedAt`.
class EditTransaction {
  /// Default constructor.
  const EditTransaction(this._repo);

  final TransactionsRepository _repo;

  /// Invokes the use case.
  Future<void> call(Transaction updated) async {
    if (await _repo.getById(updated.id) == null) {
      throw ValidationFailure(
        'Transaction ${updated.id.value} not found',
      );
    }
    await _repo.upsert(updated.copyWith(updatedAt: DateTime.now().toUtc()));
  }
}
