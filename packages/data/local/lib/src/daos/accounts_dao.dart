import 'dart:async';

import 'package:sqflite/sqflite.dart';

import '../database/pf_database.dart';
import '../models/account_row.dart';

/// Data access object for the `accounts` table.
class AccountsDao {
  /// Wraps [db] for typed access to the `accounts` table.
  AccountsDao(this.db);

  /// Underlying database handle.
  final PfDatabase db;

  static const String _table = 'accounts';
  Database get _raw => db.raw;

  /// Inserts (or replaces) an account row.
  Future<void> upsert(AccountRow row) async {
    await _raw.insert(
      _table,
      row.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    db.changeBus.notify(_table);
  }

  /// Returns the row with the given primary key, or `null` when absent.
  Future<AccountRow?> getById(String id) async {
    final rows = await _raw.query(
      _table,
      where: 'id = ?',
      whereArgs: <Object?>[id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return AccountRow.fromMap(rows.first);
  }

  /// Lists active (non-deleted, non-archived) accounts for [userId].
  Future<List<AccountRow>> listForUser(
    String userId, {
    bool includeArchived = false,
    bool includeDeleted = false,
  }) async {
    final where = <String>['user_id = ?'];
    final args = <Object?>[userId];
    if (!includeDeleted) where.add('deleted_at IS NULL');
    if (!includeArchived) where.add('is_archived = 0');
    final rows = await _raw.query(
      _table,
      where: where.join(' AND '),
      whereArgs: args,
      orderBy: 'sort_order ASC, name ASC',
    );
    return rows.map(AccountRow.fromMap).toList(growable: false);
  }

  /// Watches the user's account list and emits on every relevant mutation.
  Stream<List<AccountRow>> watchForUser(String userId) async* {
    yield await listForUser(userId);
    await for (final _ in db.changeBus.watch(_table)) {
      yield await listForUser(userId);
    }
  }

  /// Soft-deletes an account, leaving its transactions intact.
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

  /// Recomputes and persists [balanceMinor] for [id] from its transactions.
  ///
  /// The denormalised balance equals `initial_balance + Σ(income/transfer-in)
  /// − Σ(expense/transfer-out)`. Adjustments are added with their sign.
  Future<int> recomputeBalance(String id) async {
    final acc = await getById(id);
    if (acc == null) return 0;
    final result = await _raw.rawQuery(
      'SELECT '
      "  COALESCE(SUM(CASE WHEN type_code = 'income' THEN amount_minor ELSE 0 END), 0) AS income, "
      "  COALESCE(SUM(CASE WHEN type_code = 'expense' THEN amount_minor ELSE 0 END), 0) AS expense, "
      "  COALESCE(SUM(CASE WHEN type_code = 'transfer' AND transfer_account_id = ? THEN amount_minor ELSE 0 END), 0) AS xfer_in, "
      "  COALESCE(SUM(CASE WHEN type_code = 'transfer' AND account_id = ? THEN amount_minor ELSE 0 END), 0) AS xfer_out "
      'FROM transactions '
      'WHERE (account_id = ? OR transfer_account_id = ?) AND deleted_at IS NULL',
      <Object?>[id, id, id, id],
    );
    final row = result.first;
    final income = (row['income'] as num).toInt();
    final expense = (row['expense'] as num).toInt();
    final xferIn = (row['xfer_in'] as num).toInt();
    final xferOut = (row['xfer_out'] as num).toInt();
    final balance = acc.initialBalanceMinor + income - expense + xferIn - xferOut;
    await _raw.update(
      _table,
      <String, Object?>{'balance_minor': balance},
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
    db.changeBus.notify(_table);
    return balance;
  }
}
