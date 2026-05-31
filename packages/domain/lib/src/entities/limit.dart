import 'package:equatable/equatable.dart';

import '../values/money.dart';
import '../values/ulid.dart';
import 'enums.dart';

/// A defensive spending guard. Unlike a [Budget], a [Limit] escalates with
/// [severity] when exceeded.
final class Limit extends Equatable {
  /// Default constructor.
  const Limit({
    required this.id,
    required this.userId,
    required this.name,
    required this.scope,
    required this.period,
    required this.amount,
    required this.severity,
    required this.alertAtPercent,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.scopeRefId,
    this.deletedAt,
  });

  /// ULID primary key.
  final Ulid id;

  /// Owning user.
  final Ulid userId;

  /// User-visible name.
  final String name;

  /// Scope tag: `category` | `tag` | `account` | `merchant` | `total`.
  final String scope;

  /// Optional reference (ULID of the scoped entity).
  final Ulid? scopeRefId;

  /// Reset cadence.
  final BudgetPeriod period;

  /// Cap amount.
  final Money amount;

  /// Reaction severity when crossed.
  final LimitSeverity severity;

  /// Percentage at which a pre-warning fires (e.g. 80).
  final int alertAtPercent;

  /// Activation flag.
  final bool isActive;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Last update timestamp.
  final DateTime updatedAt;

  /// Soft-delete timestamp.
  final DateTime? deletedAt;

  /// Returns a copy with the given fields replaced.
  Limit copyWith({
    Ulid? id,
    Ulid? userId,
    String? name,
    String? scope,
    Ulid? scopeRefId,
    BudgetPeriod? period,
    Money? amount,
    LimitSeverity? severity,
    int? alertAtPercent,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) =>
      Limit(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        scope: scope ?? this.scope,
        scopeRefId: scopeRefId ?? this.scopeRefId,
        period: period ?? this.period,
        amount: amount ?? this.amount,
        severity: severity ?? this.severity,
        alertAtPercent: alertAtPercent ?? this.alertAtPercent,
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
        'scope': scope,
        'scope_ref_id': scopeRefId?.value,
        'period_code': period.code,
        'amount': amount.toJson(),
        'severity': severity.code,
        'alert_at_percent': alertAtPercent,
        'is_active': isActive,
        'created_at': createdAt.toUtc().toIso8601String(),
        'updated_at': updatedAt.toUtc().toIso8601String(),
        'deleted_at': deletedAt?.toUtc().toIso8601String(),
      };

  /// Reconstructs from JSON.
  factory Limit.fromJson(Map<String, dynamic> json) => Limit(
        id: Ulid(json['id'] as String),
        userId: Ulid(json['user_id'] as String),
        name: json['name'] as String,
        scope: json['scope'] as String,
        scopeRefId: json['scope_ref_id'] == null
            ? null
            : Ulid(json['scope_ref_id'] as String),
        period: BudgetPeriod.parse(json['period_code'] as String),
        amount: Money.fromJson(json['amount'] as Map<String, dynamic>),
        severity: LimitSeverity.parse(json['severity'] as String),
        alertAtPercent: (json['alert_at_percent'] as num).toInt(),
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
        scope,
        scopeRefId,
        period,
        amount,
        severity,
        alertAtPercent,
        isActive,
        createdAt,
        updatedAt,
        deletedAt,
      ];
}
