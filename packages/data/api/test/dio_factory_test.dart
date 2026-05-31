import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnx_data_api/fnx_data_api.dart';

import '_mock_adapter.dart';

void main() {
  group('DioFactory', () {
    late MockHttpAdapter adapter;
    late Dio dio;

    setUp(() {
      adapter = MockHttpAdapter();
      dio = DioFactory.create(
        config: const ApiConfig(baseUrl: 'https://api.finnex.kz/v1'),
        getAccessToken: () async => 'token-abc',
        onRefresh: () async => 'token-new',
        getDeviceId: () async => 'dev_test',
      );
      dio.httpClientAdapter = adapter;
    });

    test('adds auth, device id, and idempotency headers on POST', () async {
      adapter.onRequest(
        'POST',
        '/transactions',
        (_) => MockResponse.json(201, <String, dynamic>{
          'id': 'tx_1',
          'account_id': 'acc_1',
          'type': 'expense',
          'amount_minor': 100,
          'currency': 'KZT',
          'occurred_at': '2026-05-30T12:00:00.000Z',
        }),
      );

      await dio.post<dynamic>(
        '/transactions',
        data: <String, dynamic>{'foo': 'bar'},
      );

      final req = adapter.recorded.single;
      expect(req.headers['Authorization'], 'Bearer token-abc');
      expect(req.headers['X-Device-Id'], 'dev_test');
      expect(req.headers['X-Idempotency-Key'], isNotEmpty);
      expect(req.headers['X-Client-Version'], isNotNull);
    });

    test('parses Problem Details into ApiException', () async {
      adapter.onRequest(
        'GET',
        '/accounts/acc_missing',
        (_) => MockResponse.problem(404, 'ACCOUNT_NOT_FOUND', 'No such acc'),
      );

      Object? caught;
      try {
        await dio.get<dynamic>('/accounts/acc_missing');
      } catch (e) {
        caught = e;
      }
      expect(caught, isA<DioException>());
      final inner = (caught! as DioException).error;
      expect(inner, isA<ApiException>());
      final api = inner! as ApiException;
      expect(api.statusCode, 404);
      expect(api.code, 'ACCOUNT_NOT_FOUND');
      expect(api.problem?.detail, 'No such acc');
    });

    test('refreshes once on 401 and retries the original request', () async {
      var attempt = 0;
      adapter.onRequest('GET', '/me', (RecordedRequest req) {
        attempt += 1;
        if (attempt == 1) {
          return MockResponse.problem(401, 'TOKEN_EXPIRED', 'Expired');
        }
        // Second call should carry the refreshed token.
        expect(req.headers['Authorization'], 'Bearer token-new');
        return MockResponse.json(200, <String, dynamic>{'id': 'usr_1'});
      });

      final res = await dio.get<Map<String, dynamic>>('/me');
      expect(res.statusCode, 200);
      expect(attempt, 2);
    });
  });
}
