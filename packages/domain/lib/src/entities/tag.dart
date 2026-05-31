import 'package:equatable/equatable.dart';

import '../values/category_color.dart';
import '../values/ulid.dart';

/// A user-defined free-form label on a transaction.
final class Tag extends Equatable {
  /// Default constructor.
  const Tag({
    required this.id,
    required this.userId,
    required this.name,
    required this.color,
    required this.usageCount,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  /// ULID primary key.
  final Ulid id;

  /// Owning user.
  final Ulid userId;

  /// Display name (case-insensitive uniqueness per user).
  final String name;

  /// Display color.
  final CategoryColor color;

  /// Number of transactions currently using this tag.
  final int usageCount;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Last update timestamp.
  final DateTime updatedAt;

  /// Soft-delete timestamp.
  final DateTime? deletedAt;

  /// Returns a copy with the given fields replaced.
  Tag copyWith({
    Ulid? id,
    Ulid? userId,
    String? name,
    CategoryColor? color,
    int? usageCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) =>
      Tag(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        color: color ?? this.color,
        usageCount: usageCount ?? this.usageCount,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt ?? this.deletedAt,
      );

  /// Serializes to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id.value,
        'user_id': userId.value,
        'name': name,
        'color': color.hex,
        'usage_count': usageCount,
        'created_at': createdAt.toUtc().toIso8601String(),
        'updated_at': updatedAt.toUtc().toIso8601String(),
        'deleted_at': deletedAt?.toUtc().toIso8601String(),
      };

  /// Reconstructs from JSON.
  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
        id: Ulid(json['id'] as String),
        userId: Ulid(json['user_id'] as String),
        name: json['name'] as String,
        color: CategoryColor(json['color'] as String),
        usageCount: (json['usage_count'] as num).toInt(),
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        deletedAt: json['deleted_at'] == null
            ? null
            : DateTime.parse(json['deleted_at'] as String),
      );

  @override
  List<Object?> get props => <Object?>[
        id,
        userId,
        name,
        color,
        usageCount,
        createdAt,
        updatedAt,
        deletedAt,
      ];
}
