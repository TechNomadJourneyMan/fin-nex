import '../daos/accounts_dao.dart';
import '../models/account_row.dart';
import 'repository_contracts.dart';

/// Sqflite-backed implementation of [AccountsRepository].
class AccountsRepositoryImpl implements AccountsRepository {
  /// Creates the repository wrapping [_dao].
  AccountsRepositoryImpl(this._dao);

  final AccountsDao _dao;

  @override
  Future<void> save(AccountRow row) => _dao.upsert(row);

  @override
  Future<AccountRow?> findById(String id) => _dao.getById(id);

  @override
  Future<List<AccountRow>> list(String userId) => _dao.listForUser(userId);

  @override
  Stream<List<AccountRow>> watch(String userId) => _dao.watchForUser(userId);

  @override
  Future<void> remove(String id, {String? deviceId}) =>
      _dao.softDelete(id, deviceId: deviceId);

  @override
  Future<int> recomputeBalance(String id) => _dao.recomputeBalance(id);
}
