import '../entities/achievement.dart';
import '../entities/user_achievement.dart';
import '../values/ulid.dart';

/// Persistence + recompute contract for the gamification engine (F-08).
abstract interface class AchievementsRepository {
  /// Live stream of the (read-only) achievement catalog.
  Stream<List<Achievement>> watchAchievements();

  /// Reads the full achievement catalog once.
  Future<List<Achievement>> listAchievements();

  /// Live stream of the achievements [userId] has unlocked.
  Stream<List<UserAchievement>> watchUserAchievements(Ulid userId);

  /// Reads [userId]'s unlocked achievements once.
  Future<List<UserAchievement>> listUserAchievements(Ulid userId);

  /// Unlocks [achievementKey] for [userId] if not already unlocked.
  ///
  /// Returns the freshly-created [UserAchievement], or `null` when the
  /// achievement was already unlocked (idempotent no-op).
  Future<UserAchievement?> unlock(
    Ulid userId,
    String achievementKey, {
    DateTime? at,
  });

  /// Re-evaluates all achievement rules against the latest user state and
  /// unlocks any that newly qualify.
  ///
  /// Returns the achievements unlocked by this call (may be empty).
  Future<List<UserAchievement>> recompute(Ulid userId, {DateTime? now});
}
