/// A single change record sent to `/sync/push`.
class SyncChangeDto {
  /// Default constructor.
  const SyncChangeDto({
    required this.entity,
    required this.op,
    required this.clientUpdatedAt,
    required this.clientRevision,
    this.id,
    this.clientId,
    this.payload = const <String, dynamic>{},
  });

  /// Logical entity (`transaction`, `account`, ...).
  final String entity;

  /// `create | update | delete`.
  final String op;

  /// Server id when known.
  final String? id;

  /// Client-generated id for new rows.
  final String? clientId;

  /// Client-side last edit time (UTC).
  final DateTime clientUpdatedAt;

  /// Per-row client revision counter.
  final int clientRevision;

  /// Payload (entity-specific).
  final Map<String, dynamic> payload;

  /// Parse from JSON.
  factory SyncChangeDto.fromJson(Map<String, dynamic> json) => SyncChangeDto(
        entity: json['entity'] as String,
        op: json['op'] as String,
        id: json['id'] as String?,
        clientId: json['client_id'] as String?,
        clientUpdatedAt: DateTime.parse(json['client_updated_at'] as String),
        clientRevision: (json['client_revision'] as num?)?.toInt() ?? 0,
        payload: (json['payload'] as Map<String, dynamic>?) ??
            const <String, dynamic>{},
      );

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'entity': entity,
        'op': op,
        if (id != null) 'id': id,
        if (clientId != null) 'client_id': clientId,
        'client_updated_at': clientUpdatedAt.toUtc().toIso8601String(),
        'client_revision': clientRevision,
        'payload': payload,
      };
}

/// `POST /sync/push` body.
class PushRequest {
  /// Default constructor.
  const PushRequest({
    required this.deviceId,
    required this.lastKnownServerRevision,
    required this.changes,
  });

  /// Originating device id.
  final String deviceId;

  /// Server revision the client believes is current.
  final int lastKnownServerRevision;

  /// Batched changes.
  final List<SyncChangeDto> changes;

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'device_id': deviceId,
        'last_known_server_revision': lastKnownServerRevision,
        'changes': changes
            .map((SyncChangeDto e) => e.toJson())
            .toList(growable: false),
      };
}

/// A conflict raised during push.
class SyncConflictDto {
  /// Default constructor.
  const SyncConflictDto({
    this.clientId,
    this.serverId,
    required this.reason,
    this.serverPayload = const <String, dynamic>{},
  });

  /// Client id of the conflicting row.
  final String? clientId;

  /// Server id of the conflicting row.
  final String? serverId;

  /// Reason code (e.g. `stale_revision`).
  final String reason;

  /// Authoritative server payload.
  final Map<String, dynamic> serverPayload;

  /// Parse from JSON.
  factory SyncConflictDto.fromJson(Map<String, dynamic> json) =>
      SyncConflictDto(
        clientId: json['client_id'] as String?,
        serverId: json['server_id'] as String?,
        reason: (json['reason'] ?? 'unknown') as String,
        serverPayload: (json['server_payload'] as Map<String, dynamic>?) ??
            const <String, dynamic>{},
      );

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        if (clientId != null) 'client_id': clientId,
        if (serverId != null) 'server_id': serverId,
        'reason': reason,
        'server_payload': serverPayload,
      };
}

/// A rejected row from push.
class SyncRejectionDto {
  /// Default constructor.
  const SyncRejectionDto({
    this.clientId,
    required this.code,
    required this.detail,
  });

  /// Client id.
  final String? clientId;

  /// Error code.
  final String code;

  /// Detail.
  final String detail;

  /// Parse from JSON.
  factory SyncRejectionDto.fromJson(Map<String, dynamic> json) =>
      SyncRejectionDto(
        clientId: json['client_id'] as String?,
        code: json['code'] as String,
        detail: (json['detail'] ?? '') as String,
      );

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        if (clientId != null) 'client_id': clientId,
        'code': code,
        'detail': detail,
      };
}

/// Maps a client-generated id to the server-assigned one.
class SyncMappingDto {
  /// Default constructor.
  const SyncMappingDto({required this.clientId, required this.serverId});

  /// Client id (`ctx_...`).
  final String clientId;

  /// Server id (`tx_...`, etc.).
  final String serverId;

  /// Parse from JSON.
  factory SyncMappingDto.fromJson(Map<String, dynamic> json) => SyncMappingDto(
        clientId: json['client_id'] as String,
        serverId: json['server_id'] as String,
      );

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'client_id': clientId,
        'server_id': serverId,
      };
}

/// `POST /sync/push` response.
class PushResponse {
  /// Default constructor.
  const PushResponse({
    required this.accepted,
    required this.serverRevision,
    this.conflicts = const <SyncConflictDto>[],
    this.rejected = const <SyncRejectionDto>[],
    this.mappings = const <SyncMappingDto>[],
  });

  /// Count of accepted changes.
  final int accepted;

  /// New server revision after applying the batch.
  final int serverRevision;

  /// Conflicts requiring client-side resolution.
  final List<SyncConflictDto> conflicts;

  /// Rejected rows.
  final List<SyncRejectionDto> rejected;

  /// Client → server id mappings for newly created rows.
  final List<SyncMappingDto> mappings;

  /// Parse from JSON.
  factory PushResponse.fromJson(Map<String, dynamic> json) => PushResponse(
        accepted: (json['accepted'] as num?)?.toInt() ?? 0,
        serverRevision: (json['server_revision'] as num?)?.toInt() ?? 0,
        conflicts: ((json['conflicts'] as List<dynamic>?) ?? const <dynamic>[])
            .map((dynamic e) =>
                SyncConflictDto.fromJson(e as Map<String, dynamic>))
            .toList(growable: false),
        rejected: ((json['rejected'] as List<dynamic>?) ?? const <dynamic>[])
            .map((dynamic e) =>
                SyncRejectionDto.fromJson(e as Map<String, dynamic>))
            .toList(growable: false),
        mappings: ((json['mappings'] as List<dynamic>?) ?? const <dynamic>[])
            .map((dynamic e) =>
                SyncMappingDto.fromJson(e as Map<String, dynamic>))
            .toList(growable: false),
      );

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'accepted': accepted,
        'server_revision': serverRevision,
        'conflicts': conflicts
            .map((SyncConflictDto e) => e.toJson())
            .toList(growable: false),
        'rejected': rejected
            .map((SyncRejectionDto e) => e.toJson())
            .toList(growable: false),
        'mappings': mappings
            .map((SyncMappingDto e) => e.toJson())
            .toList(growable: false),
      };
}

/// A remote change retrieved from `/sync/pull`.
class PullChangeDto {
  /// Default constructor.
  const PullChangeDto({
    required this.entity,
    required this.op,
    required this.serverRevision,
    this.id,
    this.data = const <String, dynamic>{},
    this.deletedAt,
  });

  /// Logical entity.
  final String entity;

  /// `upsert | delete`.
  final String op;

  /// Server revision when the change was applied.
  final int serverRevision;

  /// Entity id (for delete ops).
  final String? id;

  /// Entity payload (for upsert).
  final Map<String, dynamic> data;

  /// Delete timestamp.
  final DateTime? deletedAt;

  /// Parse from JSON.
  factory PullChangeDto.fromJson(Map<String, dynamic> json) => PullChangeDto(
        entity: json['entity'] as String,
        op: json['op'] as String,
        serverRevision: (json['server_revision'] as num?)?.toInt() ?? 0,
        id: json['id'] as String?,
        data: (json['data'] as Map<String, dynamic>?) ??
            const <String, dynamic>{},
        deletedAt: json['deleted_at'] is String
            ? DateTime.parse(json['deleted_at'] as String)
            : null,
      );

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'entity': entity,
        'op': op,
        'server_revision': serverRevision,
        if (id != null) 'id': id,
        if (data.isNotEmpty) 'data': data,
        if (deletedAt != null)
          'deleted_at': deletedAt!.toUtc().toIso8601String(),
      };
}

/// `GET /sync/pull` response.
class PullResponse {
  /// Default constructor.
  const PullResponse({
    required this.changes,
    required this.serverRevision,
    required this.serverTime,
    this.nextCursor,
    this.hasMore = false,
  });

  /// Remote changes since the requested revision.
  final List<PullChangeDto> changes;

  /// Authoritative server revision at response time.
  final int serverRevision;

  /// Server clock when the response was generated.
  final DateTime serverTime;

  /// Cursor for the next page.
  final String? nextCursor;

  /// Whether more pages remain.
  final bool hasMore;

  /// Parse from JSON.
  factory PullResponse.fromJson(Map<String, dynamic> json) => PullResponse(
        changes: ((json['changes'] as List<dynamic>?) ?? const <dynamic>[])
            .map((dynamic e) =>
                PullChangeDto.fromJson(e as Map<String, dynamic>))
            .toList(growable: false),
        serverRevision: (json['server_revision'] as num?)?.toInt() ?? 0,
        serverTime: json['server_time'] is String
            ? DateTime.parse(json['server_time'] as String)
            : DateTime.now().toUtc(),
        nextCursor: json['next_cursor'] as String?,
        hasMore: (json['has_more'] as bool?) ?? false,
      );

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'changes': changes
            .map((PullChangeDto e) => e.toJson())
            .toList(growable: false),
        'server_revision': serverRevision,
        'server_time': serverTime.toUtc().toIso8601String(),
        if (nextCursor != null) 'next_cursor': nextCursor,
        'has_more': hasMore,
      };
}
