import 'package:meta/meta.dart';

import '../database/sync_state.dart';
import '_helpers.dart';

/// Persisted shape of a single category in the local database.
@immutable
class CategoryRow {
  /// Creates an immutable category row.
  const CategoryRow({
    required this.id,
    required this.typeCode,
    required this.name,
    required this.icon,
    required this.clientId,
    required this.createdAt,
    required this.updatedAt,
    required this.syncState,
    required this.version,
    required this.dirty,
    this.userId,
    this.parentId,
    this.nameI18nKey,
    this.color = '#888888',
    this.isSystem = false,
    this.isArchived = false,
    this.sortOrder = 0,
    this.monthlyLimitMinor,
    this.bucket,
    this.isEssential = false,
    this.serverId,
    this.deletedAt,
    this.serverVersion,
    this.lastSyncedAt,
    this.deviceId,
  });

  /// Builds a [CategoryRow] from a sqflite result map.
  factory CategoryRow.fromMap(Map<String, Object?> m) => CategoryRow(
        id: m['id']! as String,
        userId: m['user_id'] as String?,
        typeCode: m['type_code']! as String,
        parentId: m['parent_id'] as String?,
        name: m['name']! as String,
        nameI18nKey: m['name_i18n_key'] as String?,
        icon: m['icon']! as String,
        color: m['color'] as String? ?? '#888888',
        isSystem: boolFromInt(m['is_system']),
        isArchived: boolFromInt(m['is_archived']),
        sortOrder: m['sort_order']! as int,
        monthlyLimitMinor: m['monthly_limit_minor'] as int?,
        bucket: m['bucket'] as String?,
        isEssential: boolFromInt(m['is_essential']),
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

  /// Owner user ULID; `null` for system categories.
  final String? userId;

  /// `expense`, `income`, `transfer`, or `adjustment`.
  final String typeCode;

  /// Parent category ULID for subcategories.
  final String? parentId;

  /// Display name (localised label for custom; canonical Russian for system).
  final String name;

  /// i18n key for system categories (e.g. `category.food_groceries`).
  final String? nameI18nKey;

  /// Icon key (Material/SF symbol name).
  final String icon;

  /// Hex accent color.
  final String color;

  /// True for built-in system categories (cannot be deleted).
  final bool isSystem;

  /// True if hidden from default pickers.
  final bool isArchived;

  /// Sort order within its kind.
  final int sortOrder;

  /// Optional inline monthly soft-limit in minor units.
  final int? monthlyLimitMinor;

  /// 50/30/20 bucket: `needs`, `wants`, `savings`, or `neutral`.
  final String? bucket;

  /// True if this category counts toward the Essentials ratio metric.
  final bool isEssential;

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
        'parent_id': parentId,
        'name': name,
        'name_i18n_key': nameI18nKey,
        'icon': icon,
        'color': color,
        'is_system': boolToInt(isSystem),
        'is_archived': boolToInt(isArchived),
        'sort_order': sortOrder,
        'monthly_limit_minor': monthlyLimitMinor,
        'bucket': bucket,
        'is_essential': boolToInt(isEssential),
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
