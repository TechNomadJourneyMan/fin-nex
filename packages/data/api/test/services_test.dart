import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pf_data_api/pf_data_api.dart';

import '_mock_adapter.dart';

Dio _buildDio(MockHttpAdapter adapter) {
  final dio = DioFactory.create(
    config: const ApiConfig(baseUrl: 'https://api.finnex.kz/v1'),
    getAccessToken: () async => 'tok',
    onRefresh: () async => null,
    getDeviceId: () async => 'dev_test',
  );
  dio.httpClientAdapter = adapter;
  return dio;
}

void main() {
  group('TransactionsService', () {
    test('list parses cursor pagination', () async {
      final adapter = MockHttpAdapter();
      adapter.onRequest(
        'GET',
        '/transactions',
        (_) => MockResponse.json(200, <String, dynamic>{
          'data': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'tx_1',
              'account_id': 'acc_1',
              'type': 'expense',
              'amount_minor': 350000,
              'currency': 'KZT',
              'occurred_at': '2026-05-30T12:00:00.000Z',
              'description': 'Coffee',
            },
          ],
          'pagination': <String, dynamic>{
            'next_cursor': 'CURSOR_2',
            'has_more': true,
            'limit': 50,
          },
        }),
      );
      final dio = _buildDio(adapter);
      final svc = TransactionsService(dio);
      final page = await svc.list(limit: 50);
      expect(page.data, hasLength(1));
      expect(page.data.first.id, 'tx_1');
      expect(page.data.first.amountMinor, 350000);
      expect(page.pagination.nextCursor, 'CURSOR_2');
      expect(page.pagination.hasMore, true);
    });

    test('create sends the request body and parses response', () async {
      final adapter = MockHttpAdapter();
      adapter.onRequest('POST', '/transactions', (RecordedRequest req) {
        expect(req.body?['amount_minor'], 100);
        expect(req.body?['type'], 'expense');
        return MockResponse.json(201, <String, dynamic>{
          'id': 'tx_new',
          'account_id': 'acc_1',
          'type': 'expense',
          'amount_minor': 100,
          'currency': 'KZT',
          'occurred_at': '2026-05-30T12:00:00.000Z',
          'revision': 1,
        });
      });
      final dio = _buildDio(adapter);
      final svc = TransactionsService(dio);
      final result = await svc.create(
        CreateTransactionRequest(
          clientId: 'ctx_1',
          accountId: 'acc_1',
          type: 'expense',
          amountMinor: 100,
          currency: 'KZT',
          occurredAt: DateTime.utc(2026, 5, 30, 12),
        ),
      );
      expect(result.id, 'tx_new');
      expect(result.revision, 1);
    });
  });

  group('AuthService', () {
    test('signIn returns tokens and skips Authorization header', () async {
      final adapter = MockHttpAdapter();
      adapter.onRequest('POST', '/auth/sign-in', (RecordedRequest req) {
        expect(req.headers.containsKey('Authorization'), false);
        expect(req.body?['method'], 'phone');
        return MockResponse.json(200, <String, dynamic>{
          'access_token': 'jwt-xyz',
          'refresh_token': 'rft_xyz',
          'expires_in': 900,
          'token_type': 'Bearer',
          'user': <String, dynamic>{
            'id': 'usr_1',
            'phone': '+77011234567',
          },
        });
      });
      final dio = _buildDio(adapter);
      final svc = AuthService(dio);
      final res = await svc.signIn(
        const SignInRequest(method: AuthMethod.phone, phone: '+77011234567'),
      );
      expect(res.tokens.accessToken, 'jwt-xyz');
      expect(res.user?.id, 'usr_1');
    });

    test('maps 401 to AuthFailure via the error mapper', () async {
      final adapter = MockHttpAdapter();
      adapter.onRequest(
        'POST',
        '/auth/sign-in',
        (_) => MockResponse.problem(401, 'INVALID_OTP', 'Wrong code'),
      );
      final dio = _buildDio(adapter);
      final svc = AuthService(dio);
      Object? caught;
      try {
        await svc.signIn(const SignInRequest(method: AuthMethod.phone));
      } catch (e) {
        caught = e;
      }
      expect(caught, isA<ApiException>());
      final failure = failureFromApiException(caught! as ApiException);
      expect(failure, isA<AuthFailure>());
    });
  });

  group('IdempotencyInterceptor', () {
    test('generates a v4 UUID for POSTs without an explicit key', () async {
      final adapter = MockHttpAdapter();
      adapter.onRequest(
        'POST',
        '/accounts',
        (_) => MockResponse.json(201, <String, dynamic>{
          'id': 'acc_1',
          'name': 'Cash',
          'type': 'cash',
          'currency': 'KZT',
          'balance_minor': 0,
        }),
      );
      final dio = _buildDio(adapter);
      final svc = AccountsService(dio);
      await svc.create(const CreateAccountRequest(
        name: 'Cash',
        type: 'cash',
        currency: 'KZT',
      ));
      final key =
          adapter.recorded.single.headers['X-Idempotency-Key'] as String?;
      expect(key, isNotNull);
      // UUID v4 format check.
      final regex = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      );
      expect(regex.hasMatch(key!), true, reason: 'got $key');
    });
  });
}
