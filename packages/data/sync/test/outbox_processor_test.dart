import 'package:flutter_test/flutter_test.dart';
import 'package:fnx_data_local/fnx_data_local.dart';
import 'package:fnx_data_sync/fnx_data_sync.dart';
import 'package:fnx_domain/fnx_domain.dart';

class _FakeOutbox implements OutboxStore {
  _FakeOutbox(this._rows);

  final List<SyncQueueRow> _rows;
  final List<String> markedInFlight = <String>[];
  final List<String> markedDone = <String>[];
  final List<({String id, String error})> failures =
      <({String id, String error})>[];
  final List<({String id, String reason})> dead =
      <({String id, String reason})>[];

  @override
  Future<List<SyncQueueRow>> pickPending({int limit = 50}) async {
    return _rows.take(limit).toList();
  }

  @override
  Future<void> markInFlight(SyncQueueRow row) async {
    markedInFlight.add(row.entityId);
  }

  @override
  Future<void> markDone(SyncQueueRow row) async {
    markedDone.add(row.entityId);
    _rows.removeWhere((r) => r.entityId == row.entityId);
  }

  @override
  Future<void> recordFailure(SyncQueueRow row, String error) async {
    failures.add((id: row.entityId, error: error));
    final idx = _rows.indexWhere((r) => r.entityId == row.entityId);
    if (idx >= 0) {
      final r = _rows[idx];
      _rows[idx] = SyncQueueRow(
        id: r.id,
        entityTable: r.entityTable,
        entityId: r.entityId,
        op: r.op,
        payload: r.payload,
        enqueuedAt: r.enqueuedAt,
        attempts: r.attempts + 1,
        lastAttemptAt: DateTime.now().toUtc(),
        lastError: error,
        status: r.status,
      );
    }
  }

  @override
  Future<void> deadLetter(SyncQueueRow row, String reason) async {
    dead.add((id: row.entityId, reason: reason));
    _rows.removeWhere((r) => r.entityId == row.entityId);
  }

  @override
  Future<int> pendingCount() async => _rows.length;
}

class _ScriptedService implements SyncService {
  _ScriptedService(this._script);

  final List<List<PushAck>> _script;
  int _callIndex = 0;

  @override
  Future<Result<List<PushAck>, Failure>> push(
    List<SyncQueueRow> batch,
  ) async {
    if (_callIndex >= _script.length) {
      return Ok<List<PushAck>, Failure>(
        List<PushAck>.filled(
          batch.length,
          const PushAck(outcome: PushOutcome.accepted),
        ),
      );
    }
    final next = _script[_callIndex++];
    return Ok<List<PushAck>, Failure>(next);
  }

  @override
  Future<Result<PullPage, Failure>> pull({
    required String entityTable,
    String? cursor,
    int limit = 100,
  }) async {
    return const Ok<PullPage, Failure>(
      PullPage(entities: <RemoteEntity>[], nextCursor: null),
    );
  }
}

SyncQueueRow _row(String id, {int attempts = 0}) => SyncQueueRow(
      entityTable: 'transactions',
      entityId: id,
      op: SyncOp.upsert,
      payload: '{}',
      enqueuedAt: DateTime.utc(2026, 5, 31, 12),
      attempts: attempts,
    );

void main() {
  group('OutboxProcessor', () {
    test('accepted acks remove rows from the outbox', () async {
      final outbox = _FakeOutbox(<SyncQueueRow>[_row('a'), _row('b')]);
      final service = _ScriptedService(<List<PushAck>>[
        <PushAck>[
          const PushAck(outcome: PushOutcome.accepted),
          const PushAck(outcome: PushOutcome.accepted),
        ],
      ]);
      final processor = OutboxProcessor(outbox: outbox, service: service);

      final res = await processor.drainOnce();

      expect(res.isOk, isTrue);
      expect(res.unwrap(), 2);
      expect(outbox.markedDone, <String>['a', 'b']);
      expect(await outbox.pendingCount(), 0);
    });

    test('retry outcome increments attempts and keeps the row', () async {
      final outbox = _FakeOutbox(<SyncQueueRow>[_row('a')]);
      final service = _ScriptedService(<List<PushAck>>[
        <PushAck>[const PushAck(outcome: PushOutcome.retry, error: '5xx')],
      ]);
      final processor = OutboxProcessor(outbox: outbox, service: service);

      await processor.drainOnce();

      expect(outbox.failures, hasLength(1));
      expect(outbox.failures.first.error, '5xx');
      expect(await outbox.pendingCount(), 1);
    });

    test('rejected outcome dead-letters immediately', () async {
      final outbox = _FakeOutbox(<SyncQueueRow>[_row('a')]);
      final service = _ScriptedService(<List<PushAck>>[
        <PushAck>[
          const PushAck(outcome: PushOutcome.rejected, error: 'bad payload'),
        ],
      ]);
      final processor = OutboxProcessor(outbox: outbox, service: service);

      await processor.drainOnce();

      expect(outbox.dead, hasLength(1));
      expect(outbox.dead.first.reason, 'bad payload');
      expect(await outbox.pendingCount(), 0);
    });

    test('max attempts exceeded moves row to dead letter', () async {
      // Start with attempts = 7 (one before maxAttempts default of 8).
      final outbox = _FakeOutbox(<SyncQueueRow>[_row('a', attempts: 7)]);
      final service = _ScriptedService(<List<PushAck>>[
        <PushAck>[const PushAck(outcome: PushOutcome.retry, error: 'flaky')],
      ]);
      final processor = OutboxProcessor(outbox: outbox, service: service);

      await processor.drainOnce();

      expect(outbox.dead, hasLength(1));
      expect(
        outbox.dead.first.reason,
        contains('max_attempts_exceeded'),
      );
    });

    test('nextBackoff grows exponentially and stays bounded', () {
      final processor = OutboxProcessor(
        outbox: _FakeOutbox(<SyncQueueRow>[]),
        service: _ScriptedService(<List<PushAck>>[]),
      );
      final d0 = processor.nextBackoff(0);
      final d3 = processor.nextBackoff(3);
      final d20 = processor.nextBackoff(20);
      expect(d0.inSeconds, lessThanOrEqualTo(2));
      expect(d3.inSeconds, greaterThanOrEqualTo(8));
      // Capped at attempt=9 → 2^9 = 512 s base + <1s jitter.
      expect(d20.inSeconds, lessThanOrEqualTo(513));
    });

    test('push ack length mismatch is treated as failure for all rows',
        () async {
      final outbox = _FakeOutbox(<SyncQueueRow>[_row('a'), _row('b')]);
      final service = _ScriptedService(<List<PushAck>>[
        <PushAck>[const PushAck(outcome: PushOutcome.accepted)],
      ]);
      final processor = OutboxProcessor(outbox: outbox, service: service);

      final res = await processor.drainOnce();

      expect(res.isErr, isTrue);
      expect(outbox.failures, hasLength(2));
    });
  });
}
