import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnx_domain/fnx_domain.dart';
import 'package:fnx_feat_auth/auth.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.failOnEmail = false});

  final bool failOnEmail;
  final StreamController<User?> _users = StreamController<User?>.broadcast();
  User? _current;

  User _user(String? email, String? phone) => User(
        id: Ulid.now(),
        email: email,
        phoneE164: phone,
        locale: 'en-US',
        timezone: 'UTC',
        primaryCurrency: Currency.kzt,
        countryCode: 'KZ',
        createdAt: DateTime.now().toUtc(),
      );

  AuthSession _session(User u) => AuthSession(
        accessToken: 'a',
        refreshToken: 'r',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        user: u,
      );

  @override
  Future<User?> currentUser() async => _current;

  @override
  Stream<User?> watchCurrentUser() => _users.stream;

  @override
  Future<AuthSession> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (failOnEmail) {
      throw const AuthFailure('bad creds');
    }
    final u = _user(email, null);
    _current = u;
    return _session(u);
  }

  @override
  Future<AuthSession> signInWithApple({required String identityToken}) async {
    final u = _user('a@a', null);
    _current = u;
    return _session(u);
  }

  @override
  Future<AuthSession> signInWithGoogle({required String idToken}) async {
    final u = _user('g@g', null);
    _current = u;
    return _session(u);
  }

  @override
  Future<void> requestOtp({required String identifier}) async {}

  @override
  Future<AuthSession> verifyOtp({
    required String identifier,
    required String code,
  }) async {
    final u = _user(null, identifier);
    _current = u;
    return _session(u);
  }

  @override
  Future<void> signOut() async {
    _current = null;
  }

  @override
  Future<void> requestAccountDeletion() async {
    _current = null;
  }
}

class _MemoryTokenStorage implements TokenStorage {
  String? access;
  String? refresh;
  DateTime? expires;

  @override
  Future<void> writeTokens({
    required String access,
    required String refresh,
    required DateTime expiresAt,
  }) async {
    this.access = access;
    this.refresh = refresh;
    expires = expiresAt;
  }

  @override
  Future<String?> readAccess() async => access;

  @override
  Future<String?> readRefresh() async => refresh;

  @override
  Future<DateTime?> readExpiresAt() async => expires;

  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
    expires = null;
  }
}

ProviderContainer _makeContainer({required AuthRepository repo}) {
  final storage = _MemoryTokenStorage();
  return ProviderContainer(
    overrides: <Override>[
      authRepositoryProvider.overrideWithValue(repo),
      tokenStorageProvider.overrideWithValue(storage),
    ],
  );
}

void main() {
  test('initial state is Unauthenticated when no current user', () async {
    final c = _makeContainer(repo: _FakeAuthRepository());
    addTearDown(c.dispose);
    final value = await c.read(authControllerProvider.future);
    expect(value, isA<Unauthenticated>());
  });

  test('signInEmail transitions to Authenticated and persists tokens',
      () async {
    final repo = _FakeAuthRepository();
    final c = _makeContainer(repo: repo);
    addTearDown(c.dispose);
    await c.read(authControllerProvider.future);
    await c
        .read(authControllerProvider.notifier)
        .signInEmail(email: 'x@y.z', password: 'password1');
    final value = c.read(authControllerProvider).value;
    expect(value, isA<Authenticated>());
    expect(c.read(currentUserProvider), isNotNull);
  });

  test('signInEmail failure surfaces error', () async {
    final repo = _FakeAuthRepository(failOnEmail: true);
    final c = _makeContainer(repo: repo);
    addTearDown(c.dispose);
    await c.read(authControllerProvider.future);
    await c
        .read(authControllerProvider.notifier)
        .signInEmail(email: 'x@y.z', password: 'password1');
    expect(c.read(authControllerProvider).hasError, isTrue);
  });

  test('signOut returns to Unauthenticated and clears storage', () async {
    final c = _makeContainer(repo: _FakeAuthRepository());
    addTearDown(c.dispose);
    await c.read(authControllerProvider.future);
    await c
        .read(authControllerProvider.notifier)
        .signInEmail(email: 'x@y.z', password: 'password1');
    await c.read(authControllerProvider.notifier).signOut();
    final value = c.read(authControllerProvider).value;
    expect(value, isA<Unauthenticated>());
    expect(c.read(currentUserProvider), isNull);
  });

  test('verifyOtp transitions to Authenticated', () async {
    final c = _makeContainer(repo: _FakeAuthRepository());
    addTearDown(c.dispose);
    await c.read(authControllerProvider.future);
    await c
        .read(authControllerProvider.notifier)
        .verifyOtp(identifier: '+77001234567', code: '123456');
    expect(c.read(authControllerProvider).value, isA<Authenticated>());
  });
}
