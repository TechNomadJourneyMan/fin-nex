import 'dart:convert';

import 'package:meta/meta.dart';

import '../database/sync_state.dart';
import '_helpers.dart';

/// Persisted shape of a single budget row.
@immutable
class BudgetRow {
  /// Creates an immutable budget row.
  const BudgetRow({
    required this.id,
    required this.userId,
    required this.name,
    required this.periodCode,
    required this.amountMinor,
    required this.currency,
    required this.startsOn,
    required this.clientId,
    required this.createdAt,
    required this.updatedAt,
    required this.syncState,
    required this.version,
    required this.dirty,
    this.scope = 'category',
    this.categoryIds = const <String>[],
    this.accountIds = const <String>[],
    this.endsOn,
    this.rolloverUnspent = false,
    this.alertAtPercent = 80,
    this.isActive = true,
    this.serverId,
    this.deletedAt,
    this.serverVersion,
    this.lastSyncedAt,
    this.deviceId,
  });

  /// Builds a [BudgetRow] from a sqflite result map.
  factory BudgetRow.fromMap(Map<String, Object?> m) => BudgetRow(
        id: m['id']! as String,
        userId: m['user_id']! as String,
        name: m['name']! as String,
        periodCode: m['period_code']! as String,
        amountMinor: m['amount_minor']! as int,
        currency: m['currency']! as String,
        scope: m['scope'] as String? ?? 'category',
        categoryIds: _parseIdList(m['category_ids'] as String?),
        accountIds: _parseIdList(m['account_ids'] as String?),
        startsOn: parseDate(m['starts_on'])!,
        endsOn: parseDate(m['ends_on']),
        rolloverUnspent: boolFromInt(m['rollover_unspent']),
        alertAtPercent: m['alert_at_percent']! as int,
        isActive: boolFromInt(m['is_active']),
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

  static List<String> _parseIdList(String? raw) {
    if (raw == null || raw.isEmpty) return const <String>[];
    final decoded = jsonDecode(raw);
    if (decoded is List) return decoded.cast<String>();
    return const <String>[];
  }

  /// ULID primary key.
  final String id;

  /// Owner user ULID.
  final String userId;

  /// Display name (e.g. "Monthly groceries").
  final String name;

  /// `weekly` | `monthly` | `quarterly` | `yearly` | `custom`.
  final String periodCode;

  /// Budgeted amount in minor units.
  final int amountMinor;

  /// ISO 4217 currency code.
  final String currency;

  /// `category` | `account` | `total`.
  final String scope;

  /// Categories tracked by this budget (JSON list of ULIDs).
  final List<String> categoryIds;

  /// Accounts tracked by this budget (JSON list of ULIDs).
  final List<String> accountIds;

  /// First date of the budget period (UTC).
  final DateTime startsOn;

  /// Last date of the budget period (UTC), if bounded.
  final DateTime? endsOn;

  /// True for envelope-style rollover of unspent amounts.
  final bool rolloverUnspent;

  /// Threshold (percent) at which the user is alerted.
  final int alertAtPercent;

  /// True while the budget is in effect.
  final bool isActive;

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
        'name': name,
        'period_code': periodCode,
        'amount_minor': amountMinor,
        'currency': currency,
        'scope': scope,
        'category_ids': jsonEncode(categoryIds),
        'account_ids': jsonEncode(accountIds),
        'starts_on': formatDate(startsOn),
        'ends_on': formatDateOrNull(endsOn),
        'rollover_unspent': boolToInt(rolloverUnspent),
        'alert_at_percent': alertAtPercent,
        'is_active': boolToInt(isActive),
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
