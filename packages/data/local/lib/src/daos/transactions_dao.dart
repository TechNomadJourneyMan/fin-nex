import 'dart:async';

import 'package:sqflite/sqflite.dart';

import '../database/fnx_database.dart';
import '../models/transaction_row.dart';

/// Data access object for the `transactions` table.
class TransactionsDao {
  /// Wraps [db] for typed access to the `transactions` table.
  TransactionsDao(this.db);

  /// Underlying database handle.
  final FnxDatabase db;

  static const String _table = 'transactions';

  Database get _raw => db.raw;

  /// Inserts (or replaces) a transaction row.
  Future<void> upsert(TransactionRow row) async {
    await _raw.insert(
      _table,
      row.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    db.changeBus.notify(_table);
  }

  /// Batch-upserts a list of transaction rows in a single transaction.
  Future<void> upsertAll(Iterable<TransactionRow> rows) async {
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
  Future<TransactionRow?> getById(String id) async {
    final rows = await _raw.query(
      _table,
      where: 'id = ?',
      whereArgs: <Object?>[id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return TransactionRow.fromMap(rows.first);
  }

  /// Lists transactions for [userId] in descending `occurred_at` order.
  ///
  /// Filters:
  /// * [from] / [to] — inclusive `occurred_at` bounds (UTC).
  /// * [accountId] — restrict to a single account.
  /// * [categoryId] — restrict to a single category.
  /// * [typeCode] — restrict to a single transaction type.
  /// * [includeDeleted] — include soft-deleted rows (default `false`).
  Future<List<TransactionRow>> listForUser(
    String userId, {
    DateTime? from,
    DateTime? to,
    String? accountId,
    String? categoryId,
    String? typeCode,
    int? limit,
    int? offset,
    bool includeDeleted = false,
  }) async {
    final where = <String>['user_id = ?'];
    final args = <Object?>[userId];
    if (!includeDeleted) where.add('deleted_at IS NULL');
    if (from != null) {
      where.add('occurred_at >= ?');
      args.add(from.toUtc().toIso8601String());
    }
    if (to != null) {
      where.add('occurred_at <= ?');
      args.add(to.toUtc().toIso8601String());
    }
    if (accountId != null) {
      where.add('account_id = ?');
      args.add(accountId);
    }
    if (categoryId != null) {
      where.add('category_id = ?');
      args.add(categoryId);
    }
    if (typeCode != null) {
      where.add('type_code = ?');
      args.add(typeCode);
    }
    final rows = await _raw.query(
      _table,
      where: where.join(' AND '),
      whereArgs: args,
      orderBy: 'occurred_at DESC',
      limit: limit,
      offset: offset,
    );
    return rows.map(TransactionRow.fromMap).toList(growable: false);
  }

  /// Watches a filtered list for changes, emitting on every relevant mutation.
  Stream<List<TransactionRow>> watchForUser(
    String userId, {
    DateTime? from,
    DateTime? to,
    String? accountId,
    String? categoryId,
    String? typeCode,
    int? limit,
  }) async* {
    Future<List<TransactionRow>> snapshot() => listForUser(
          userId,
          from: from,
          to: to,
          accountId: accountId,
          categoryId: categoryId,
          typeCode: typeCode,
          limit: limit,
        );
    yield await snapshot();
    await for (final _ in db.changeBus.watch(_table)) {
      yield await snapshot();
    }
  }

  /// Soft-deletes a transaction by id, marking it `dirty` for sync.
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

  /// Hard-deletes a transaction row (e.g. cleanup of a never-synced draft).
  Future<void> hardDelete(String id) async {
    await _raw.delete(_table, where: 'id = ?', whereArgs: <Object?>[id]);
    db.changeBus.notify(_table);
  }

  /// Returns the sum of `amount_minor` for the given filters.
  Future<int> sumForUser(
    String userId, {
    DateTime? from,
    DateTime? to,
    String? typeCode,
    String? categoryId,
  }) async {
    final where = <String>['user_id = ?', 'deleted_at IS NULL'];
    final args = <Object?>[userId];
    if (from != null) {
      where.add('occurred_at >= ?');
      args.add(from.toUtc().toIso8601String());
    }
    if (to != null) {
      where.add('occurred_at <= ?');
      args.add(to.toUtc().toIso8601String());
    }
    if (typeCode != null) {
      where.add('type_code = ?');
      args.add(typeCode);
    }
    if (categoryId != null) {
      where.add('category_id = ?');
      args.add(categoryId);
    }
    final result = await _raw.rawQuery(
      'SELECT COALESCE(SUM(amount_minor), 0) AS total FROM $_table '
      'WHERE ${where.join(' AND ')}',
      args,
    );
    final total = result.first['total'];
    return total is int ? total : (total as num? ?? 0).toInt();
  }

  /// Returns rows that have local changes pending push.
  Future<List<TransactionRow>> dirtyForUser(String userId, {int? limit}) async {
    final rows = await _raw.query(
      _table,
      where: 'user_id = ? AND dirty = 1',
      whereArgs: <Object?>[userId],
      orderBy: 'updated_at ASC',
      limit: limit,
    );
    return rows.map(TransactionRow.fromMap).toList(growable: false);
  }
}
