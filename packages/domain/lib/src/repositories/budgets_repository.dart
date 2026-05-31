import '../entities/budget.dart';
import '../entities/limit.dart';
import '../values/ulid.dart';

/// Persistence and query contract for [Budget] and [Limit].
abstract interface class BudgetsRepository {
  /// Live list of all active budgets for [userId].
  Stream<List<Budget>> watchBudgets(Ulid userId);

  /// Snapshot list of budgets.
  Future<List<Budget>> listBudgets(Ulid userId);

  /// Inserts or updates [budget].
  Future<void> upsertBudget(Budget budget);

  /// Soft-deletes the budget [id].
  Future<void> softDeleteBudget(Ulid id);

  /// Live list of active limits.
  Stream<List<Limit>> watchLimits(Ulid userId);

  /// Snapshot list of limits.
  Future<List<Limit>> listLimits(Ulid userId);

  /// Inserts or updates [limit].
  Future<void> upsertLimit(Limit limit);

  /// Soft-deletes the limit [id].
  Future<void> softDeleteLimit(Ulid id);
}
