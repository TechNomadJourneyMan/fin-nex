import 'package:fnx_data_local/fnx_data_local.dart';
import 'package:fnx_domain/fnx_domain.dart';
import 'package:meta/meta.dart';

import 'result.dart';

/// Status of a single outbox row after a push attempt.
enum PushOutcome {
  /// Server accepted the change.
  accepted,

  /// Server detected a conflict (e.g. stale version).
  conflict,

  /// Server permanently rejected the change (4xx other than 429).
  rejected,

  /// Transient failure (network / 5xx / 429) — retry later.
  retry,
}

/// Result of pushing a single outbox row.
@immutable
class PushAck {
  /// Default const ctor.
  const PushAck({
    required this.outcome,
    this.serverId,
    this.serverVersion,
    this.error,
  });

  /// Outcome category.
  final PushOutcome outcome;

  /// Server-assigned ULID, if the server allocated one.
  final String? serverId;

  /// Server-side version counter after the apply.
  final int? serverVersion;

  /// Diagnostic message when [outcome] is not [PushOutcome.accepted].
  final String? error;
}

/// Snapshot of a row pulled from the server.
@immutable
class RemoteEntity {
  /// Default const ctor.
  const RemoteEntity({
    required this.entityTable,
    required this.serverId,
    required this.serverVersion,
    required this.updatedAt,
    required this.payload,
    this.deletedAt,
  });

  /// Logical table the entity belongs to (e.g. `transactions`).
  final String entityTable;

  /// Server-assigned ULID.
  final String serverId;

  /// Server-side version after this change.
  final int serverVersion;

  /// Server-side last mutation timestamp (UTC).
  final DateTime updatedAt;

  /// Soft-delete marker; non-null when the server tombstoned the row.
  final DateTime? deletedAt;

  /// Raw JSON-decoded payload of the entity.
  final Map<String, Object?> payload;
}

/// Page of pull results from the server.
@immutable
class PullPage {
  /// Default const ctor.
  const PullPage({
    required this.entities,
    required this.nextCursor,
    this.hasMore = false,
  });

  /// Returned entities for this page.
  final List<RemoteEntity> entities;

  /// Opaque cursor to fetch the next page. `null` when fully drained.
  final String? nextCursor;

  /// Whether more pages remain after this one.
  final bool hasMore;
}

/// Abstract REST-style contract the sync engine talks to.
///
/// The concrete implementation lives in `fnx_data_api` (Dio + retrofit-style).
/// Keeping the engine decoupled lets us inject in-memory fakes for tests.
abstract class SyncService {
  /// Push a batch of outbox rows; the response is one [PushAck] per input row
  /// in the same order.
  Future<Result<List<PushAck>, Failure>> push(List<SyncQueueRow> batch);

  /// Pull a page of server changes for [entityTable] occurring after [cursor].
  Future<Result<PullPage, Failure>> pull({
    required String entityTable,
    String? cursor,
    int limit = 100,
  });
}

/// Minimal facade over the local outbox DAO so the engine doesn't depend on a
/// specific DAO class. Implementers wrap [FnxDatabase] DAOs.
abstract class OutboxStore {
  /// Returns up to [limit] entries with `status = pending`, oldest first.
  Future<List<SyncQueueRow>> pickPending({int limit = 50});

  /// Marks [row] as `in_flight` for the duration of the push.
  Future<void> markInFlight(SyncQueueRow row);

  /// Removes [row] from the queue after a successful push.
  Future<void> markDone(SyncQueueRow row);

  /// Increments attempt counter and stores the error; row stays pending.
  Future<void> recordFailure(SyncQueueRow row, String error);

  /// Moves [row] into the dead-letter slot after exhausting retries.
  Future<void> deadLetter(SyncQueueRow row, String reason);

  /// Total number of pending rows (cheap count).
  Future<int> pendingCount();
}

/// Apply remote entities (pull) into the local store. Implemented by each
/// table's repository.
abstract class RemoteApplier {
  /// Tables this applier knows how to handle.
  Set<String> get tables;

  /// Applies [entity] to the local store, resolving conflicts as needed.
  Future<void> apply(RemoteEntity entity);
}
