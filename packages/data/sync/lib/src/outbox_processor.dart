import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:fnx_data_local/fnx_data_local.dart';
import 'package:fnx_domain/fnx_domain.dart';

import 'result.dart';
import 'sync_contracts.dart';

/// Drains the local outbox in batches and pushes them to the server.
///
/// Retry policy (per `08_architecture.md` §7.4, tightened for MVP):
/// * exponential backoff `2^attempt * 1s + jitter(0..1s)`, capped at
///   ~8.5 minutes;
/// * `maxAttempts` (default `8`) before the row is moved to the dead-letter
///   queue;
/// * `429` and `5xx` failures count as retries; explicit `rejected` from the
///   server skips retry and dead-letters immediately.
class OutboxProcessor {
  /// Default const ctor.
  OutboxProcessor({
    required this.outbox,
    required this.service,
    this.batchSize = 50,
    this.maxAttempts = 8,
    math.Random? random,
  })  : assert(batchSize > 0, 'batchSize must be positive'),
        assert(maxAttempts > 0, 'maxAttempts must be positive'),
        _rng = random ?? math.Random();

  /// Local outbox facade.
  final OutboxStore outbox;

  /// Remote sync transport.
  final SyncService service;

  /// Maximum rows pushed per HTTP round-trip.
  final int batchSize;

  /// Maximum attempts before a row is dead-lettered.
  final int maxAttempts;

  final math.Random _rng;

  /// Computes the next backoff delay for [attempt] (`0`-based).
  Duration nextBackoff(int attempt) {
    final capped = math.min(attempt, 9);
    final base = Duration(seconds: math.pow(2, capped).toInt());
    final jitter = Duration(milliseconds: _rng.nextInt(1000));
    return base + jitter;
  }

  /// Drains the outbox once: pulls a single batch, pushes it, and updates
  /// each row according to the server's [PushAck]. Returns the number of
  /// rows processed in this call (regardless of outcome).
  Future<Result<int, Failure>> drainOnce() async {
    final batch = await outbox.pickPending(limit: batchSize);
    if (batch.isEmpty) return const Ok<int, Failure>(0);

    for (final row in batch) {
      await outbox.markInFlight(row);
    }

    final response = await service.push(batch);
    if (response is Err<List<PushAck>, Failure>) {
      for (final row in batch) {
        await _recordFailure(row, response.failure.message);
      }
      return Err<int, Failure>(response.failure);
    }

    final acks = (response as Ok<List<PushAck>, Failure>).value;
    if (acks.length != batch.length) {
      const f = ServerFailure('push ack length mismatch');
      for (final row in batch) {
        await _recordFailure(row, f.message);
      }
      return const Err<int, Failure>(f);
    }

    for (var i = 0; i < batch.length; i++) {
      await _applyAck(batch[i], acks[i]);
    }
    return Ok<int, Failure>(batch.length);
  }

  /// Drains repeatedly until the queue is empty or a transport failure is
  /// returned. Useful for an explicit "Sync now" CTA.
  Future<Result<int, Failure>> drainAll() async {
    var total = 0;
    while (true) {
      final res = await drainOnce();
      switch (res) {
        case Ok<int, Failure>(:final value):
          if (value == 0) return Ok<int, Failure>(total);
          total += value;
        case Err<int, Failure>():
          return res;
      }
    }
  }

  Future<void> _applyAck(SyncQueueRow row, PushAck ack) async {
    switch (ack.outcome) {
      case PushOutcome.accepted:
        await outbox.markDone(row);
      case PushOutcome.rejected:
        await outbox.deadLetter(row, ack.error ?? 'rejected by server');
      case PushOutcome.conflict:
        // Conflicts are surfaced as failures so the engine's conflict resolver
        // runs on the subsequent pull; we keep the row pending so a refreshed
        // payload can be re-pushed.
        await _recordFailure(row, ack.error ?? 'conflict');
      case PushOutcome.retry:
        await _recordFailure(row, ack.error ?? 'transient failure');
    }
  }

  Future<void> _recordFailure(SyncQueueRow row, String error) async {
    final attempts = row.attempts + 1;
    if (attempts >= maxAttempts) {
      await outbox.deadLetter(
        row,
        'max_attempts_exceeded: $error',
      );
      return;
    }
    await outbox.recordFailure(row, error);
    if (kDebugMode) {
      debugPrint(
        'OutboxProcessor failure '
        '[${row.entityTable}/${row.entityId}] attempt=$attempts: $error',
      );
    }
  }
}
