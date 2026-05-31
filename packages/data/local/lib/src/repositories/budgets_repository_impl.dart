import '../daos/budgets_dao.dart';
import '../models/budget_row.dart';
import 'repository_contracts.dart';

/// Sqflite-backed implementation of [BudgetsRepository].
class BudgetsRepositoryImpl implements BudgetsRepository {
  /// Creates the repository wrapping [_dao].
  BudgetsRepositoryImpl(this._dao);

  final BudgetsDao _dao;

  @override
  Future<void> save(BudgetRow row) => _dao.upsert(row);

  @override
  Future<BudgetRow?> findById(String id) => _dao.getById(id);

  @override
  Future<List<BudgetRow>> list(String userId, {bool activeOnly = true}) =>
      _dao.listForUser(userId, activeOnly: activeOnly);

  @override
  Stream<List<BudgetRow>> watch(String userId, {bool activeOnly = true}) =>
      _dao.watchForUser(userId, activeOnly: activeOnly);

  @override
  Future<void> remove(String id, {String? deviceId}) =>
      _dao.softDelete(id, deviceId: deviceId);
}
