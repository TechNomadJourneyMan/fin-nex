import '../daos/transactions_dao.dart';
import '../models/transaction_row.dart';
import 'repository_contracts.dart';

/// Sqflite-backed implementation of [TransactionsRepository].
class TransactionsRepositoryImpl implements TransactionsRepository {
  /// Creates the repository wrapping [_dao].
  TransactionsRepositoryImpl(this._dao);

  final TransactionsDao _dao;

  @override
  Future<void> save(TransactionRow row) => _dao.upsert(row);

  @override
  Future<TransactionRow?> findById(String id) => _dao.getById(id);

  @override
  Future<List<TransactionRow>> list(
    String userId, {
    DateTime? from,
    DateTime? to,
    String? accountId,
    String? categoryId,
    String? typeCode,
    int? limit,
  }) =>
      _dao.listForUser(
        userId,
        from: from,
        to: to,
        accountId: accountId,
        categoryId: categoryId,
        typeCode: typeCode,
        limit: limit,
      );

  @override
  Stream<List<TransactionRow>> watch(
    String userId, {
    DateTime? from,
    DateTime? to,
    String? accountId,
    String? categoryId,
    String? typeCode,
  }) =>
      _dao.watchForUser(
        userId,
        from: from,
        to: to,
        accountId: accountId,
        categoryId: categoryId,
        typeCode: typeCode,
      );

  @override
  Future<void> remove(String id, {String? deviceId}) =>
      _dao.softDelete(id, deviceId: deviceId);
}
