import '../entities/recurring_rule.dart';
import '../values/ulid.dart';

/// Persistence and query contract for [RecurringRule].
abstract interface class RecurringRulesRepository {
  /// Returns a stream of all live rules for [userId].
  Stream<List<RecurringRule>> watchAll(Ulid userId);

  /// Returns every rule for [userId] (point-in-time, used by the engine).
  Future<List<RecurringRule>> list(Ulid userId);

  /// Returns the rule with [id], or `null` if missing.
  Future<RecurringRule?> getById(Ulid id);

  /// Inserts or updates [rule].
  Future<void> upsert(RecurringRule rule);

  /// Permanently removes [id].
  Future<void> delete(Ulid id);
}
