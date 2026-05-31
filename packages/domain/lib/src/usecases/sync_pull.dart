import '../repositories/sync_repository.dart';

/// Pulls server-side changes since the last cursor.
class SyncPull {
  /// Default constructor.
  const SyncPull(this._repo);

  final SyncRepository _repo;

  /// Invokes the use case.
  Future<SyncResult> call() => _repo.pull();
}
