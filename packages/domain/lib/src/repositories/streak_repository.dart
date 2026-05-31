import '../entities/streak.dart';
import '../values/ulid.dart';

/// Streak persistence contract.
abstract interface class StreakRepository {
  /// Live stream of [Streak] for [userId].
  Stream<Streak> watch(Ulid userId);

  /// Reads the current streak (create-or-load).
  Future<Streak> get(Ulid userId);

  /// Replaces the streak record.
  Future<void> save(Streak streak);
}
