import 'package:sqflite/sqflite.dart';

import '../database/pf_database.dart';
import '../models/_helpers.dart';
import '../models/insight_row.dart';

/// Data access object for the `insights` table.
class InsightsDao {
  /// Wraps [db] for typed access to the `insights` table.
  InsightsDao(this.db);

  /// Underlying database handle.
  final PfDatabase db;

  static const String _table = 'insights';
  Database get _raw => db.raw;

  /// Inserts (or replaces) an insight row.
  Future<void> upsert(InsightRow row) async {
    await _raw.insert(
      _table,
      row.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    db.changeBus.notify(_table);
  }

  /// Lists active (non-dismissed, non-expired) insights for [userId].
  Future<List<InsightRow>> listActive(String userId) async {
    final now = nowIso();
    final rows = await _raw.rawQuery(
      'SELECT * FROM $_table '
      'WHERE user_id = ? AND dismissed_at IS NULL '
      'AND (expires_at IS NULL OR expires_at > ?) '
      'ORDER BY generated_at DESC',
      <Object?>[userId, now],
    );
    return rows.map(InsightRow.fromMap).toList(growable: false);
  }

  /// Watches active insights for [userId].
  Stream<List<InsightRow>> watchActive(String userId) async* {
    yield await listActive(userId);
    await for (final _ in db.changeBus.watch(_table)) {
      yield await listActive(userId);
    }
  }

  /// Marks an insight as dismissed.
  Future<void> dismiss(String id) async {
    await _raw.update(
      _table,
      <String, Object?>{'dismissed_at': nowIso()},
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
    db.changeBus.notify(_table);
  }

  /// Marks an insight as acted on.
  Future<void> markActed(String id) async {
    await _raw.update(
      _table,
      <String, Object?>{'acted_at': nowIso()},
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
    db.changeBus.notify(_table);
  }
}
