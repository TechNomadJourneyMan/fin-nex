import '../repositories/analytics_repository.dart';
import '../values/ulid.dart';

/// Computes a 0–100 Financial Wellness Score.
///
/// Heuristic blend: 60 × savings_rate + 40 × (1 - expense_to_income_var).
/// The exact formula is intentionally simple — UX spec §6 calls for a
/// "directional" score, not an absolute benchmark.
class CalculateFinancialWellness {
  /// Default constructor.
  const CalculateFinancialWellness(this._analytics);

  final AnalyticsRepository _analytics;

  /// Invokes the use case.
  Future<int> call(Ulid userId) async {
    final summary = await _analytics.dashboardSummary(userId);
    final rate = summary.savingsRate.clamp(-1.0, 1.0);
    final normalized = (rate + 1) / 2; // 0..1
    final score = (normalized * 100).round();
    if (score < 0) {
      return 0;
    }
    if (score > 100) {
      return 100;
    }
    return score;
  }
}
