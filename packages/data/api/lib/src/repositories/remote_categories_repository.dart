import '../dto/category_dto.dart';
import '../services/categories_service.dart';

/// Thin facade over [CategoriesService].
///
/// TODO(F-CAT-01): swap to a domain-defined `CategoriesRepository` once it
/// lands in `pf_domain`.
class RemoteCategoriesRepository {
  /// Default constructor.
  RemoteCategoriesRepository(this._service);

  final CategoriesService _service;

  /// List.
  Future<List<CategoryDto>> list({
    String kind = 'all',
    bool includeSystem = true,
    bool includeUser = true,
  }) =>
      _service.list(
        kind: kind,
        includeSystem: includeSystem,
        includeUser: includeUser,
      );

  /// Create.
  Future<CategoryDto> create(CreateCategoryRequest request) =>
      _service.create(request);

  /// Update.
  Future<CategoryDto> update(
    String id,
    UpdateCategoryRequest request, {
    String? ifMatch,
  }) =>
      _service.update(id, request, ifMatch: ifMatch);

  /// Delete.
  Future<void> delete(String id, {String? reassignTo, String? ifMatch}) =>
      _service.delete(id, reassignTo: reassignTo, ifMatch: ifMatch);
}
