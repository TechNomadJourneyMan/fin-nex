import '../failures/failure.dart';
import '../repositories/auth_repository.dart';

/// Verifies a one-time code and returns a session.
class VerifyOtp {
  /// Default constructor.
  const VerifyOtp(this._repo);

  final AuthRepository _repo;

  /// Invokes the use case.
  Future<AuthSession> call({
    required String identifier,
    required String code,
  }) async {
    if (code.length < 4) {
      throw const ValidationFailure(
        'OTP code must be at least 4 digits',
        fieldErrors: <String, List<String>>{
          'code': <String>['too_short'],
        },
      );
    }
    return _repo.verifyOtp(identifier: identifier, code: code);
  }
}
