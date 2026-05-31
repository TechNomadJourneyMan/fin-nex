import 'package:equatable/equatable.dart';

import '../values/currency.dart';
import '../values/ulid.dart';
import 'enums.dart';

/// A multi-tenant container that partitions a user's financial data into a
/// Personal or Business space (PRD F-06).
///
/// Accounts, categories, transactions and budgets all carry a nullable
/// `workspace_id` that points back at one of these. A user always has exactly
/// one [isDefault] workspace (the "Personal" one created at migration time).
final class Workspace extends Equatable {
  /// Default constructor.
  const Workspace({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.baseCurrency,
    required this.colorHex,
    required this.createdAt,
    required this.updatedAt,
    required this.isDefault,
    this.iconKey,
    this.deletedAt,
  });

  /// ULID primary key.
  final Ulid id;

  /// Owning user.
  final Ulid userId;

  /// User-supplied workspace name.
  final String name;

  /// Tenancy kind (personal / business).
  final WorkspaceType type;

  /// Currency new accounts in this workspace default to.
  final Currency baseCurrency;

  /// Display color in `#RRGGBB`.
  final String colorHex;

  /// Optional iconography key.
  final String? iconKey;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Last update timestamp.
  final DateTime updatedAt;

  /// Soft-delete timestamp; non-null means in trash.
  final DateTime? deletedAt;

  /// Whether this is the user's default workspace.
  final bool isDefault;

  /// Returns a copy with the given fields replaced.
  Workspace copyWith({
    Ulid? id,
    Ulid? userId,
    String? name,
    WorkspaceType? type,
    Currency? baseCurrency,
    String? colorHex,
    String? iconKey,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? isDefault,
  }) => Workspace(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    type: type ?? this.type,
    baseCurrency: baseCurrency ?? this.baseCurrency,
    colorHex: colorHex ?? this.colorHex,
    iconKey: iconKey ?? this.iconKey,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt ?? this.deletedAt,
    isDefault: isDefault ?? this.isDefault,
  );

  /// Serializes to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id.value,
    'user_id': userId.value,
    'name': name,
    'type': type.code,
    'base_currency': baseCurrency.code,
    'color_hex': colorHex,
    'icon_key': iconKey,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'deleted_at': deletedAt?.toUtc().toIso8601String(),
    'is_default': isDefault,
  };

  /// Reconstructs from JSON.
  factory Workspace.fromJson(Map<String, dynamic> json) => Workspace(
    id: Ulid(json['id'] as String),
    userId: Ulid(json['user_id'] as String),
    name: json['name'] as String,
    type: WorkspaceType.parse(json['type'] as String),
    baseCurrency: Currency.parse(json['base_currency'] as String),
    colorHex: json['color_hex'] as String,
    iconKey: json['icon_key'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
    deletedAt: json['deleted_at'] == null
        ? null
        : DateTime.parse(json['deleted_at'] as String),
    isDefault: json['is_default'] as bool,
  );

  @override
  List<Object?> get props => <Object?>[
    id,
    userId,
    name,
    type,
    baseCurrency,
    colorHex,
    iconKey,
    createdAt,
    updatedAt,
    deletedAt,
    isDefault,
  ];
}
