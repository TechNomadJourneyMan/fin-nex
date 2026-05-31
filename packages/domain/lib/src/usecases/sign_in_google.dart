import '../repositories/auth_repository.dart';

/// Signs the user in via Google ID token.
class SignInGoogle {
  /// Default constructor.
  const SignInGoogle(this._repo);

  final AuthRepository _repo;

  /// Invokes the use case.
  Future<AuthSession> call({required String idToken}) =>
      _repo.signInWithGoogle(idToken: idToken);
}
