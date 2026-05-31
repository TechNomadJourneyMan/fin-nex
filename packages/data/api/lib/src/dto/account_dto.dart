/// REST representation of an account.
class AccountDto {
  /// Default constructor.
  const AccountDto({
    required this.id,
    required this.name,
    required this.type,
    required this.currency,
    required this.balanceMinor,
    this.initialBalanceMinor = 0,
    this.icon,
    this.color,
    this.isArchived = false,
    this.isPrimary = false,
    this.createdAt,
    this.updatedAt,
    this.revision = 0,
  });

  /// ULID.
  final String id;

  /// Display name.
  final String name;

  /// `card | cash | savings | credit | other`.
  final String type;

  /// ISO 4217.
  final String currency;

  /// Server-computed balance in minor units.
  final int balanceMinor;

  /// Opening balance in minor units.
  final int initialBalanceMinor;

  /// Icon catalog key.
  final String? icon;

  /// Hex color.
  final String? color;

  /// Whether the account is archived.
  final bool isArchived;

  /// Whether this is the user's primary account.
  final bool isPrimary;

  /// Server creation timestamp.
  final DateTime? createdAt;

  /// Server last-update timestamp.
  final DateTime? updatedAt;

  /// Optimistic-concurrency revision counter.
  final int revision;

  /// Parse from JSON.
  factory AccountDto.fromJson(Map<String, dynamic> json) => AccountDto(
        id: json['id'] as String,
        name: json['name'] as String,
        type: json['type'] as String,
        currency: json['currency'] as String,
        balanceMinor: (json['balance_minor'] as num).toInt(),
        initialBalanceMinor:
            (json['initial_balance_minor'] as num?)?.toInt() ?? 0,
        icon: json['icon'] as String?,
        color: json['color'] as String?,
        isArchived: (json['is_archived'] as bool?) ?? false,
        isPrimary: (json['is_primary'] as bool?) ?? false,
        createdAt: json['created_at'] is String
            ? DateTime.parse(json['created_at'] as String)
            : null,
        updatedAt: json['updated_at'] is String
            ? DateTime.parse(json['updated_at'] as String)
            : null,
        revision: (json['revision'] as num?)?.toInt() ?? 0,
      );

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'type': type,
        'currency': currency,
        'balance_minor': balanceMinor,
        'initial_balance_minor': initialBalanceMinor,
        if (icon != null) 'icon': icon,
        if (color != null) 'color': color,
        'is_archived': isArchived,
        'is_primary': isPrimary,
        if (createdAt != null)
          'created_at': createdAt!.toUtc().toIso8601String(),
        if (updatedAt != null)
          'updated_at': updatedAt!.toUtc().toIso8601String(),
        'revision': revision,
      };
}

/// Create-account payload.
class CreateAccountRequest {
  /// Default constructor.
  const CreateAccountRequest({
    required this.name,
    required this.type,
    required this.currency,
    this.initialBalanceMinor = 0,
    this.icon,
    this.color,
    this.isPrimary = false,
  });

  /// Display name.
  final String name;

  /// Account type.
  final String type;

  /// ISO 4217.
  final String currency;

  /// Opening balance.
  final int initialBalanceMinor;

  /// Icon key.
  final String? icon;

  /// Hex color.
  final String? color;

  /// Mark as primary.
  final bool isPrimary;

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'type': type,
        'currency': currency,
        'initial_balance_minor': initialBalanceMinor,
        if (icon != null) 'icon': icon,
        if (color != null) 'color': color,
        'is_primary': isPrimary,
      };
}

/// Partial update payload.
class UpdateAccountRequest {
  /// Default constructor.
  const UpdateAccountRequest({
    this.name,
    this.icon,
    this.color,
    this.isPrimary,
    this.isArchived,
  });

  /// New name.
  final String? name;

  /// New icon.
  final String? icon;

  /// New color.
  final String? color;

  /// Primary flag.
  final bool? isPrimary;

  /// Archived flag.
  final bool? isArchived;

  /// Serialize to JSON (omits unset fields).
  Map<String, dynamic> toJson() => <String, dynamic>{
        if (name != null) 'name': name,
        if (icon != null) 'icon': icon,
        if (color != null) 'color': color,
        if (isPrimary != null) 'is_primary': isPrimary,
        if (isArchived != null) 'is_archived': isArchived,
      };
}
