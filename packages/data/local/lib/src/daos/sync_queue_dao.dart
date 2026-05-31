import 'package:sqflite/sqflite.dart';

import '../database/fnx_database.dart';
import '../models/_helpers.dart';
import '../models/sync_queue_row.dart';

/// Data access object for the `sync_queue` outbox table.
class SyncQueueDao {
  /// Wraps [db] for typed access to the `sync_queue` table.
  SyncQueueDao(this.db);

  /// Underlying database handle.
  final FnxDatabase db;

  static const String _table = 'sync_queue';
  Database get _raw => db.raw;

  /// Enqueues a new outbox entry; returns the assigned autoincrement id.
  Future<int> enqueue(SyncQueueRow row) async {
    final id = await _raw.insert(_table, row.toMap());
    db.changeBus.notify(_table);
    return id;
  }

  /// Returns up to [limit] pending entries in FIFO order.
  Future<List<SyncQueueRow>> pending({int limit = 50}) async {
    final rows = await _raw.query(
      _table,
      where: "status = 'pending'",
      orderBy: 'enqueued_at ASC, id ASC',
      limit: limit,
    );
    return rows.map(SyncQueueRow.fromMap).toList(growable: false);
  }

  /// Marks [id] as in-flight.
  Future<void> markInFlight(int id) async {
    await _raw.update(
      _table,
      <String, Object?>{
        'status': 'in_flight',
        'last_attempt_at': nowIso(),
      },
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
    db.changeBus.notify(_table);
  }

  /// Marks [id] as successfully completed.
  Future<void> markDone(int id) async {
    await _raw.update(
      _table,
      <String, Object?>{'status': 'done'},
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
    db.changeBus.notify(_table);
  }

  /// Records a transient failure; increments [attempts] and stores [error].
  Future<void> markFailed(int id, String error) async {
    await _raw.rawUpdate(
      "UPDATE $_table SET status = 'pending', attempts = attempts + 1, "
      'last_attempt_at = ?, last_error = ? WHERE id = ?',
      <Object?>[nowIso(), error, id],
    );
    db.changeBus.notify(_table);
  }

  /// Records a permanent failure that should not auto-retry.
  Future<void> markFailedPermanent(int id, String error) async {
    await _raw.update(
      _table,
      <String, Object?>{
        'status': 'failed_permanent',
        'last_attempt_at': nowIso(),
        'last_error': error,
      },
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
    db.changeBus.notify(_table);
  }

  /// Deletes completed entries older than [olderThan].
  Future<int> purgeDone({Duration olderThan = const Duration(days: 7)}) async {
    final cutoff = DateTime.now().toUtc().subtract(olderThan).toIso8601String();
    final deleted = await _raw.delete(
      _table,
      where: "status = 'done' AND enqueued_at < ?",
      whereArgs: <Object?>[cutoff],
    );
    if (deleted > 0) db.changeBus.notify(_table);
    return deleted;
  }
}
