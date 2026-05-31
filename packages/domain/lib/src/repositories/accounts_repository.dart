import '../entities/account.dart';
import '../values/ulid.dart';

/// Persistence and query contract for [Account].
abstract interface class AccountsRepository {
  /// Live list of non-deleted accounts for [userId].
  Stream<List<Account>> watchAll(Ulid userId);

  /// Snapshot list.
  Future<List<Account>> list(Ulid userId);

  /// Returns the account or `null`.
  Future<Account?> getById(Ulid id);

  /// Inserts or updates [account].
  Future<void> upsert(Account account);

  /// Soft-deletes [id].
  Future<void> softDelete(Ulid id);
}
