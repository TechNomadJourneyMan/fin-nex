import '../repositories/auth_repository.dart';

/// Signs the user in via Apple identity token.
class SignInApple {
  /// Default constructor.
  const SignInApple(this._repo);

  final AuthRepository _repo;

  /// Invokes the use case.
  Future<AuthSession> call({required String identityToken}) =>
      _repo.signInWithApple(identityToken: identityToken);
}
