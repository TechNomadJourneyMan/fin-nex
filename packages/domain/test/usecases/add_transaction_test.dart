import 'package:fnx_domain/domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../_fixtures.dart';

class _MockRepo extends Mock implements TransactionsRepository {}

class _FakeTx extends Fake implements Transaction {}

void main() {
  setUpAll(() => registerFallbackValue(_FakeTx()));

  group('AddTransaction', () {
    late _MockRepo repo;
    late AddTransaction uc;

    setUp(() {
      repo = _MockRepo();
      uc = AddTransaction(repo);
      when(() => repo.upsert(any())).thenAnswer((_) async {});
    });

    test('persists a valid transaction', () async {
      final tx = Fixtures.expense(id: Ulid.now());
      await uc.call(tx);
      verify(() => repo.upsert(tx)).called(1);
    });

    test('rejects zero amount', () async {
      final tx = Fixtures.expense(
        id: Ulid.now(),
        amount: Money.zero(Currency.kzt),
      );
      await expectLater(uc.call(tx), throwsA(isA<ValidationFailure>()));
      verifyNever(() => repo.upsert(any()));
    });
  });
}
