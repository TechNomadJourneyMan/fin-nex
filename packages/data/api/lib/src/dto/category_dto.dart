/// REST representation of a category (system or user-defined).
class CategoryDto {
  /// Default constructor.
  const CategoryDto({
    required this.id,
    required this.kind,
    required this.name,
    this.icon,
    this.color,
    this.isSystem = false,
    this.parentId,
    this.sortOrder = 0,
    this.revision = 0,
  });

  /// ULID or system id (e.g. `cat_sys_food`).
  final String id;

  /// `expense | income`.
  final String kind;

  /// Display name (localized server-side).
  final String name;

  /// Icon key.
  final String? icon;

  /// Hex color.
  final String? color;

  /// Whether this is a read-only system category.
  final bool isSystem;

  /// Parent category id for hierarchical layouts.
  final String? parentId;

  /// Sort weight.
  final int sortOrder;

  /// Optimistic-concurrency counter.
  final int revision;

  /// Parse from JSON.
  factory CategoryDto.fromJson(Map<String, dynamic> json) => CategoryDto(
        id: json['id'] as String,
        kind: (json['kind'] as String?) ?? 'expense',
        name: json['name'] as String,
        icon: json['icon'] as String?,
        color: json['color'] as String?,
        isSystem: (json['is_system'] as bool?) ?? false,
        parentId: json['parent_id'] as String?,
        sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
        revision: (json['revision'] as num?)?.toInt() ?? 0,
      );

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'kind': kind,
        'name': name,
        if (icon != null) 'icon': icon,
        if (color != null) 'color': color,
        'is_system': isSystem,
        if (parentId != null) 'parent_id': parentId,
        'sort_order': sortOrder,
        'revision': revision,
      };
}

/// Create-category payload.
class CreateCategoryRequest {
  /// Default constructor.
  const CreateCategoryRequest({
    required this.kind,
    required this.name,
    this.icon,
    this.color,
    this.parentId,
  });

  /// `expense | income`.
  final String kind;

  /// Display name.
  final String name;

  /// Icon key.
  final String? icon;

  /// Hex color.
  final String? color;

  /// Optional parent id.
  final String? parentId;

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'kind': kind,
        'name': name,
        if (icon != null) 'icon': icon,
        if (color != null) 'color': color,
        if (parentId != null) 'parent_id': parentId,
      };
}

/// Partial update payload.
class UpdateCategoryRequest {
  /// Default constructor.
  const UpdateCategoryRequest({
    this.name,
    this.icon,
    this.color,
    this.parentId,
    this.sortOrder,
  });

  /// New name.
  final String? name;

  /// New icon.
  final String? icon;

  /// New color.
  final String? color;

  /// New parent id (set to empty string to unparent).
  final String? parentId;

  /// New sort order.
  final int? sortOrder;

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        if (name != null) 'name': name,
        if (icon != null) 'icon': icon,
        if (color != null) 'color': color,
        if (parentId != null) 'parent_id': parentId,
        if (sortOrder != null) 'sort_order': sortOrder,
      };
}
