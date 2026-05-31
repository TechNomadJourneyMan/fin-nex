import '../entities/budget.dart';
import '../failures/failure.dart';
import '../repositories/budgets_repository.dart';

/// Creates a new [Budget].
class CreateBudget {
  /// Default constructor.
  const CreateBudget(this._repo);

  final BudgetsRepository _repo;

  /// Invokes the use case.
  Future<void> call(Budget budget) async {
    if (budget.amount.isZero || budget.amount.isNegative) {
      throw const ValidationFailure(
        'Budget amount must be positive',
        fieldErrors: <String, List<String>>{
          'amount': <String>['must_be_positive'],
        },
      );
    }
    await _repo.upsertBudget(budget);
  }
}
