// In-memory stub AuthRepository implementation.
//
// TODO(F-AUTH-WEB): replace with real impl from `pf_data_api` once the
// backend AuthService and dio wiring is finalized. Until then, this stub
// satisfies the domain contract so the UI can be developed end-to-end.

import 'dart:async';

import 'package:pf_domain/pf_domain.dart';

/// Simulated [AuthRepository] backed by an in-memory map.
class StubAuthRepository implements AuthRepository {
  /// Creates a stub repository.
  StubAuthRepository();

  final StreamController<User?> _userController =
      StreamController<User?>.broadcast();
  User? _currentUser;

  /// Returns a deterministic-ish synthetic user for the given identifier.
  User _makeUser({String? email, String? phone}) {
    return User(
      id: Ulid.now(),
      email: email,
      phoneE164: phone,
      displayName: email?.split('@').first ?? phone,
      locale: 'en-US',
      timezone: 'Asia/Almaty',
      primaryCurrency: Currency.kzt,
      countryCode: 'KZ',
      createdAt: DateTime.now().toUtc(),
      emailVerifiedAt: email != null ? DateTime.now().toUtc() : null,
      phoneVerifiedAt: phone != null ? DateTime.now().toUtc() : null,
      lastSeenAt: DateTime.now().toUtc(),
    );
  }

  AuthSession _makeSession(User user) {
    return AuthSession(
      accessToken: 'stub-access-${user.id.value}',
      refreshToken: 'stub-refresh-${user.id.value}',
      expiresAt: DateTime.now().toUtc().add(const Duration(hours: 1)),
      user: user,
    );
  }

  @override
  Future<User?> currentUser() async => _currentUser;

  @override
  Stream<User?> watchCurrentUser() => _userController.stream;

  @override
  Future<AuthSession> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (password.length < 8) {
      throw const ValidationFailure(
        'Password too short',
        fieldErrors: <String, List<String>>{
          'password': <String>['too_short'],
        },
      );
    }
    final user = _makeUser(email: email);
    _currentUser = user;
    _userController.add(user);
    return _makeSession(user);
  }

  @override
  Future<AuthSession> signInWithApple({required String identityToken}) async {
    // TODO(F-AUTH-WEB): wire to real Apple OAuth identity token flow.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final user = _makeUser(email: 'apple.user@privaterelay.appleid.com');
    _currentUser = user;
    _userController.add(user);
    return _makeSession(user);
  }

  @override
  Future<AuthSession> signInWithGoogle({required String idToken}) async {
    // TODO(F-AUTH-WEB): wire to real Google OAuth id_token flow.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final user = _makeUser(email: 'google.user@gmail.com');
    _currentUser = user;
    _userController.add(user);
    return _makeSession(user);
  }

  @override
  Future<void> requestOtp({required String identifier}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<AuthSession> verifyOtp({
    required String identifier,
    required String code,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (code.length != 6 || int.tryParse(code) == null) {
      throw const ValidationFailure(
        'Invalid OTP',
        fieldErrors: <String, List<String>>{
          'code': <String>['invalid'],
        },
      );
    }
    if (code == '000000') {
      throw const AuthFailure('Incorrect code');
    }
    final user = _makeUser(phone: identifier);
    _currentUser = user;
    _userController.add(user);
    return _makeSession(user);
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _userController.add(null);
  }

  @override
  Future<void> requestAccountDeletion() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
    _userController.add(null);
  }
}
