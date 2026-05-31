import '../repositories/analytics_repository.dart';
import '../values/ulid.dart';

/// Returns the dashboard summary tile data.
class GetDashboardSummary {
  /// Default constructor.
  const GetDashboardSummary(this._repo);

  final AnalyticsRepository _repo;

  /// Invokes the use case.
  Future<DashboardSummary> call(Ulid userId) => _repo.dashboardSummary(userId);
}
