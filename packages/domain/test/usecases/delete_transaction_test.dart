import 'package:fnx_domain/domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockRepo extends Mock implements TransactionsRepository {}

void main() {
  test('DeleteTransaction calls softDelete on repo', () async {
    final repo = _MockRepo();
    final id = Ulid.now();
    when(() => repo.softDelete(id)).thenAnswer((_) async {});

    await DeleteTransaction(repo).call(id);

    verify(() => repo.softDelete(id)).called(1);
  });
}
