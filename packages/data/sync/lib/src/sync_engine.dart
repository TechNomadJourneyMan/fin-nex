import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pf_domain/pf_domain.dart';

import 'conflict_resolver.dart';
import 'cursor_store.dart';
import 'outbox_processor.dart';
import 'result.dart';
import 'sync_contracts.dart';
import 'sync_status.dart';

/// Tables synced by the engine, in pull order.
///
/// The order matters: parents (accounts, categories) must be pulled before
/// rows that reference them (transactions, budgets).
const List<String> kSyncTables = <String>[
  'accounts',
  'categories',
  'tags',
  'transactions',
  'budgets',
];

/// Orchestrates the push (outbox) and pull (server cursor) halves of the
/// sync round-trip.
///
/// The engine is intentionally small: it sequences the moving parts and emits
/// a [SyncStatus] stream the UI listens to. Concrete IO lives in
/// [OutboxProcessor], [SyncService], and the per-table [RemoteApplier]s.
class SyncEngine {
  /// Default const ctor.
  SyncEngine({
    required this.outbox,
    required this.service,
    required this.cursors,
    required Map<String, RemoteApplier> appliers,
    ConflictResolver? resolver,
    List<String>? tables,
  })  : _appliers = Map<String, RemoteApplier>.unmodifiable(appliers),
        resolver = resolver ?? const ConflictResolver(),
        tables = List<String>.unmodifiable(tables ?? kSyncTables);

  /// Drains the local outbox.
  final OutboxProcessor outbox;

  /// Remote transport.
  final SyncService service;

  /// Per-table pull cursor persistence.
  final CursorStore cursors;

  /// Conflict resolution policy.
  final ConflictResolver resolver;

  /// Tables iterated by [pull] and [syncAll].
  final List<String> tables;

  final Map<String, RemoteApplier> _appliers;

  final StreamController<SyncStatus> _statusController =
      StreamController<SyncStatus>.broadcast();

  /// Broadcast stream of lifecycle transitions.
  Stream<SyncStatus> get status => _statusController.stream;

  bool _running = false;

  /// Pushes the outbox until empty (or transport fails).
  Future<Result<int, Failure>> push() async {
    _emit(const SyncStatus.pushing());
    final res = await outbox.drainAll();
    switch (res) {
      case Ok<int, Failure>():
        _emit(const SyncStatus.idle());
      case Err<int, Failure>(:final failure):
        _emit(SyncStatus.error(failure.message));
    }
    return res;
  }

  /// Pulls server changes for every configured table.
  Future<Result<int, Failure>> pull() async {
    _emit(const SyncStatus.pulling());
    var applied = 0;
    var conflicts = 0;
    for (final table in tables) {
      final applier = _appliers[table];
      if (applier == null) {
        // No applier registered yet — skip silently; this lets feature packages
        // opt-in incrementally.
        continue;
      }
      var cursor = cursors.read(table);
      var done = false;
      while (!done) {
        final res = await service.pull(
          entityTable: table,
          cursor: cursor,
        );
        if (res is Err<PullPage, Failure>) {
          _emit(SyncStatus.error(res.failure.message));
          return Err<int, Failure>(res.failure);
        }
        final page = (res as Ok<PullPage, Failure>).value;
        for (final entity in page.entities) {
          try {
            await applier.apply(entity);
            applied++;
          } on SyncConflictFailure {
            conflicts++;
          }
        }
        await cursors.write(table, page.nextCursor);
        cursor = page.nextCursor;
        done = !page.hasMore || cursor == null;
      }
    }
    if (conflicts > 0) {
      _emit(SyncStatus.conflict(conflicts));
    } else {
      _emit(const SyncStatus.idle());
    }
    return Ok<int, Failure>(applied);
  }

  /// Convenience orchestrator: push, then pull. Returns on the first failure.
  Future<Result<void, Failure>> syncAll() async {
    if (_running) return const Ok<void, Failure>(null);
    _running = true;
    try {
      final pushRes = await push();
      if (pushRes is Err<int, Failure>) {
        return Err<void, Failure>(pushRes.failure);
      }
      final pullRes = await pull();
      if (pullRes is Err<int, Failure>) {
        return Err<void, Failure>(pullRes.failure);
      }
      return const Ok<void, Failure>(null);
    } finally {
      _running = false;
    }
  }

  /// Releases the status stream controller.
  Future<void> dispose() async {
    await _statusController.close();
  }

  void _emit(SyncStatus s) {
    if (_statusController.isClosed) return;
    _statusController.add(s);
    if (kDebugMode) debugPrint('SyncEngine status -> $s');
  }
}
