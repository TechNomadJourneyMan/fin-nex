/// Outcome of a sync round-trip.
class SyncResult {
  /// Default constructor.
  const SyncResult({
    required this.pushed,
    required this.pulled,
    required this.conflicts,
    required this.startedAt,
    required this.completedAt,
  });

  /// Number of records pushed to the server.
  final int pushed;

  /// Number of records pulled from the server.
  final int pulled;

  /// Number of records that required conflict resolution.
  final int conflicts;

  /// Sync start moment.
  final DateTime startedAt;

  /// Sync completion moment.
  final DateTime completedAt;
}

/// Drives the outbox / pull cursor sync engine.
abstract interface class SyncRepository {
  /// Pushes any locally-dirty records to the server.
  Future<SyncResult> push();

  /// Pulls all server changes since the last cursor.
  Future<SyncResult> pull();

  /// Runs both push and pull in one round-trip.
  Future<SyncResult> roundTrip();

  /// Live stream of sync state changes (e.g. for the menu icon).
  Stream<SyncResult> watch();
}
