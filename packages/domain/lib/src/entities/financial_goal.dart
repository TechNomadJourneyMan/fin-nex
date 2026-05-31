import 'package:equatable/equatable.dart';

import '../values/money.dart';
import '../values/ulid.dart';

/// A savings goal that tracks progress toward a target amount.
///
/// Progress may be tracked manually (by editing [currentAmount]) or derived
/// from a [linkedAccountId] whose balance is mirrored into [currentAmount] via
/// `recomputeProgress`.
final class FinancialGoal extends Equatable {
  /// Default constructor.
  const FinancialGoal({
    required this.id,
    required this.userId,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.iconKey,
    required this.colorHex,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
    this.targetDate,
    this.linkedAccountId,
    this.deletedAt,
  });

  /// ULID primary key.
  final Ulid id;

  /// Owning user.
  final Ulid userId;

  /// User-supplied goal name (e.g. "Emergency fund").
  final String name;

  /// Amount the user is saving toward.
  final Money targetAmount;

  /// Amount saved so far. Mirrors the linked account balance when present.
  final Money currentAmount;

  /// Optional date by which the user wants to hit [targetAmount].
  final DateTime? targetDate;

  /// Iconography key (e.g. `flight`, `home`, `car`).
  final String iconKey;

  /// Accent color as `#RRGGBB`.
  final String colorHex;

  /// Optional account whose balance feeds [currentAmount].
  final Ulid? linkedAccountId;

  /// Whether the goal has been reached / marked done.
  final bool isCompleted;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Last update timestamp.
  final DateTime updatedAt;

  /// Soft-delete timestamp; non-null means in trash.
  final DateTime? deletedAt;

  /// Fraction of the target reached, clamped to `[0, 1]`.
  ///
  /// Returns `0` when [targetAmount] is zero to avoid division by zero.
  double get progress {
    if (targetAmount.minor == BigInt.zero) return 0;
    final ratio = currentAmount.minor / targetAmount.minor;
    if (ratio.isNaN || ratio < 0) return 0;
    if (ratio > 1) return 1;
    return ratio;
  }

  /// Amount still needed to reach [targetAmount]; never negative.
  Money get remaining {
    final diff = targetAmount - currentAmount;
    return diff.isNegative ? Money.zero(targetAmount.currency) : diff;
  }

  /// Returns a copy with the given fields replaced.
  ///
  /// Pass [clearTargetDate] / [clearLinkedAccountId] to explicitly null out
  /// the optional fields (a `null` argument is treated as "keep existing").
  FinancialGoal copyWith({
    Ulid? id,
    Ulid? userId,
    String? name,
    Money? targetAmount,
    Money? currentAmount,
    DateTime? targetDate,
    String? iconKey,
    String? colorHex,
    Ulid? linkedAccountId,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearTargetDate = false,
    bool clearLinkedAccountId = false,
  }) =>
      FinancialGoal(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        targetAmount: targetAmount ?? this.targetAmount,
        currentAmount: currentAmount ?? this.currentAmount,
        targetDate: clearTargetDate ? null : (targetDate ?? this.targetDate),
        iconKey: iconKey ?? this.iconKey,
        colorHex: colorHex ?? this.colorHex,
        linkedAccountId: clearLinkedAccountId
            ? null
            : (linkedAccountId ?? this.linkedAccountId),
        isCompleted: isCompleted ?? this.isCompleted,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt ?? this.deletedAt,
      );

  /// Serializes to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id.value,
        'user_id': userId.value,
        'name': name,
        'target_amount': targetAmount.toJson(),
        'current_amount': currentAmount.toJson(),
        'target_date': targetDate?.toUtc().toIso8601String(),
        'icon_key': iconKey,
        'color_hex': colorHex,
        'linked_account_id': linkedAccountId?.value,
        'is_completed': isCompleted,
        'created_at': createdAt.toUtc().toIso8601String(),
        'updated_at': updatedAt.toUtc().toIso8601String(),
        'deleted_at': deletedAt?.toUtc().toIso8601String(),
      };

  /// Reconstructs from JSON.
  factory FinancialGoal.fromJson(Map<String, dynamic> json) => FinancialGoal(
        id: Ulid(json['id'] as String),
        userId: Ulid(json['user_id'] as String),
        name: json['name'] as String,
        targetAmount:
            Money.fromJson(json['target_amount'] as Map<String, dynamic>),
        currentAmount:
            Money.fromJson(json['current_amount'] as Map<String, dynamic>),
        targetDate: json['target_date'] == null
            ? null
            : DateTime.parse(json['target_date'] as String),
        iconKey: json['icon_key'] as String,
        colorHex: json['color_hex'] as String,
        linkedAccountId: json['linked_account_id'] == null
            ? null
            : Ulid(json['linked_account_id'] as String),
        isCompleted: json['is_completed'] as bool,
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
        targetAmount,
        currentAmount,
        targetDate,
        iconKey,
        colorHex,
        linkedAccountId,
        isCompleted,
        createdAt,
        updatedAt,
        deletedAt,
      ];
}
