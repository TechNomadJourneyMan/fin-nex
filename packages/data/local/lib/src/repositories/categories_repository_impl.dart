import '../daos/categories_dao.dart';
import '../models/category_row.dart';
import 'repository_contracts.dart';

/// Sqflite-backed implementation of [CategoriesRepository].
class CategoriesRepositoryImpl implements CategoriesRepository {
  /// Creates the repository wrapping [_dao].
  CategoriesRepositoryImpl(this._dao);

  final CategoriesDao _dao;

  @override
  Future<void> save(CategoryRow row) => _dao.upsert(row);

  @override
  Future<CategoryRow?> findById(String id) => _dao.getById(id);

  @override
  Future<List<CategoryRow>> list(String userId, {String? typeCode}) =>
      _dao.listForUser(userId, typeCode: typeCode);

  @override
  Stream<List<CategoryRow>> watch(String userId, {String? typeCode}) =>
      _dao.watchForUser(userId, typeCode: typeCode);

  @override
  Future<void> remove(String id, {String? deviceId}) =>
      _dao.softDelete(id, deviceId: deviceId);
}
