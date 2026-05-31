import 'dart:async';

import 'package:sqflite/sqflite.dart';

import '../database/fnx_database.dart';
import '../models/budget_row.dart';

/// Data access object for the `budgets` table.
class BudgetsDao {
  /// Wraps [db] for typed access to the `budgets` table.
  BudgetsDao(this.db);

  /// Underlying database handle.
  final FnxDatabase db;

  static const String _table = 'budgets';
  Database get _raw => db.raw;

  /// Inserts (or replaces) a budget row.
  Future<void> upsert(BudgetRow row) async {
    await _raw.insert(
      _table,
      row.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    db.changeBus.notify(_table);
  }

  /// Returns the row with the given primary key, or `null` when absent.
  Future<BudgetRow?> getById(String id) async {
    final rows = await _raw.query(
      _table,
      where: 'id = ?',
      whereArgs: <Object?>[id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return BudgetRow.fromMap(rows.first);
  }

  /// Lists budgets for [userId].
  Future<List<BudgetRow>> listForUser(
    String userId, {
    bool activeOnly = true,
  }) async {
    final where = <String>['user_id = ?', 'deleted_at IS NULL'];
    final args = <Object?>[userId];
    if (activeOnly) where.add('is_active = 1');
    final rows = await _raw.query(
      _table,
      where: where.join(' AND '),
      whereArgs: args,
      orderBy: 'starts_on DESC',
    );
    return rows.map(BudgetRow.fromMap).toList(growable: false);
  }

  /// Watches the user's budget list.
  Stream<List<BudgetRow>> watchForUser(
    String userId, {
    bool activeOnly = true,
  }) async* {
    yield await listForUser(userId, activeOnly: activeOnly);
    await for (final _ in db.changeBus.watch(_table)) {
      yield await listForUser(userId, activeOnly: activeOnly);
    }
  }

  /// Soft-deletes a budget.
  Future<void> softDelete(String id, {String? deviceId}) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await _raw.update(
      _table,
      <String, Object?>{
        'deleted_at': now,
        'updated_at': now,
        'sync_state': 'pending',
        'dirty': 1,
        if (deviceId != null) 'device_id': deviceId,
      },
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
    db.changeBus.notify(_table);
  }
}
