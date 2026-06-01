import 'package:sqflite/sqflite.dart';

import '../database/pf_database.dart';
import '../models/setting_row.dart';

/// Data access object for the per-user `user_settings` table.
class SettingsDao {
  /// Wraps [db] for typed access to the `user_settings` table.
  SettingsDao(this.db);

  /// Underlying database handle.
  final PfDatabase db;

  static const String _table = 'user_settings';
  Database get _raw => db.raw;

  /// Returns the settings row for [userId], or `null` when none exists yet.
  Future<SettingRow?> get(String userId) async {
    final rows = await _raw.query(
      _table,
      where: 'user_id = ?',
      whereArgs: <Object?>[userId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return SettingRow.fromMap(rows.first);
  }

  /// Inserts or replaces the settings row.
  Future<void> upsert(SettingRow row) async {
    await _raw.insert(
      _table,
      row.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    db.changeBus.notify(_table);
  }

  /// Watches the settings row for [userId].
  Stream<SettingRow?> watch(String userId) async* {
    yield await get(userId);
    await for (final _ in db.changeBus.watch(_table)) {
      yield await get(userId);
    }
  }
}
