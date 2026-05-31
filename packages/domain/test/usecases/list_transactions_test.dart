import 'package:fnx_domain/domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../_fixtures.dart';

class _MockRepo extends Mock implements TransactionsRepository {}

class _FakeFilter extends Fake implements TransactionFilter {}

void main() {
  setUpAll(() => registerFallbackValue(_FakeFilter()));

  test('ListTransactions delegates to the repo', () async {
    final repo = _MockRepo();
    final tx = Fixtures.expense(id: Ulid.now());
    when(() => repo.list(Fixtures.userId, any()))
        .thenAnswer((_) async => <Transaction>[tx]);

    final result = await ListTransactions(repo).call(Fixtures.userId);

    expect(result, <Transaction>[tx]);
    verify(() => repo.list(Fixtures.userId, any())).called(1);
  });
}
