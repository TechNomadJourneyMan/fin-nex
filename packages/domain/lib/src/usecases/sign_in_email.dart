import '../failures/failure.dart';
import '../repositories/auth_repository.dart';

/// Signs the user in with email + password.
class SignInEmail {
  /// Default constructor.
  const SignInEmail(this._repo);

  final AuthRepository _repo;

  /// Invokes the use case.
  Future<AuthSession> call({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || !email.contains('@')) {
      throw const ValidationFailure(
        'Invalid email',
        fieldErrors: <String, List<String>>{
          'email': <String>['invalid'],
        },
      );
    }
    if (password.length < 8) {
      throw const ValidationFailure(
        'Password too short',
        fieldErrors: <String, List<String>>{
          'password': <String>['too_short'],
        },
      );
    }
    return _repo.signInWithEmail(email: email, password: password);
  }
}
