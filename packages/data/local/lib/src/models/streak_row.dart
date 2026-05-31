import 'package:meta/meta.dart';

import '_helpers.dart';

/// Persisted shape of the per-user activity streak.
@immutable
class StreakRow {
  /// Creates an immutable streak row.
  const StreakRow({
    required this.userId,
    required this.updatedAt,
    this.currentStreakDays = 0,
    this.longestStreakDays = 0,
    this.lastActiveDate,
    this.totalActiveDays = 0,
    this.frozenUntil,
    this.version = 1,
  });

  /// Builds a [StreakRow] from a sqflite result map.
  factory StreakRow.fromMap(Map<String, Object?> m) => StreakRow(
        userId: m['user_id']! as String,
        currentStreakDays: m['current_streak_days']! as int,
        longestStreakDays: m['longest_streak_days']! as int,
        lastActiveDate: parseDate(m['last_active_date']),
        totalActiveDays: m['total_active_days']! as int,
        frozenUntil: parseDate(m['frozen_until']),
        updatedAt: parseDate(m['updated_at'])!,
        version: m['version']! as int,
      );

  /// Owner user ULID.
  final String userId;

  /// Current consecutive-active-days count.
  final int currentStreakDays;

  /// Longest streak ever achieved.
  final int longestStreakDays;

  /// Most recent active date (UTC, date-only).
  final DateTime? lastActiveDate;

  /// Total number of distinct active days lifetime.
  final int totalActiveDays;

  /// Streak-freeze power-up expiry (UTC).
  final DateTime? frozenUntil;

  /// Last update timestamp (UTC).
  final DateTime updatedAt;

  /// Lamport version counter.
  final int version;

  /// Serialises to a sqflite-friendly map.
  Map<String, Object?> toMap() => <String, Object?>{
        'user_id': userId,
        'current_streak_days': currentStreakDays,
        'longest_streak_days': longestStreakDays,
        'last_active_date': formatDateOrNull(lastActiveDate),
        'total_active_days': totalActiveDays,
        'frozen_until': formatDateOrNull(frozenUntil),
        'updated_at': formatDate(updatedAt),
        'version': version,
      };
}
