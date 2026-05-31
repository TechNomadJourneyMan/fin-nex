import 'package:fnx_domain/domain.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockSync extends Mock implements SyncRepository {}

void main() {
  final result = SyncResult(
    pushed: 1,
    pulled: 2,
    conflicts: 0,
    startedAt: DateTime.utc(2026, 5, 31, 10),
    completedAt: DateTime.utc(2026, 5, 31, 10, 0, 5),
  );

  test('SyncPush forwards to repo', () async {
    final repo = _MockSync();
    when(() => repo.push()).thenAnswer((_) async => result);
    expect(await SyncPush(repo).call(), result);
  });

  test('SyncPull forwards to repo', () async {
    final repo = _MockSync();
    when(() => repo.pull()).thenAnswer((_) async => result);
    expect(await SyncPull(repo).call(), result);
  });
}
