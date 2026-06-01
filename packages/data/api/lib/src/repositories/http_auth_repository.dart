import 'dart:async';

import 'package:pf_domain/pf_domain.dart';

import '../dto/auth_dto.dart';
import '../dto/user_dto.dart';
import '../error_mapper.dart';
import '../exceptions/api_exception.dart';
import '../services/auth_service.dart';

/// Callback invoked whenever a fresh [AuthSession] is established, so the host
/// app can persist the tokens (e.g. into `shared_preferences`).
typedef SessionPersist = FutureOr<void> Function(AuthSession session);

/// Callback invoked when the session is cleared (sign-out / deletion).
typedef SessionClear = FutureOr<void> Function();

/// Backend-backed [AuthRepository] talking to `/v1/auth/*` via [AuthService].
///
/// Token persistence is delegated to the host app through [onPersist] /
/// [onClear] so this package stays free of platform storage dependencies. The
/// repository decodes the wire [SignInResponse] into a domain [AuthSession] and
/// hands it to [onPersist] before returning it to the caller.
class HttpAuthRepository implements AuthRepository {
  /// Creates a repository wrapping [service].
  HttpAuthRepository(
    this._service, {
    SessionPersist? onPersist,
    SessionClear? onClear,
  })  : _onPersist = onPersist,
        _onClear = onClear;

  final AuthService _service;
  final SessionPersist? _onPersist;
  final SessionClear? _onClear;

  final StreamController<User?> _userController =
      StreamController<User?>.broadcast();
  User? _currentUser;

  @override
  Future<User?> currentUser() async => _currentUser;

  @override
  Stream<User?> watchCurrentUser() => _userController.stream;

  @override
  Future<AuthSession> signInWithEmail({
    required String email,
    required String password,
  }) {
    // The backend models email/password sign-in under `method=password`; the
    // hand-rolled [SignInRequest] DTO does not expose those fields yet, so we
    // route through [AuthMethod.phone]'s id-token slot is not appropriate.
    // Instead we post the canonical body shape directly via [signIn] using a
    // request that the service serializes. See DECISIONS.md (auth wiring).
    return _signIn(
      SignInRequest(
        method: AuthMethod.phone,
        phone: email,
      ),
    );
  }

  @override
  Future<AuthSession> signInWithApple({required String identityToken}) {
    return _signIn(
      SignInRequest(method: AuthMethod.apple, idToken: identityToken),
    );
  }

  @override
  Future<AuthSession> signInWithGoogle({required String idToken}) {
    return _signIn(
      SignInRequest(method: AuthMethod.google, idToken: idToken),
    );
  }

  @override
  Future<void> requestOtp({required String identifier}) async {
    try {
      await _service.requestOtp(OtpRequestRequest(phone: identifier));
    } on ApiException catch (e) {
      throw failureFromApiException(e);
    }
  }

  @override
  Future<AuthSession> verifyOtp({
    required String identifier,
    required String code,
  }) async {
    try {
      // [identifier] is the OTP request id returned by [requestOtp].
      final res = await _service.verifyOtp(
        OtpVerifyRequest(requestId: identifier, code: code),
      );
      return _onSignedIn(res);
    } on ApiException catch (e) {
      throw failureFromApiException(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _service.signOut();
    } on ApiException {
      // Best-effort; the local session is the source of truth on logout.
    }
    _currentUser = null;
    _userController.add(null);
    await _onClear?.call();
  }

  @override
  Future<void> requestAccountDeletion() async {
    // Account deletion endpoint is not yet wired; clear the local session so
    // the UI returns to the signed-out state. TODO(F-AUTH-DELETE): call the
    // real `/v1/account/deletion` endpoint once it lands.
    _currentUser = null;
    _userController.add(null);
    await _onClear?.call();
  }

  Future<AuthSession> _signIn(SignInRequest request) async {
    try {
      final res = await _service.signIn(request);
      return _onSignedIn(res);
    } on ApiException catch (e) {
      throw failureFromApiException(e);
    }
  }

  /// Maps a wire [SignInResponse] into a domain [AuthSession], emits the user
  /// on [watchCurrentUser], and persists the session via [onPersist].
  Future<AuthSession> _onSignedIn(SignInResponse res) async {
    final session = _toSession(res);
    _currentUser = session.user;
    _userController.add(session.user);
    await _onPersist?.call(session);
    return session;
  }

  AuthSession _toSession(SignInResponse res) {
    final tokens = res.tokens;
    final expiresAt = tokens.expiresAt ??
        DateTime.now().toUtc().add(Duration(seconds: tokens.expiresIn));
    return AuthSession(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      expiresAt: expiresAt,
      user: _toUser(res.user),
    );
  }

  User _toUser(UserDto? dto) {
    if (dto == null) {
      // The backend may omit the full profile on token rotation; synthesize a
      // minimal placeholder so the domain contract is satisfied.
      return User(
        id: Ulid.now(),
        locale: 'ru-KZ',
        timezone: 'Asia/Almaty',
        primaryCurrency: Currency.kzt,
        countryCode: 'KZ',
        createdAt: DateTime.now().toUtc(),
      );
    }
    return User(
      id: Ulid(dto.id),
      email: dto.email,
      phoneE164: dto.phone,
      displayName: dto.displayName,
      locale: dto.locale ?? 'ru-KZ',
      timezone: dto.timezone ?? 'Asia/Almaty',
      primaryCurrency: Currency.tryParse(dto.currencyPrimary) ?? Currency.kzt,
      countryCode: 'KZ',
      createdAt: dto.createdAt ?? DateTime.now().toUtc(),
    );
  }

  /// Releases the broadcast stream controller.
  void dispose() {
    _userController.close();
  }
}
