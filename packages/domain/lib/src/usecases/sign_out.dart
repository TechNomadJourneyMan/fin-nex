import '../repositories/auth_repository.dart';

/// Ends the current session.
class SignOut {
  /// Default constructor.
  const SignOut(this._repo);

  final AuthRepository _repo;

  /// Invokes the use case.
  Future<void> call() => _repo.signOut();
}
