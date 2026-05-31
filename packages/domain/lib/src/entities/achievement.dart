import 'package:equatable/equatable.dart';

import '../values/ulid.dart';
import 'enums.dart';

/// A definable gamification badge the user can unlock (F-08).
///
/// Achievements are seeded read-only system rows; their copy is localised via
/// the `*Key` i18n keys rather than stored as literal strings.
final class Achievement extends Equatable {
  /// Default constructor.
  const Achievement({
    required this.id,
    required this.key,
    required this.titleKey,
    required this.descriptionKey,
    required this.iconKey,
    required this.xpReward,
    required this.category,
    this.isHidden = false,
  });

  /// Surrogate ULID primary key (deterministic for system rows).
  final Ulid id;

  /// Stable machine key, e.g. `first_transaction`. Unique across the catalog.
  final String key;

  /// i18n key for the badge title.
  final String titleKey;

  /// i18n key for the badge description.
  final String descriptionKey;

  /// Icon key (Material/SF symbol name).
  final String iconKey;

  /// Experience points awarded when the achievement unlocks.
  final int xpReward;

  /// Thematic grouping for grid sectioning and filtering.
  final AchievementCategory category;

  /// True for spoiler badges that are hidden until unlocked.
  final bool isHidden;

  /// Returns a copy with the given fields replaced.
  Achievement copyWith({
    Ulid? id,
    String? key,
    String? titleKey,
    String? descriptionKey,
    String? iconKey,
    int? xpReward,
    AchievementCategory? category,
    bool? isHidden,
  }) =>
      Achievement(
        id: id ?? this.id,
        key: key ?? this.key,
        titleKey: titleKey ?? this.titleKey,
        descriptionKey: descriptionKey ?? this.descriptionKey,
        iconKey: iconKey ?? this.iconKey,
        xpReward: xpReward ?? this.xpReward,
        category: category ?? this.category,
        isHidden: isHidden ?? this.isHidden,
      );

  /// Serializes to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id.value,
        'key': key,
        'title_key': titleKey,
        'description_key': descriptionKey,
        'icon_key': iconKey,
        'xp_reward': xpReward,
        'category': category.code,
        'is_hidden': isHidden,
      };

  /// Reconstructs from JSON.
  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        id: Ulid(json['id'] as String),
        key: json['key'] as String,
        titleKey: json['title_key'] as String,
        descriptionKey: json['description_key'] as String,
        iconKey: json['icon_key'] as String,
        xpReward: (json['xp_reward'] as num).toInt(),
        category: AchievementCategory.parse(json['category'] as String),
        isHidden: (json['is_hidden'] as bool?) ?? false,
      );

  @override
  List<Object?> get props => <Object?>[
        id,
        key,
        titleKey,
        descriptionKey,
        iconKey,
        xpReward,
        category,
        isHidden,
      ];
}
