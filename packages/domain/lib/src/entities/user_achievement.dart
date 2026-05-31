import 'package:equatable/equatable.dart';

import '../values/ulid.dart';

/// Records that a given user unlocked a given [Achievement] (F-08).
final class UserAchievement extends Equatable {
  /// Default constructor.
  const UserAchievement({
    required this.id,
    required this.userId,
    required this.achievementId,
    required this.unlockedAt,
  });

  /// ULID primary key.
  final Ulid id;

  /// Owning user.
  final Ulid userId;

  /// The achievement that was unlocked.
  final Ulid achievementId;

  /// When the achievement unlocked (UTC).
  final DateTime unlockedAt;

  /// Returns a copy with the given fields replaced.
  UserAchievement copyWith({
    Ulid? id,
    Ulid? userId,
    Ulid? achievementId,
    DateTime? unlockedAt,
  }) =>
      UserAchievement(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        achievementId: achievementId ?? this.achievementId,
        unlockedAt: unlockedAt ?? this.unlockedAt,
      );

  /// Serializes to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id.value,
        'user_id': userId.value,
        'achievement_id': achievementId.value,
        'unlocked_at': unlockedAt.toUtc().toIso8601String(),
      };

  /// Reconstructs from JSON.
  factory UserAchievement.fromJson(Map<String, dynamic> json) =>
      UserAchievement(
        id: Ulid(json['id'] as String),
        userId: Ulid(json['user_id'] as String),
        achievementId: Ulid(json['achievement_id'] as String),
        unlockedAt: DateTime.parse(json['unlocked_at'] as String),
      );

  @override
  List<Object?> get props => <Object?>[
        id,
        userId,
        achievementId,
        unlockedAt,
      ];
}
