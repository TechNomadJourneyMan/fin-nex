import '../repositories/insights_repository.dart';
import '../values/ulid.dart';

/// Marks an insight card as dismissed.
class DismissInsight {
  /// Default constructor.
  const DismissInsight(this._repo);

  final InsightsRepository _repo;

  /// Invokes the use case.
  Future<void> call(Ulid id) => _repo.dismiss(id);
}
