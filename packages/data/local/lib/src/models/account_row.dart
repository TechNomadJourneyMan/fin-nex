import 'package:meta/meta.dart';

import '../database/sync_state.dart';
import '_helpers.dart';

/// Persisted shape of a single account in the local database.
@immutable
class AccountRow {
  /// Creates an immutable account row.
  const AccountRow({
    required this.id,
    required this.userId,
    required this.typeCode,
    required this.name,
    required this.currency,
    required this.clientId,
    required this.createdAt,
    required this.updatedAt,
    required this.syncState,
    required this.version,
    required this.dirty,
    this.balanceMinor = 0,
    this.initialBalanceMinor = 0,
    this.creditLimitMinor,
    this.bankCode,
    this.lastFour,
    this.color = '#1F8FFF',
    this.icon,
    this.isArchived = false,
    this.includeInTotal = true,
    this.sortOrder = 0,
    this.serverId,
    this.deletedAt,
    this.serverVersion,
    this.lastSyncedAt,
    this.deviceId,
  });

  /// Builds an [AccountRow] from a sqflite result map.
  factory AccountRow.fromMap(Map<String, Object?> m) => AccountRow(
        id: m['id']! as String,
        userId: m['user_id']! as String,
        typeCode: m['type_code']! as String,
        name: m['name']! as String,
        currency: m['currency']! as String,
        balanceMinor: m['balance_minor']! as int,
        initialBalanceMinor: m['initial_balance_minor']! as int,
        creditLimitMinor: m['credit_limit_minor'] as int?,
        bankCode: m['bank_code'] as String?,
        lastFour: m['last_four'] as String?,
        color: m['color'] as String? ?? '#1F8FFF',
        icon: m['icon'] as String?,
        isArchived: boolFromInt(m['is_archived']),
        includeInTotal: boolFromInt(m['include_in_total']),
        sortOrder: m['sort_order']! as int,
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

  /// Account type code (see `account_types` lookup).
  final String typeCode;

  /// Display name.
  final String name;

  /// ISO 4217 currency code.
  final String currency;

  /// Denormalised cached balance in minor units (recomputed from txs).
  final int balanceMinor;

  /// Opening balance in minor units.
  final int initialBalanceMinor;

  /// Credit limit (only meaningful for `credit_card`).
  final int? creditLimitMinor;

  /// Optional bank code (`kaspi`, `halyk`, ...).
  final String? bankCode;

  /// Last four digits for card-style accounts.
  final String? lastFour;

  /// Hex accent color.
  final String color;

  /// Optional icon key.
  final String? icon;

  /// Whether the account is archived (hidden from default lists).
  final bool isArchived;

  /// Whether the balance contributes to the user's total net worth.
  final bool includeInTotal;

  /// User-defined ordering within the account list.
  final int sortOrder;

  /// Client-generated ULID.
  final String clientId;

  /// Server-assigned ULID.
  final String? serverId;

  /// Row creation timestamp (UTC).
  final DateTime createdAt;

  /// Last local mutation timestamp (UTC).
  final DateTime updatedAt;

  /// Soft-delete marker.
  final DateTime? deletedAt;

  /// Sync state.
  final SyncState syncState;

  /// Lamport version counter.
  final int version;

  /// Last version confirmed by the server.
  final int? serverVersion;

  /// Last successful round-trip timestamp (UTC).
  final DateTime? lastSyncedAt;

  /// Whether the row has unpushed local changes.
  final bool dirty;

  /// Authoring device ULID.
  final String? deviceId;

  /// Serialises to a sqflite-friendly map.
  Map<String, Object?> toMap() => <String, Object?>{
        'id': id,
        'user_id': userId,
        'type_code': typeCode,
        'name': name,
        'currency': currency,
        'balance_minor': balanceMinor,
        'initial_balance_minor': initialBalanceMinor,
        'credit_limit_minor': creditLimitMinor,
        'bank_code': bankCode,
        'last_four': lastFour,
        'color': color,
        'icon': icon,
        'is_archived': boolToInt(isArchived),
        'include_in_total': boolToInt(includeInTotal),
        'sort_order': sortOrder,
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
}
