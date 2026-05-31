import 'package:meta/meta.dart';

import '../database/sync_state.dart';
import '_helpers.dart';

/// Persisted shape of a single transaction in the local database.
///
/// Mirrors the columns of the `transactions` table. All money values are
/// stored in minor units (tiyn / cents) as 64-bit integers — never doubles.
@immutable
class TransactionRow {
  /// Creates an immutable transaction row.
  const TransactionRow({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.typeCode,
    required this.amountMinor,
    required this.currency,
    required this.occurredAt,
    required this.clientId,
    required this.createdAt,
    required this.updatedAt,
    required this.syncState,
    required this.version,
    required this.dirty,
    this.categoryId,
    this.fxRate,
    this.amountPrimaryMinor,
    this.note,
    this.transferAccountId,
    this.transferGroupId,
    this.recurringRuleId,
    this.source = 'manual',
    this.externalRef,
    this.hasAttachment = false,
    this.lat,
    this.lng,
    this.serverId,
    this.deletedAt,
    this.serverVersion,
    this.lastSyncedAt,
    this.deviceId,
  });

  /// Builds a [TransactionRow] from a sqflite result map.
  factory TransactionRow.fromMap(Map<String, Object?> m) => TransactionRow(
        id: m['id']! as String,
        userId: m['user_id']! as String,
        accountId: m['account_id']! as String,
        typeCode: m['type_code']! as String,
        categoryId: m['category_id'] as String?,
        amountMinor: m['amount_minor']! as int,
        currency: m['currency']! as String,
        fxRate: (m['fx_rate'] as num?)?.toDouble(),
        amountPrimaryMinor: m['amount_primary_minor'] as int?,
        occurredAt: parseDate(m['occurred_at'])!,
        note: m['note'] as String?,
        transferAccountId: m['transfer_account_id'] as String?,
        transferGroupId: m['transfer_group_id'] as String?,
        recurringRuleId: m['recurring_rule_id'] as String?,
        source: m['source'] as String? ?? 'manual',
        externalRef: m['external_ref'] as String?,
        hasAttachment: boolFromInt(m['has_attachment']),
        lat: (m['lat'] as num?)?.toDouble(),
        lng: (m['lng'] as num?)?.toDouble(),
        clientId: m['client_id']! as String,
        serverId: m['server_id'] as String?,
        createdAt: parseDate(m['created_at'])!,
        updatedAt: parseDate(m['updated_at'])!,
        deletedAt: parseDate(m['deleted_at']),
        syncState: SyncState.fromString(m['sync_state'] as String?),
        version: m['version']! as int,
        serverVersion: m['server_version'] as int?,
        lastSyncedAt: parseDate(m['last_synced_at']),
        dirty: boolFromInt(m['dirty']),
        deviceId: m['device_id'] as String?,
      );

  /// ULID primary key.
  final String id;

  /// Owner user ULID.
  final String userId;

  /// Source account ULID.
  final String accountId;

  /// One of `expense`, `income`, `transfer`, `adjustment`.
  final String typeCode;

  /// Category ULID (`null` for `transfer` rows).
  final String? categoryId;

  /// Always non-negative; the sign is implied by [typeCode].
  final int amountMinor;

  /// ISO 4217 currency code (e.g. `KZT`).
  final String currency;

  /// FX rate to the user's primary currency. `null` when currencies match.
  final double? fxRate;

  /// Pre-computed amount in the user's primary currency, minor units.
  final int? amountPrimaryMinor;

  /// Wall-clock moment at which the transaction occurred (UTC).
  final DateTime occurredAt;

  /// Free-form user note.
  final String? note;

  /// Destination account ULID for transfers.
  final String? transferAccountId;

  /// Groups the debit/credit pair of a single logical transfer.
  final String? transferGroupId;

  /// FK to the recurring rule that materialised this transaction, if any.
  final String? recurringRuleId;

  /// Origin of the row (`manual`, `widget`, `recurring`, `import_csv`, ...).
  final String source;

  /// Idempotency reference from the source system (e.g. bank ref / SMS hash).
  final String? externalRef;

  /// Whether at least one attachment is linked to this transaction.
  final bool hasAttachment;

  /// Optional geo coordinates (opt-in).
  final double? lat;

  /// Optional geo coordinates (opt-in).
  final double? lng;

  /// ULID generated locally by the authoring device.
  final String clientId;

  /// Server-assigned ULID; `null` until first successful push.
  final String? serverId;

  /// Row creation timestamp (UTC).
  final DateTime createdAt;

  /// Last local mutation timestamp (UTC).
  final DateTime updatedAt;

  /// Soft-delete marker; `null` for live rows.
  final DateTime? deletedAt;

  /// Current state in the sync state machine.
  final SyncState syncState;

  /// Monotonic local version counter (Lamport-ish).
  final int version;

  /// Last version confirmed by the server.
  final int? serverVersion;

  /// Last successful round-trip timestamp (UTC).
  final DateTime? lastSyncedAt;

  /// Whether the row has unpushed local changes.
  final bool dirty;

  /// Device ULID that authored the last edit.
  final String? deviceId;

  /// Serialises this row to a sqflite-friendly map for insert/update calls.
  Map<String, Object?> toMap() => <String, Object?>{
        'id': id,
        'user_id': userId,
        'account_id': accountId,
        'type_code': typeCode,
        'category_id': categoryId,
        'amount_minor': amountMinor,
        'currency': currency,
        'fx_rate': fxRate,
        'amount_primary_minor': amountPrimaryMinor,
        'occurred_at': formatDate(occurredAt),
        'note': note,
        'transfer_account_id': transferAccountId,
        'transfer_group_id': transferGroupId,
        'recurring_rule_id': recurringRuleId,
        'source': source,
        'external_ref': externalRef,
        'has_attachment': boolToInt(hasAttachment),
        'lat': lat,
        'lng': lng,
        'client_id': clientId,
        'server_id': serverId,
        'created_at': formatDate(createdAt),
        'updated_at': formatDate(updatedAt),
        'deleted_at': formatDateOrNull(deletedAt),
        'sync_state': syncState.value,
        'version': version,
        'server_version': serverVersion,
        'last_synced_at': formatDateOrNull(lastSyncedAt),
        'dirty': boolToInt(dirty),
        'device_id': deviceId,
      };

  /// Returns a copy with the given fields replaced.
  TransactionRow copyWith({
    String? id,
    String? userId,
    String? accountId,
    String? typeCode,
    String? categoryId,
    int? amountMinor,
    String? currency,
    double? fxRate,
    int? amountPrimaryMinor,
    DateTime? occurredAt,
    String? note,
    String? transferAccountId,
    String? transferGroupId,
    String? recurringRuleId,
    String? source,
    String? externalRef,
    bool? hasAttachment,
    double? lat,
    double? lng,
    String? clientId,
    String? serverId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    SyncState? syncState,
    int? version,
    int? serverVersion,
    DateTime? lastSyncedAt,
    bool? dirty,
    String? deviceId,
  }) =>
      TransactionRow(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        accountId: accountId ?? this.accountId,
        typeCode: typeCode ?? this.typeCode,
        categoryId: categoryId ?? this.categoryId,
        amountMinor: amountMinor ?? this.amountMinor,
        currency: currency ?? this.currency,
        fxRate: fxRate ?? this.fxRate,
        amountPrimaryMinor: amountPrimaryMinor ?? this.amountPrimaryMinor,
        occurredAt: occurredAt ?? this.occurredAt,
        note: note ?? this.note,
        transferAccountId: transferAccountId ?? this.transferAccountId,
        transferGroupId: transferGroupId ?? this.transferGroupId,
        recurringRuleId: recurringRuleId ?? this.recurringRuleId,
        source: source ?? this.source,
        externalRef: externalRef ?? this.externalRef,
        hasAttachment: hasAttachment ?? this.hasAttachment,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        clientId: clientId ?? this.clientId,
        serverId: serverId ?? this.serverId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt ?? this.deletedAt,
        syncState: syncState ?? this.syncState,
        version: version ?? this.version,
        serverVersion: serverVersion ?? this.serverVersion,
        lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
        dirty: dirty ?? this.dirty,
        deviceId: deviceId ?? this.deviceId,
      );
}
