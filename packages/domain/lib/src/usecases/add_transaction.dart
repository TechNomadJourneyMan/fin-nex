import '../entities/transaction.dart';
import '../failures/failure.dart';
import '../repositories/transactions_repository.dart';

/// Persists a brand-new [Transaction].
class AddTransaction {
  /// Default constructor.
  const AddTransaction(this._repo);

  final TransactionsRepository _repo;

  /// Invokes the use case.
  ///
  /// Throws [ValidationFailure] when the amount is zero or negative.
  Future<void> call(Transaction tx) async {
    if (tx.amount.isZero || tx.amount.isNegative) {
      throw const ValidationFailure(
        'Transaction amount must be positive',
        fieldErrors: <String, List<String>>{
          'amount': <String>['must_be_positive'],
        },
      );
    }
    await _repo.upsert(tx);
  }
}
