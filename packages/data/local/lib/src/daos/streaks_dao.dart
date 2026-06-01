import 'package:sqflite/sqflite.dart';

import '../database/pf_database.dart';
import '../models/streak_row.dart';

/// Data access object for the `streaks` table.
class StreaksDao {
  /// Wraps [db] for typed access to the `streaks` table.
  StreaksDao(this.db);

  /// Underlying database handle.
  final PfDatabase db;

  static const String _table = 'streaks';
  Database get _raw => db.raw;

  /// Returns the streak row for [userId], or `null` when not yet initialised.
  Future<StreakRow?> get(String userId) async {
    final rows = await _raw.query(
      _table,
      where: 'user_id = ?',
      whereArgs: <Object?>[userId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return StreakRow.fromMap(rows.first);
  }

  /// Inserts or replaces the streak row.
  Future<void> upsert(StreakRow row) async {
    await _raw.insert(
      _table,
      row.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    db.changeBus.notify(_table);
  }

  /// Watches the streak row for [userId].
  Stream<StreakRow?> watch(String userId) async* {
    yield await get(userId);
    await for (final _ in db.changeBus.watch(_table)) {
      yield await get(userId);
    }
  }
}
