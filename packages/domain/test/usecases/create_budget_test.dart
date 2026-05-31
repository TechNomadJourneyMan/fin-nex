import 'package:fnx_domain/domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../_fixtures.dart';

class _MockRepo extends Mock implements BudgetsRepository {}

class _FakeBudget extends Fake implements Budget {}

void main() {
  setUpAll(() => registerFallbackValue(_FakeBudget()));

  test('CreateBudget rejects zero amount', () async {
    final repo = _MockRepo();
    final b = Fixtures.budget(id: Ulid.now(), amount: Money.zero(Currency.kzt));
    await expectLater(
      CreateBudget(repo).call(b),
      throwsA(isA<ValidationFailure>()),
    );
    verifyNever(() => repo.upsertBudget(any()));
  });

  test('CreateBudget persists a valid budget', () async {
    final repo = _MockRepo();
    final b = Fixtures.budget(id: Ulid.now());
    when(() => repo.upsertBudget(b)).thenAnswer((_) async {});

    await CreateBudget(repo).call(b);

    verify(() => repo.upsertBudget(b)).called(1);
  });
}
