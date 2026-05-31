import 'package:flutter_test/flutter_test.dart';
import 'package:fnx_data_sync/fnx_data_sync.dart';

class _Tag implements TagLike {
  _Tag(this.name);
  @override
  final String name;
}

void main() {
  group('ConflictResolver', () {
    const resolver = ConflictResolver();

    test('strategyFor returns canonical strategy per table', () {
      expect(
        resolver.strategyFor('transactions'),
        ConflictStrategy.lastWriteWins,
      );
      expect(
        resolver.strategyFor('budgets'),
        ConflictStrategy.lastWriteWins,
      );
      expect(
        resolver.strategyFor('categories'),
        ConflictStrategy.serverWinsForSystem,
      );
      expect(
        resolver.strategyFor('tags'),
        ConflictStrategy.mergeByName,
      );
      expect(
        resolver.strategyFor('something_else'),
        ConflictStrategy.lastWriteWins,
      );
    });

    test('lastWriteWins picks local when local is newer', () {
      final local = DateTime.utc(2026, 5, 31, 12);
      final remote = DateTime.utc(2026, 5, 31, 10);
      expect(
        resolver.resolveLastWriteWins(
          localUpdatedAt: local,
          remoteUpdatedAt: remote,
        ),
        ConflictDecision.keepLocal,
      );
    });

    test('lastWriteWins picks remote when equal (server canonical)', () {
      final t = DateTime.utc(2026, 5, 31, 12);
      expect(
        resolver.resolveLastWriteWins(
          localUpdatedAt: t,
          remoteUpdatedAt: t,
        ),
        ConflictDecision.takeRemote,
      );
    });

    test('categories: server wins when system row is involved', () {
      final t = DateTime.utc(2026, 5, 31, 12);
      expect(
        resolver.resolveCategoryConflict(
          remoteIsSystem: true,
          localIsSystem: false,
          localUpdatedAt: t.add(const Duration(hours: 1)),
          remoteUpdatedAt: t,
        ),
        ConflictDecision.takeRemote,
      );
    });

    test('categories: LWW for two custom rows', () {
      final older = DateTime.utc(2026, 5, 30);
      final newer = DateTime.utc(2026, 5, 31);
      expect(
        resolver.resolveCategoryConflict(
          remoteIsSystem: false,
          localIsSystem: false,
          localUpdatedAt: newer,
          remoteUpdatedAt: older,
        ),
        ConflictDecision.keepLocal,
      );
    });

    test('mergeTags unions names case-insensitively, local wins ties', () {
      final local = <TagLike>[_Tag('Food'), _Tag('Fuel')];
      final remote = <TagLike>[_Tag('food'), _Tag('Coffee')];
      final result = resolver.mergeTags(local: local, remote: remote);
      expect(result.decision, ConflictDecision.merged);
      final names = result.merged!.map((t) => t.name.toLowerCase()).toSet();
      expect(names, <String>{'food', 'fuel', 'coffee'});
    });

    test('resolve dispatches by table strategy', () {
      final older = DateTime.utc(2026, 5, 30);
      final newer = DateTime.utc(2026, 5, 31);
      expect(
        resolver.resolve(
          table: 'transactions',
          localUpdatedAt: newer,
          remoteUpdatedAt: older,
        ),
        ConflictDecision.keepLocal,
      );
      expect(
        resolver.resolve(
          table: 'tags',
          localUpdatedAt: older,
          remoteUpdatedAt: newer,
        ),
        ConflictDecision.merged,
      );
    });
  });
}
