import '../entities/streak.dart';
import '../repositories/streak_repository.dart';
import '../values/ulid.dart';

/// Returns the current streak record for [userId].
class GetStreak {
  /// Default constructor.
  const GetStreak(this._repo);

  final StreakRepository _repo;

  /// Invokes the use case.
  Future<Streak> call(Ulid userId) => _repo.get(userId);
}
