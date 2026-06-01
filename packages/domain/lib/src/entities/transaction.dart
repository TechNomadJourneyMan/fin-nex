import 'package:equatable/equatable.dart';

import '../values/money.dart';
import '../values/ulid.dart';
import 'enums.dart';

/// A single ledger entry — expense, income, transfer leg, or adjustment.
final class Transaction extends Equatable {
  /// Default constructor.
  const Transaction({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.type,
    required this.amount,
    required this.occurredAt,
    required this.createdAt,
    required this.updatedAt,
    required this.source,
    required this.attachmentIds,
    required this.tagIds,
    this.categoryId,
    this.description,
    this.transferAccountId,
    this.transferGroupId,
    this.recurringRuleId,
    this.externalRef,
    this.lat,
    this.lng,
    this.deletedAt,
  });

  /// ULID primary key.
  final Ulid id;

  /// Owning user.
  final Ulid userId;

  /// Source account.
  final Ulid accountId;

  /// Kind of entry.
  final TransactionType type;

  /// Positive money amount; the sign is implied by [type].
  final Money amount;

  /// Category; required for expense/income, null for transfer/adjustment.
  final Ulid? categoryId;

  /// When the transaction actually occurred (user-editable).
  final DateTime occurredAt;

  /// Optional user-facing note.
  final String? description;

  /// Counterpart account for transfers.
  final Ulid? transferAccountId;

  /// Links the debit + credit halves of a transfer.
  final Ulid? transferGroupId;

  /// Recurring rule that generated this transaction.
  final Ulid? recurringRuleId;

  /// Origin: `manual`, `widget`, `recurring`, `import_csv`, …
  final String source;

  /// External de-dup reference (bank ref / QR id / SMS hash).
  final String? externalRef;

  /// Optional lat-lng captured at creation.
  final double? lat;

  /// Optional lng.
  final double? lng;

  /// Attachment ULIDs linked to this transaction.
  final List<Ulid> attachmentIds;

  /// Tag ULIDs linked to this transaction.
  final List<Ulid> tagIds;

  /// Creation timestamp (immutable bookkeeping).
  final DateTime createdAt;

  /// Last edit timestamp.
  final DateTime updatedAt;

  /// Soft-delete timestamp.
  final DateTime? deletedAt;

  /// Returns a copy with the given fields replaced.
  Transaction copyWith({
    Ulid? id,
    Ulid? userId,
    Ulid? accountId,
    TransactionType? type,
    Money? amount,
    Ulid? categoryId,
    DateTime? occurredAt,
    String? description,
    Ulid? transferAccountId,
    Ulid? transferGroupId,
    Ulid? recurringRuleId,
    String? source,
    String? externalRef,
    double? lat,
    double? lng,
    List<Ulid>? attachmentIds,
    List<Ulid>? tagIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) =>
      Transaction(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        accountId: accountId ?? this.accountId,
        type: type ?? this.type,
        amount: amount ?? this.amount,
        categoryId: categoryId ?? this.categoryId,
        occurredAt: occurredAt ?? this.occurredAt,
        description: description ?? this.description,
        transferAccountId: transferAccountId ?? this.transferAccountId,
        transferGroupId: transferGroupId ?? this.transferGroupId,
        recurringRuleId: recurringRuleId ?? this.recurringRuleId,
        source: source ?? this.source,
        externalRef: externalRef ?? this.externalRef,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        attachmentIds: attachmentIds ?? this.attachmentIds,
        tagIds: tagIds ?? this.tagIds,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt ?? this.deletedAt,
      );

  /// Serializes to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id.value,
        'user_id': userId.value,
        'account_id': accountId.value,
        'type_code': type.code,
        'amount': amount.toJson(),
        'category_id': categoryId?.value,
        'occurred_at': occurredAt.toUtc().toIso8601String(),
        'description': description,
        'transfer_account_id': transferAccountId?.value,
        'transfer_group_id': transferGroupId?.value,
        'recurring_rule_id': recurringRuleId?.value,
        'source': source,
        'external_ref': externalRef,
        'lat': lat,
        'lng': lng,
        'attachment_ids':
            attachmentIds.map((Ulid id) => id.value).toList(growable: false),
        'tag_ids': tagIds.map((Ulid id) => id.value).toList(growable: false),
        'created_at': createdAt.toUtc().toIso8601String(),
        'updated_at': updatedAt.toUtc().toIso8601String(),
        'deleted_at': deletedAt?.toUtc().toIso8601String(),
      };

  /// Reconstructs from JSON.
  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: Ulid(json['id'] as String),
        userId: Ulid(json['user_id'] as String),
        accountId: Ulid(json['account_id'] as String),
        type: TransactionType.parse(json['type_code'] as String),
        amount: Money.fromJson(json['amount'] as Map<String, dynamic>),
        categoryId: json['category_id'] == null
            ? null
            : Ulid(json['category_id'] as String),
        occurredAt: DateTime.parse(json['occurred_at'] as String),
        description: json['description'] as String?,
        transferAccountId: json['transfer_account_id'] == null
            ? null
            : Ulid(json['transfer_account_id'] as String),
        transferGroupId: json['transfer_group_id'] == null
            ? null
            : Ulid(json['transfer_group_id'] as String),
        recurringRuleId: json['recurring_rule_id'] == null
            ? null
            : Ulid(json['recurring_rule_id'] as String),
        source: json['source'] as String,
        externalRef: json['external_ref'] as String?,
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
        attachmentIds:
            ((json['attachment_ids'] as List<dynamic>?) ?? const <dynamic>[])
                .map((dynamic id) => Ulid(id as String))
                .toList(growable: false),
        tagIds: ((json['tag_ids'] as List<dynamic>?) ?? const <dynamic>[])
            .map((dynamic id) => Ulid(id as String))
            .toList(growable: false),
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
        accountId,
        type,
        amount,
        categoryId,
        occurredAt,
        description,
        transferAccountId,
        transferGroupId,
        recurringRuleId,
        source,
        externalRef,
        lat,
        lng,
        attachmentIds,
        tagIds,
        createdAt,
        updatedAt,
        deletedAt,
      ];
}
