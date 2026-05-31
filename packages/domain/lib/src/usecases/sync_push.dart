import '../repositories/sync_repository.dart';

/// Pushes any locally-dirty rows to the backend.
class SyncPush {
  /// Default constructor.
  const SyncPush(this._repo);

  final SyncRepository _repo;

  /// Invokes the use case.
  Future<SyncResult> call() => _repo.push();
}
