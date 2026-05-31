import '../entities/insight.dart';
import '../repositories/insights_repository.dart';
import '../values/ulid.dart';

/// Pulls the latest active insights for the dashboard cards strip.
class GenerateInsights {
  /// Default constructor.
  const GenerateInsights(this._repo);

  final InsightsRepository _repo;

  /// Invokes the use case.
  Future<List<Insight>> call(Ulid userId) => _repo.listActive(userId);
}
