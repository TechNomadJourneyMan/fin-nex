import 'package:fnx_domain/domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../_fixtures.dart';

class _MockRepo extends Mock implements TransactionsRepository {}

class _FakeTx extends Fake implements Transaction {}

void main() {
  setUpAll(() => registerFallbackValue(_FakeTx()));

  late _MockRepo repo;
  late EditTransaction uc;

  setUp(() {
    repo = _MockRepo();
    uc = EditTransaction(repo);
  });

  test('throws when the transaction does not exist', () async {
    final tx = Fixtures.expense(id: Ulid.now());
    when(() => repo.getById(tx.id)).thenAnswer((_) async => null);

    await expectLater(uc.call(tx), throwsA(isA<ValidationFailure>()));
    verifyNever(() => repo.upsert(any()));
  });

  test('persists when the transaction exists', () async {
    final tx = Fixtures.expense(id: Ulid.now());
    when(() => repo.getById(tx.id)).thenAnswer((_) async => tx);
    when(() => repo.upsert(any())).thenAnswer((_) async {});

    await uc.call(tx);

    verify(() => repo.upsert(any(that: isA<Transaction>()))).called(1);
  });
}
