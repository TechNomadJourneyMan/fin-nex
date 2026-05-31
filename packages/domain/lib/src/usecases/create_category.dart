import '../entities/category.dart';
import '../failures/failure.dart';
import '../repositories/categories_repository.dart';

/// Creates a user-owned [Category].
class CreateCategory {
  /// Default constructor.
  const CreateCategory(this._repo);

  final CategoriesRepository _repo;

  /// Invokes the use case.
  Future<void> call(Category category) async {
    if (category.isSystem) {
      throw const ValidationFailure('Cannot create system categories from app');
    }
    if (category.name.trim().isEmpty) {
      throw const ValidationFailure(
        'Category name is required',
        fieldErrors: <String, List<String>>{
          'name': <String>['required'],
        },
      );
    }
    await _repo.upsert(category);
  }
}
