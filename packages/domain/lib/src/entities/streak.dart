import 'package:equatable/equatable.dart';

import '../values/ulid.dart';

/// Tracks consecutive-day app usage for retention gamification.
final class Streak extends Equatable {
  /// Default constructor.
  const Streak({
    required this.userId,
    required this.currentStreakDays,
    required this.longestStreakDays,
    required this.totalActiveDays,
    required this.updatedAt,
    this.lastActiveDate,
    this.frozenUntil,
  });

  /// Owning user — also the primary key.
  final Ulid userId;

  /// Active streak length (consecutive days up to today).
  final int currentStreakDays;

  /// All-time longest streak.
  final int longestStreakDays;

  /// Most-recent active calendar date (local).
  final DateTime? lastActiveDate;

  /// Total distinct active days.
  final int totalActiveDays;

  /// `frozen_until` power-up: streak doesn't break before this date.
  final DateTime? frozenUntil;

  /// Last update.
  final DateTime updatedAt;

  /// Returns a copy with the given fields replaced.
  Streak copyWith({
    Ulid? userId,
    int? currentStreakDays,
    int? longestStreakDays,
    DateTime? lastActiveDate,
    int? totalActiveDays,
    DateTime? frozenUntil,
    DateTime? updatedAt,
  }) =>
      Streak(
        userId: userId ?? this.userId,
        currentStreakDays: currentStreakDays ?? this.currentStreakDays,
        longestStreakDays: longestStreakDays ?? this.longestStreakDays,
        lastActiveDate: lastActiveDate ?? this.lastActiveDate,
        totalActiveDays: totalActiveDays ?? this.totalActiveDays,
        frozenUntil: frozenUntil ?? this.frozenUntil,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  /// Serializes to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'user_id': userId.value,
        'current_streak_days': currentStreakDays,
        'longest_streak_days': longestStreakDays,
        'last_active_date': lastActiveDate?.toUtc().toIso8601String(),
        'total_active_days': totalActiveDays,
        'frozen_until': frozenUntil?.toUtc().toIso8601String(),
        'updated_at': updatedAt.toUtc().toIso8601String(),
      };

  /// Reconstructs from JSON.
  factory Streak.fromJson(Map<String, dynamic> json) => Streak(
        userId: Ulid(json['user_id'] as String),
        currentStreakDays: (json['current_streak_days'] as num).toInt(),
        longestStreakDays: (json['longest_streak_days'] as num).toInt(),
        lastActiveDate: json['last_active_date'] == null
            ? null
            : DateTime.parse(json['last_active_date'] as String),
        totalActiveDays: (json['total_active_days'] as num).toInt(),
        frozenUntil: json['frozen_until'] == null
            ? null
            : DateTime.parse(json['frozen_until'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  @override
  List<Object?> get props => <Object?>[
        userId,
        currentStreakDays,
        longestStreakDays,
        lastActiveDate,
        totalActiveDays,
        frozenUntil,
        updatedAt,
      ];
}
