import '../entities/insight.dart';
import '../values/ulid.dart';

/// Persistence and query contract for [Insight].
abstract interface class InsightsRepository {
  /// Live list of active insights for [userId].
  Stream<List<Insight>> watchActive(Ulid userId);

  /// Snapshot list of active insights.
  Future<List<Insight>> listActive(Ulid userId);

  /// Marks [id] as dismissed.
  Future<void> dismiss(Ulid id);

  /// Marks [id] as acted-upon.
  Future<void> markActed(Ulid id);
}
