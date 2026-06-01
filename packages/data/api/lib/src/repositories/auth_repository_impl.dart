import 'package:pf_domain/pf_domain.dart';

import '../dto/auth_dto.dart';
import '../error_mapper.dart';
import '../exceptions/api_exception.dart';
import '../services/auth_service.dart';

/// Result of an authentication operation; either tokens (+optional user) or a
/// domain [Failure].
class AuthResult {
  /// Success.
  const AuthResult.success(this.response) : failure = null;

  /// Failure.
  const AuthResult.failure(this.failure) : response = null;

  /// Tokens on success.
  final SignInResponse? response;

  /// Failure on error.
  final Failure? failure;

  /// True when this is a success.
  bool get isSuccess => response != null;
}

/// Concrete remote auth repository. Returns [Failure] subclasses for
/// caller-visible errors, swallowing transport details.
///
/// TODO(F-AUTH-01): once `pf_domain` exposes an `AuthRepository` interface
/// this class should `implements` it.
class AuthRepositoryImpl {
  /// Default constructor.
  AuthRepositoryImpl(this._service);

  final AuthService _service;

  /// Sign in.
  Future<AuthResult> signIn(SignInRequest request) async {
    try {
      final res = await _service.signIn(request);
      return AuthResult.success(res);
    } on ApiException catch (e) {
      return AuthResult.failure(failureFromApiException(e));
    }
  }

  /// Sign up.
  Future<AuthResult> signUp(SignUpRequest request) async {
    try {
      final res = await _service.signUp(request);
      return AuthResult.success(res);
    } on ApiException catch (e) {
      return AuthResult.failure(failureFromApiException(e));
    }
  }

  /// Request OTP.
  Future<OtpRequestResponse> requestOtp(OtpRequestRequest request) =>
      _service.requestOtp(request);

  /// Verify OTP.
  Future<AuthResult> verifyOtp(OtpVerifyRequest request) async {
    try {
      final res = await _service.verifyOtp(request);
      return AuthResult.success(res);
    } on ApiException catch (e) {
      return AuthResult.failure(failureFromApiException(e));
    }
  }

  /// Refresh.
  Future<AuthTokensDto?> refresh(String refreshToken) async {
    try {
      return await _service.refresh(refreshToken);
    } on ApiException {
      return null;
    }
  }

  /// Sign out.
  Future<void> signOut() async {
    try {
      await _service.signOut();
    } on ApiException {
      // Best-effort; local session is the source of truth on logout.
    }
  }
}
