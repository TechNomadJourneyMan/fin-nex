import 'package:fnx_domain/domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockInsights extends Mock implements InsightsRepository {}

void main() {
  test('DismissInsight forwards id to repo', () async {
    final repo = _MockInsights();
    final id = Ulid.now();
    when(() => repo.dismiss(id)).thenAnswer((_) async {});

    await DismissInsight(repo).call(id);

    verify(() => repo.dismiss(id)).called(1);
  });
}
