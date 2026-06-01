import 'package:pf_domain/domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockNotif extends Mock implements NotificationsRepository {}

void main() {
  test('MarkNotificationRead forwards id to repo', () async {
    final repo = _MockNotif();
    final id = Ulid.now();
    when(() => repo.markRead(id)).thenAnswer((_) async {});

    await MarkNotificationRead(repo).call(id);

    verify(() => repo.markRead(id)).called(1);
  });
}
