import 'package:meta/meta.dart';

import '_helpers.dart';

/// Operation a queued sync entry should apply on the server.
enum SyncOp {
  /// Insert-or-update the entity.
  upsert('upsert'),

  /// Soft-delete or hard-delete the entity.
  delete('delete');

  const SyncOp(this.value);

  /// String form persisted in `sync_queue.op`.
  final String value;

  /// Parse a string into [SyncOp], defaulting to [upsert].
  static SyncOp fromString(String? raw) {
    for (final v in SyncOp.values) {
      if (v.value == raw) return v;
    }
    return SyncOp.upsert;
  }
}

/// Lifecycle status of a sync queue entry.
enum SyncQueueStatus {
  /// Awaiting next sync attempt.
  pending('pending'),

  /// Currently being pushed.
  inFlight('in_flight'),

  /// Successfully pushed and acknowledged.
  done('done'),

  /// Permanent failure; will not auto-retry.
  failedPermanent('failed_permanent');

  const SyncQueueStatus(this.value);

  /// String form persisted in `sync_queue.status`.
  final String value;

  /// Parse a string into [SyncQueueStatus], defaulting to [pending].
  static SyncQueueStatus fromString(String? raw) {
    for (final v in SyncQueueStatus.values) {
      if (v.value == raw) return v;
    }
    return SyncQueueStatus.pending;
  }
}

/// A single pending outbox entry in the local sync queue.
@immutable
class SyncQueueRow {
  /// Creates an immutable sync-queue row.
  const SyncQueueRow({
    required this.entityTable,
    required this.entityId,
    required this.op,
    required this.payload,
    required this.enqueuedAt,
    this.id,
    this.attempts = 0,
    this.lastAttemptAt,
    this.lastError,
    this.status = SyncQueueStatus.pending,
  });

  /// Builds a [SyncQueueRow] from a sqflite result map.
  factory SyncQueueRow.fromMap(Map<String, Object?> m) => SyncQueueRow(
        id: m['id'] as int?,
        entityTable: m['entity_table']! as String,
        entityId: m['entity_id']! as String,
        op: SyncOp.fromString(m['op'] as String?),
        payload: m['payload']! as String,
        enqueuedAt: parseDate(m['enqueued_at'])!,
        attempts: m['attempts']! as int,
        lastAttemptAt: parseDate(m['last_attempt_at']),
        lastError: m['last_error'] as String?,
        status: SyncQueueStatus.fromString(m['status'] as String?),
      );

  /// Autoincrement primary key (null until inserted).
  final int? id;

  /// Target entity table name (e.g. `transactions`).
  final String entityTable;

  /// Entity client ULID.
  final String entityId;

  /// Operation to apply.
  final SyncOp op;

  /// JSON-encoded entity snapshot.
  final String payload;

  /// Enqueue timestamp (UTC).
  final DateTime enqueuedAt;

  /// Number of attempts so far.
  final int attempts;

  /// Last attempt timestamp (UTC), if any.
  final DateTime? lastAttemptAt;

  /// Error message from the last failed attempt.
  final String? lastError;

  /// Current lifecycle status.
  final SyncQueueStatus status;

  /// Serialises to a sqflite-friendly map. The `id` is omitted when null so
  /// that sqflite will auto-assign one.
  Map<String, Object?> toMap() => <String, Object?>{
        if (id != null) 'id': id,
        'entity_table': entityTable,
        'entity_id': entityId,
        'op': op.value,
        'payload': payload,
        'enqueued_at': formatDate(enqueuedAt),
        'attempts': attempts,
        'last_attempt_at': formatDateOrNull(lastAttemptAt),
        'last_error': lastError,
        'status': status.value,
      };
}
