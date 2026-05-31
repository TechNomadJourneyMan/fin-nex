import '../entities/category.dart';
import '../values/ulid.dart';

/// Persistence and query contract for [Category].
abstract interface class CategoriesRepository {
  /// Live list of all categories visible to [userId] (system + user-owned).
  Stream<List<Category>> watchAll(Ulid userId);

  /// Snapshot list.
  Future<List<Category>> list(Ulid userId);

  /// Returns the category or `null`.
  Future<Category?> getById(Ulid id);

  /// Inserts or updates [category].
  Future<void> upsert(Category category);

  /// Soft-deletes [id].
  Future<void> softDelete(Ulid id);
}
