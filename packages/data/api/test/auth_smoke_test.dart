import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pf_data_api/pf_data_api.dart';
import 'package:pf_domain/pf_domain.dart';

import '_mock_adapter.dart';

void main() {
  group('Auth sign-in smoke test', () {
    late MockHttpAdapter adapter;
    late Dio dio;

    setUp(() {
      adapter = MockHttpAdapter();
      dio = DioFactory.create(
        config: const ApiConfig(baseUrl: 'https://api.example.com/v1'),
        getAccessToken: () async => null,
        onRefresh: () async => null,
        getDeviceId: () async => 'dev_smoke',
      );
      dio.httpClientAdapter = adapter;
    });

    test('AuthService.signIn posts the expected body and decodes tokens',
        () async {
      RecordedRequest? captured;
      adapter.onRequest('POST', '/auth/sign-in', (RecordedRequest req) {
        captured = req;
        return MockResponse.json(200, <String, dynamic>{
          'access_token': 'acc_123',
          'refresh_token': 'ref_456',
          'expires_in': 3600,
          'token_type': 'Bearer',
          'user': <String, dynamic>{
            'id': '01HZY0000000000000000000AB',
            'phone': '+77011234567',
            'display_name': 'Smoke Tester',
            'currency_primary': 'KZT',
          },
        });
      });

      final res = await AuthService(dio).signIn(
        const SignInRequest(
          method: AuthMethod.phone,
          phone: '+77011234567',
          locale: 'ru-KZ',
        ),
      );

      // Body shape sent to the backend.
      expect(captured, isNotNull);
      expect(captured!.body, <String, dynamic>{
        'method': 'phone',
        'phone': '+77011234567',
        'locale': 'ru-KZ',
      });
      // sign-in must NOT carry an Authorization header.
      expect(captured!.headers.containsKey('Authorization'), isFalse);

      // Decoded response.
      expect(res.tokens.accessToken, 'acc_123');
      expect(res.tokens.refreshToken, 'ref_456');
      expect(res.tokens.expiresIn, 3600);
      expect(res.user?.phone, '+77011234567');
    });

    test('HttpAuthRepository decodes sign-in into an AuthSession and persists',
        () async {
      adapter.onRequest('POST', '/auth/sign-in', (_) {
        return MockResponse.json(200, <String, dynamic>{
          'access_token': 'acc_abc',
          'refresh_token': 'ref_def',
          'expires_in': 7200,
          'token_type': 'Bearer',
          'user': <String, dynamic>{
            'id': '01HZY0000000000000000000AB',
            'email': 'tester@example.com',
            'currency_primary': 'USD',
          },
        });
      });

      AuthSession? persisted;
      final repo = HttpAuthRepository(
        AuthService(dio),
        onPersist: (AuthSession s) => persisted = s,
      );

      final session = await repo.signInWithEmail(
        email: 'tester@example.com',
        password: 'unused-by-mock',
      );

      expect(session.accessToken, 'acc_abc');
      expect(session.refreshToken, 'ref_def');
      // expiresAt derived from expires_in (no server expires_at supplied).
      expect(session.expiresAt.isAfter(DateTime.now().toUtc()), isTrue);
      expect(session.user.email, 'tester@example.com');
      expect(session.user.primaryCurrency, Currency.usd);

      // Persistence callback fired with the same session.
      expect(persisted, same(session));

      // watchCurrentUser emits the signed-in user.
      expect(await repo.currentUser(), isNotNull);

      repo.dispose();
    });

    test('HttpAuthRepository maps backend failures to domain Failure',
        () async {
      adapter.onRequest('POST', '/auth/sign-in', (_) {
        return MockResponse.problem(404, 'USER_NOT_FOUND', 'User not found');
      });

      final repo = HttpAuthRepository(AuthService(dio));

      await expectLater(
        repo.signInWithGoogle(idToken: 'bad'),
        throwsA(isA<Failure>()),
      );

      repo.dispose();
    });
  });
}
