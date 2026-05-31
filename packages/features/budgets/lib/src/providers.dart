// Riverpod providers for the budgets feature.
//
// In-memory defaults so the feature is functional on Web before the data
// layer is wired. Override in app composition.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fnx_domain/domain.dart';

import 'budget_calculator.dart';
import 'data/in_memory_budgets_repository.dart';

/// Provides the active [BudgetsRepository].
final budgetsRepositoryProvider = Provider<BudgetsRepository>((ref) {
  // TODO(F-budget): replace with real repository in app composition.
  return InMemoryBudgetsRepository();
});

/// Provides the active [TransactionsRepository], for spend calculation.
///
/// Apps override this with the real implementation. The default stub yields
/// an empty list so widgets render predictably.
final budgetsTransactionsRepositoryProvider =
    Provider<TransactionsRepository>((ref) {
  // TODO(F-tx): replace with real repository in app composition.
  return _EmptyTxRepo();
});

/// Provides the [BudgetCalculator] singleton.
final budgetCalculatorProvider =
    Provider<BudgetCalculator>((ref) => const BudgetCalculator());

/// Current user id; overridden by the auth feature.
final budgetsCurrentUserIdProvider = Provider<Ulid>((ref) {
  // TODO(F-auth): provide real user id.
  return Ulid('00000000000000000000000000');
});

/// Streams all transactions for the current user. Used by the budgets list
/// to recompute spend live as transactions change.
final budgetsTransactionsStreamProvider =
    StreamProvider<List<Transaction>>((ref) {
  final repo = ref.watch(budgetsTransactionsRepositoryProvider);
  final userId = ref.watch(budgetsCurrentUserIdProvider);
  return repo.watchAll(userId);
});

class _EmptyTxRepo implements TransactionsRepository {
  @override
  Stream<List<Transaction>> watchAll(Ulid userId) =>
      Stream<List<Transaction>>.value(const <Transaction>[]);

  @override
  Future<List<Transaction>> list(Ulid userId, TransactionFilter filter) async =>
      const <Transaction>[];

  @override
  Future<Transaction?> getById(Ulid id) async => null;

  @override
  Future<void> upsert(Transaction tx) async {}

  @override
  Future<void> softDelete(Ulid id) async {}
}
