import 'package:equatable/equatable.dart';

import '../values/category_color.dart';
import '../values/money.dart';
import '../values/ulid.dart';
import 'enums.dart';

/// A spending or income category.
///
/// System categories have [isSystem] = true and `userId == null`; custom
/// categories are user-scoped.
final class Category extends Equatable {
  /// Default constructor.
  const Category({
    required this.id,
    required this.type,
    required this.name,
    required this.iconKey,
    required this.color,
    required this.isSystem,
    required this.isArchived,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.userId,
    this.parentId,
    this.nameI18nKey,
    this.monthlyLimit,
    this.deletedAt,
  });

  /// ULID primary key.
  final Ulid id;

  /// Owning user; null for system categories.
  final Ulid? userId;

  /// Category classification.
  final CategoryType type;

  /// Parent category for two-level hierarchies (sub-categories).
  final Ulid? parentId;

  /// User-visible name (or fallback when [nameI18nKey] is missing).
  final String name;

  /// Translation key for system categories (e.g. `category.food`).
  final String? nameI18nKey;

  /// Icon identifier (asset name or sprite key).
  final String iconKey;

  /// Display color.
  final CategoryColor color;

  /// True when category is built-in.
  final bool isSystem;

  /// True when hidden from pickers.
  final bool isArchived;

  /// Order key.
  final int sortOrder;

  /// Optional soft monthly cap shown inline on category cards.
  final Money? monthlyLimit;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Last update timestamp.
  final DateTime updatedAt;

  /// Soft-delete moment.
  final DateTime? deletedAt;

  /// Returns a copy with the given fields replaced.
  Category copyWith({
    Ulid? id,
    Ulid? userId,
    CategoryType? type,
    Ulid? parentId,
    String? name,
    String? nameI18nKey,
    String? iconKey,
    CategoryColor? color,
    bool? isSystem,
    bool? isArchived,
    int? sortOrder,
    Money? monthlyLimit,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) =>
      Category(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        type: type ?? this.type,
        parentId: parentId ?? this.parentId,
        name: name ?? this.name,
        nameI18nKey: nameI18nKey ?? this.nameI18nKey,
        iconKey: iconKey ?? this.iconKey,
        color: color ?? this.color,
        isSystem: isSystem ?? this.isSystem,
        isArchived: isArchived ?? this.isArchived,
        sortOrder: sortOrder ?? this.sortOrder,
        monthlyLimit: monthlyLimit ?? this.monthlyLimit,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt ?? this.deletedAt,
      );

  /// Serializes to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id.value,
        'user_id': userId?.value,
        'type_code': type.code,
        'parent_id': parentId?.value,
        'name': name,
        'name_i18n_key': nameI18nKey,
        'icon_key': iconKey,
        'color': color.hex,
        'is_system': isSystem,
        'is_archived': isArchived,
        'sort_order': sortOrder,
        'monthly_limit': monthlyLimit?.toJson(),
        'created_at': createdAt.toUtc().toIso8601String(),
        'updated_at': updatedAt.toUtc().toIso8601String(),
        'deleted_at': deletedAt?.toUtc().toIso8601String(),
      };

  /// Reconstructs from JSON.
  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: Ulid(json['id'] as String),
        userId: json['user_id'] == null ? null : Ulid(json['user_id'] as String),
        type: CategoryType.parse(json['type_code'] as String),
        parentId:
            json['parent_id'] == null ? null : Ulid(json['parent_id'] as String),
        name: json['name'] as String,
        nameI18nKey: json['name_i18n_key'] as String?,
        iconKey: json['icon_key'] as String,
        color: CategoryColor(json['color'] as String),
        isSystem: json['is_system'] as bool,
        isArchived: json['is_archived'] as bool,
        sortOrder: json['sort_order'] as int,
        monthlyLimit: json['monthly_limit'] == null
            ? null
            : Money.fromJson(json['monthly_limit'] as Map<String, dynamic>),
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
        type,
        parentId,
        name,
        nameI18nKey,
        iconKey,
        color,
        isSystem,
        isArchived,
        sortOrder,
        monthlyLimit,
        createdAt,
        updatedAt,
        deletedAt,
      ];
}
