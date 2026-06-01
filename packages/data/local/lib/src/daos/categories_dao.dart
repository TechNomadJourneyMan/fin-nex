import 'dart:async';

import 'package:sqflite/sqflite.dart';

import '../database/pf_database.dart';
import '../models/category_row.dart';

/// Data access object for the `categories` table.
class CategoriesDao {
  /// Wraps [db] for typed access to the `categories` table.
  CategoriesDao(this.db);

  /// Underlying database handle.
  final PfDatabase db;

  static const String _table = 'categories';
  Database get _raw => db.raw;

  /// Inserts (or replaces) a category row.
  Future<void> upsert(CategoryRow row) async {
    await _raw.insert(
      _table,
      row.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    db.changeBus.notify(_table);
  }

  /// Batch-upserts a list of category rows.
  Future<void> upsertAll(Iterable<CategoryRow> rows) async {
    await _raw.transaction((txn) async {
      final batch = txn.batch();
      for (final r in rows) {
        batch.insert(
          _table,
          r.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
    db.changeBus.notify(_table);
  }

  /// Returns the row with the given primary key, or `null` when absent.
  Future<CategoryRow?> getById(String id) async {
    final rows = await _raw.query(
      _table,
      where: 'id = ?',
      whereArgs: <Object?>[id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return CategoryRow.fromMap(rows.first);
  }

  /// Lists categories available to [userId] — system categories plus the
  /// user's own. Optionally filtered by [typeCode].
  Future<List<CategoryRow>> listForUser(
    String userId, {
    String? typeCode,
    bool includeArchived = false,
  }) async {
    final where = <String>[
      '(user_id = ? OR is_system = 1)',
      'deleted_at IS NULL'
    ];
    final args = <Object?>[userId];
    if (!includeArchived) where.add('is_archived = 0');
    if (typeCode != null) {
      where.add('type_code = ?');
      args.add(typeCode);
    }
    final rows = await _raw.query(
      _table,
      where: where.join(' AND '),
      whereArgs: args,
      orderBy: 'is_system DESC, sort_order ASC, name ASC',
    );
    return rows.map(CategoryRow.fromMap).toList(growable: false);
  }

  /// Returns only the built-in system categories (system-canonical replica).
  Future<List<CategoryRow>> listSystem({String? typeCode}) async {
    final where = <String>['is_system = 1', 'deleted_at IS NULL'];
    final args = <Object?>[];
    if (typeCode != null) {
      where.add('type_code = ?');
      args.add(typeCode);
    }
    final rows = await _raw.query(
      _table,
      where: where.join(' AND '),
      whereArgs: args,
      orderBy: 'sort_order ASC, name ASC',
    );
    return rows.map(CategoryRow.fromMap).toList(growable: false);
  }

  /// Watches the available categories for [userId].
  Stream<List<CategoryRow>> watchForUser(
    String userId, {
    String? typeCode,
  }) async* {
    yield await listForUser(userId, typeCode: typeCode);
    await for (final _ in db.changeBus.watch(_table)) {
      yield await listForUser(userId, typeCode: typeCode);
    }
  }

  /// Counts how many system categories are present (used by the seeder).
  Future<int> countSystem() async {
    final r = await _raw.rawQuery(
      'SELECT COUNT(*) AS c FROM $_table WHERE is_system = 1',
    );
    return (r.first['c'] as num).toInt();
  }

  /// Soft-deletes a custom category. System categories cannot be deleted.
  Future<void> softDelete(String id, {String? deviceId}) async {
    final existing = await getById(id);
    if (existing == null || existing.isSystem) return;
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
