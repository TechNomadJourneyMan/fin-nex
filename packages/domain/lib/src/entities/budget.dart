import 'package:equatable/equatable.dart';

import '../values/money.dart';
import '../values/ulid.dart';
import 'enums.dart';

/// A planned spending envelope for a category, account, or total.
final class Budget extends Equatable {
  /// Default constructor.
  const Budget({
    required this.id,
    required this.userId,
    required this.name,
    required this.period,
    required this.amount,
    required this.startsOn,
    required this.alertThresholds,
    required this.rolloverUnspent,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.categoryIds = const <Ulid>[],
    this.accountIds = const <Ulid>[],
    this.endsOn,
    this.deletedAt,
  });

  /// ULID primary key.
  final Ulid id;

  /// Owning user.
  final Ulid userId;

  /// User-supplied budget name.
  final String name;

  /// Period code.
  final BudgetPeriod period;

  /// Cap amount.
  final Money amount;

  /// Optional category scope; empty means all.
  final List<Ulid> categoryIds;

  /// Optional account scope; empty means all.
  final List<Ulid> accountIds;

  /// Period start (date-only).
  final DateTime startsOn;

  /// Period end (exclusive), null for rolling.
  final DateTime? endsOn;

  /// Whether unspent rolls over to next period.
  final bool rolloverUnspent;

  /// Percent thresholds at which alerts fire (e.g. `[50, 80, 100]`).
  final List<int> alertThresholds;

  /// Soft activation flag.
  final bool isActive;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Last update timestamp.
  final DateTime updatedAt;

  /// Soft-delete timestamp.
  final DateTime? deletedAt;

  /// Returns a copy with the given fields replaced.
  Budget copyWith({
    Ulid? id,
    Ulid? userId,
    String? name,
    BudgetPeriod? period,
    Money? amount,
    List<Ulid>? categoryIds,
    List<Ulid>? accountIds,
    DateTime? startsOn,
    DateTime? endsOn,
    bool? rolloverUnspent,
    List<int>? alertThresholds,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) =>
      Budget(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        period: period ?? this.period,
        amount: amount ?? this.amount,
        categoryIds: categoryIds ?? this.categoryIds,
        accountIds: accountIds ?? this.accountIds,
        startsOn: startsOn ?? this.startsOn,
        endsOn: endsOn ?? this.endsOn,
        rolloverUnspent: rolloverUnspent ?? this.rolloverUnspent,
        alertThresholds: alertThresholds ?? this.alertThresholds,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt ?? this.deletedAt,
      );

  /// Serializes to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id.value,
        'user_id': userId.value,
        'name': name,
        'period_code': period.code,
        'amount': amount.toJson(),
        'category_ids':
            categoryIds.map((Ulid c) => c.value).toList(growable: false),
        'account_ids':
            accountIds.map((Ulid c) => c.value).toList(growable: false),
        'starts_on': startsOn.toUtc().toIso8601String(),
        'ends_on': endsOn?.toUtc().toIso8601String(),
        'rollover_unspent': rolloverUnspent,
        'alert_thresholds': alertThresholds,
        'is_active': isActive,
        'created_at': createdAt.toUtc().toIso8601String(),
        'updated_at': updatedAt.toUtc().toIso8601String(),
        'deleted_at': deletedAt?.toUtc().toIso8601String(),
      };

  /// Reconstructs from JSON.
  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
        id: Ulid(json['id'] as String),
        userId: Ulid(json['user_id'] as String),
        name: json['name'] as String,
        period: BudgetPeriod.parse(json['period_code'] as String),
        amount: Money.fromJson(json['amount'] as Map<String, dynamic>),
        categoryIds: ((json['category_ids'] as List<dynamic>?) ??
                const <dynamic>[])
            .map((dynamic c) => Ulid(c as String))
            .toList(growable: false),
        accountIds:
            ((json['account_ids'] as List<dynamic>?) ?? const <dynamic>[])
                .map((dynamic c) => Ulid(c as String))
                .toList(growable: false),
        startsOn: DateTime.parse(json['starts_on'] as String),
        endsOn: json['ends_on'] == null
            ? null
            : DateTime.parse(json['ends_on'] as String),
        rolloverUnspent: json['rollover_unspent'] as bool,
        alertThresholds: ((json['alert_thresholds'] as List<dynamic>?) ??
                const <dynamic>[])
            .map((dynamic t) => (t as num).toInt())
            .toList(growable: false),
        isActive: json['is_active'] as bool,
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
        period,
        amount,
        categoryIds,
        accountIds,
        startsOn,
        endsOn,
        rolloverUnspent,
        alertThresholds,
        isActive,
        createdAt,
        updatedAt,
        deletedAt,
      ];
}
