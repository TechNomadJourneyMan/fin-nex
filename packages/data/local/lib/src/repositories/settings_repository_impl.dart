import '../daos/settings_dao.dart';
import '../models/setting_row.dart';
import 'repository_contracts.dart';

/// Sqflite-backed implementation of [SettingsRepository].
class SettingsRepositoryImpl implements SettingsRepository {
  /// Creates the repository wrapping [_dao].
  SettingsRepositoryImpl(this._dao);

  final SettingsDao _dao;

  @override
  Future<SettingRow?> get(String userId) => _dao.get(userId);

  @override
  Future<void> save(SettingRow row) => _dao.upsert(row);

  @override
  Stream<SettingRow?> watch(String userId) => _dao.watch(userId);
}
