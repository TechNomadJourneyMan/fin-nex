import 'package:equatable/equatable.dart';

import '../values/category_color.dart';
import '../values/currency.dart';
import '../values/money.dart';
import '../values/ulid.dart';
import 'enums.dart';

/// A user-owned financial account (cash, card, bank, etc.).
final class Account extends Equatable {
  /// Default constructor.
  const Account({
    required this.id,
    required this.userId,
    required this.type,
    required this.name,
    required this.currency,
    required this.balance,
    required this.initialBalance,
    required this.color,
    required this.isArchived,
    required this.includeInTotal,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.creditLimit,
    this.bankCode,
    this.lastFour,
    this.icon,
    this.deletedAt,
  });

  /// ULID primary key.
  final Ulid id;

  /// Owning user.
  final Ulid userId;

  /// Logical account type.
  final AccountType type;

  /// User-supplied account name.
  final String name;

  /// Currency this account is denominated in.
  final Currency currency;

  /// Cached balance — derived from `SUM(transactions)`, never authoritative.
  final Money balance;

  /// Opening balance set at creation.
  final Money initialBalance;

  /// Credit limit; only meaningful for [AccountType.creditCard].
  final Money? creditLimit;

  /// Optional bank code (`kaspi`, `halyk`, …) for SMS / import matching.
  final String? bankCode;

  /// Last four digits of card, for display only.
  final String? lastFour;

  /// Display color in `#RRGGBB`.
  final CategoryColor color;

  /// Optional iconography key.
  final String? icon;

  /// User has archived the account (read-only in UI).
  final bool isArchived;

  /// Whether the balance contributes to net-worth totals.
  final bool includeInTotal;

  /// Sort key for the accounts list.
  final int sortOrder;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Last update timestamp.
  final DateTime updatedAt;

  /// Soft-delete timestamp; non-null means in trash.
  final DateTime? deletedAt;

  /// Returns a copy with the given fields replaced.
  Account copyWith({
    Ulid? id,
    Ulid? userId,
    AccountType? type,
    String? name,
    Currency? currency,
    Money? balance,
    Money? initialBalance,
    Money? creditLimit,
    String? bankCode,
    String? lastFour,
    CategoryColor? color,
    String? icon,
    bool? isArchived,
    bool? includeInTotal,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) =>
      Account(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        type: type ?? this.type,
        name: name ?? this.name,
        currency: currency ?? this.currency,
        balance: balance ?? this.balance,
        initialBalance: initialBalance ?? this.initialBalance,
        creditLimit: creditLimit ?? this.creditLimit,
        bankCode: bankCode ?? this.bankCode,
        lastFour: lastFour ?? this.lastFour,
        color: color ?? this.color,
        icon: icon ?? this.icon,
        isArchived: isArchived ?? this.isArchived,
        includeInTotal: includeInTotal ?? this.includeInTotal,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt ?? this.deletedAt,
      );

  /// Serializes to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id.value,
        'user_id': userId.value,
        'type_code': type.code,
        'name': name,
        'currency': currency.code,
        'balance': balance.toJson(),
        'initial_balance': initialBalance.toJson(),
        'credit_limit': creditLimit?.toJson(),
        'bank_code': bankCode,
        'last_four': lastFour,
        'color': color.hex,
        'icon': icon,
        'is_archived': isArchived,
        'include_in_total': includeInTotal,
        'sort_order': sortOrder,
        'created_at': createdAt.toUtc().toIso8601String(),
        'updated_at': updatedAt.toUtc().toIso8601String(),
        'deleted_at': deletedAt?.toUtc().toIso8601String(),
      };

  /// Reconstructs from JSON.
  factory Account.fromJson(Map<String, dynamic> json) => Account(
        id: Ulid(json['id'] as String),
        userId: Ulid(json['user_id'] as String),
        type: AccountType.parse(json['type_code'] as String),
        name: json['name'] as String,
        currency: Currency.parse(json['currency'] as String),
        balance: Money.fromJson(json['balance'] as Map<String, dynamic>),
        initialBalance:
            Money.fromJson(json['initial_balance'] as Map<String, dynamic>),
        creditLimit: json['credit_limit'] == null
            ? null
            : Money.fromJson(json['credit_limit'] as Map<String, dynamic>),
        bankCode: json['bank_code'] as String?,
        lastFour: json['last_four'] as String?,
        color: CategoryColor(json['color'] as String),
        icon: json['icon'] as String?,
        isArchived: json['is_archived'] as bool,
        includeInTotal: json['include_in_total'] as bool,
        sortOrder: json['sort_order'] as int,
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
        name,
        currency,
        balance,
        initialBalance,
        creditLimit,
        bankCode,
        lastFour,
        color,
        icon,
        isArchived,
        includeInTotal,
        sortOrder,
        createdAt,
        updatedAt,
        deletedAt,
      ];
}
