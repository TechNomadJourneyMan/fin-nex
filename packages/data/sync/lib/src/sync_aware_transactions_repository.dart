import 'dart:async';

import 'package:pf_domain/pf_domain.dart';

import 'sync_engine.dart';

/// Repository decorator that wraps a local transactions repository, queues
/// every write so the [SyncEngine] can push it to the server, and triggers
/// an opportunistic `syncAll()` after each mutation.
///
/// Reads delegate straight to the local store so the UI stays reactive
/// without round-tripping the network.
///
/// TODO(F-501): replace [_NoopOutboxBridge] with a real bridge that inserts
/// rows into `sync_queue` once the local DAOs land.
class SyncAwareTransactionsRepository implements TransactionsRepository {
  /// Default ctor.
  SyncAwareTransactionsRepository({
    required TransactionsRepository local,
    required SyncEngine engine,
    OutboxBridge? outboxBridge,
  })  : _local = local,
        _engine = engine,
        _bridge = outboxBridge ?? const _NoopOutboxBridge();

  final TransactionsRepository _local;
  final SyncEngine _engine;
  final OutboxBridge _bridge;

  @override
  Stream<List<Transaction>> watchAll(Ulid userId) => _local.watchAll(userId);

  @override
  Future<List<Transaction>> list(Ulid userId, TransactionFilter filter) =>
      _local.list(userId, filter);

  @override
  Future<Transaction?> getById(Ulid id) => _local.getById(id);

  @override
  Future<void> upsert(Transaction tx) async {
    await _local.upsert(tx);
    await _bridge.enqueueUpsert(
      entityTable: 'transactions',
      entityId: tx.id.toString(),
      payload: <String, Object?>{'id': tx.id.toString()},
    );
    // Fire-and-forget; failures bubble through engine.status.
    unawaited(_engine.syncAll().then((_) {}));
  }

  @override
  Future<void> softDelete(Ulid id) async {
    await _local.softDelete(id);
    await _bridge.enqueueDelete(
      entityTable: 'transactions',
      entityId: id.toString(),
    );
    unawaited(_engine.syncAll().then((_) {}));
  }
}

/// Abstract bridge between repository writes and the outbox table. The real
/// implementation lives in `pf_data_local` once DAOs are wired up.
abstract class OutboxBridge {
  /// Enqueues an upsert entry into `sync_queue`.
  Future<void> enqueueUpsert({
    required String entityTable,
    required String entityId,
    required Map<String, Object?> payload,
  });

  /// Enqueues a delete entry into `sync_queue`.
  Future<void> enqueueDelete({
    required String entityTable,
    required String entityId,
  });
}

class _NoopOutboxBridge implements OutboxBridge {
  const _NoopOutboxBridge();

  @override
  Future<void> enqueueDelete({
    required String entityTable,
    required String entityId,
  }) async {}

  @override
  Future<void> enqueueUpsert({
    required String entityTable,
    required String entityId,
    required Map<String, Object?> payload,
  }) async {}
}
