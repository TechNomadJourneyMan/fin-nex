import '../repositories/auth_repository.dart';

/// Starts the 30-day account-deletion cool-off.
class DeleteAccount {
  /// Default constructor.
  const DeleteAccount(this._repo);

  final AuthRepository _repo;

  /// Invokes the use case.
  Future<void> call() => _repo.requestAccountDeletion();
}
