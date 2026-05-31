import '../failures/failure.dart';
import '../repositories/auth_repository.dart';

/// Requests a one-time code by email or SMS.
class RequestOtp {
  /// Default constructor.
  const RequestOtp(this._repo);

  final AuthRepository _repo;

  /// Invokes the use case.
  Future<void> call({required String identifier}) async {
    if (identifier.trim().isEmpty) {
      throw const ValidationFailure(
        'Email or phone is required',
        fieldErrors: <String, List<String>>{
          'identifier': <String>['required'],
        },
      );
    }
    await _repo.requestOtp(identifier: identifier);
  }
}
