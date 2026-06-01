import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_domain/pf_domain.dart';
import 'package:pf_feat_auth/auth.dart';

class _NoopRepo implements AuthRepository {
  final StreamController<User?> _c = StreamController<User?>.broadcast();
  @override
  Future<User?> currentUser() async => null;
  @override
  Stream<User?> watchCurrentUser() => _c.stream;
  @override
  Future<AuthSession> signInWithEmail({
    required String email,
    required String password,
  }) async =>
      throw UnimplementedError();
  @override
  Future<AuthSession> signInWithApple({required String identityToken}) async =>
      throw UnimplementedError();
  @override
  Future<AuthSession> signInWithGoogle({required String idToken}) async =>
      throw UnimplementedError();
  @override
  Future<void> requestOtp({required String identifier}) async {}
  @override
  Future<AuthSession> verifyOtp({
    required String identifier,
    required String code,
  }) async =>
      throw UnimplementedError();
  @override
  Future<void> signOut() async {}
  @override
  Future<void> requestAccountDeletion() async {}
}

class _MemStorage implements TokenStorage {
  @override
  Future<void> writeTokens({
    required String access,
    required String refresh,
    required DateTime expiresAt,
  }) async {}
  @override
  Future<String?> readAccess() async => null;
  @override
  Future<String?> readRefresh() async => null;
  @override
  Future<DateTime?> readExpiresAt() async => null;
  @override
  Future<void> clear() async {}
}

void main() {
  testWidgets('SignInPage renders email, password, and OAuth buttons',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          authRepositoryProvider.overrideWithValue(_NoopRepo()),
          tokenStorageProvider.overrideWithValue(_MemStorage()),
        ],
        child: MaterialApp(
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: const SignInPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('signin.email')), findsOneWidget);
    expect(
        find.byKey(const ValueKey<String>('signin.password')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('signin.submit')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('signin.google')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('signin.phone')), findsOneWidget);
  });
}
