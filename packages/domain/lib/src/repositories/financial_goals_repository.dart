import '../entities/financial_goal.dart';
import '../values/ulid.dart';

/// Persistence and query contract for [FinancialGoal].
abstract interface class FinancialGoalsRepository {
  /// Live list of non-deleted goals for [userId].
  Stream<List<FinancialGoal>> watchAll(Ulid userId);

  /// Snapshot list of non-deleted goals for [userId].
  Future<List<FinancialGoal>> list(Ulid userId);

  /// Returns the goal with [id], or `null` when absent.
  Future<FinancialGoal?> getById(Ulid id);

  /// Inserts or updates [goal].
  Future<void> upsert(FinancialGoal goal);

  /// Soft-deletes [id].
  Future<void> softDelete(Ulid id);

  /// Re-reads the linked account balance for goal [id] and mirrors it into
  /// `currentAmount`, returning the updated goal.
  ///
  /// When the goal has no linked account the goal is returned unchanged.
  /// Returns `null` when no goal with [id] exists.
  Future<FinancialGoal?> recomputeProgress(Ulid id);
}
