import '../repositories/analytics_repository.dart';
import '../values/ulid.dart';

/// Returns category breakdown slices for the given period.
class GetCategoryBreakdown {
  /// Default constructor.
  const GetCategoryBreakdown(this._repo);

  final AnalyticsRepository _repo;

  /// Invokes the use case.
  Future<List<CategoryBreakdownSlice>> call(
    Ulid userId, {
    required DateTime from,
    required DateTime to,
  }) =>
      _repo.categoryBreakdown(userId, from: from, to: to);
}
