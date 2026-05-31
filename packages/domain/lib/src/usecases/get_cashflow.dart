import '../repositories/analytics_repository.dart';
import '../values/ulid.dart';

/// Returns time-bucketed cashflow for charting.
class GetCashflow {
  /// Default constructor.
  const GetCashflow(this._repo);

  final AnalyticsRepository _repo;

  /// Invokes the use case.
  Future<List<CashflowBucket>> call(
    Ulid userId, {
    required DateTime from,
    required DateTime to,
    int bucketDays = 1,
  }) =>
      _repo.cashflow(userId, from: from, to: to, bucketDays: bucketDays);
}
