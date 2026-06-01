import 'package:flutter_test/flutter_test.dart';
import 'package:pf_data_sync/pf_data_sync.dart';
import 'package:pf_domain/pf_domain.dart';

void main() {
  group('barrel exports', () {
    test('public types are reachable from the package root', () {
      // Touching each export ensures the barrel resolves under analyzer.
      const status = SyncStatus.idle();
      const resolver = ConflictResolver();
      expect(status, isA<SyncStatus>());
      expect(resolver.strategyFor('transactions'),
          ConflictStrategy.lastWriteWins);
      expect(const Ok<int, NetworkFailure>(1).unwrap(), 1);
    });
  });

  group('SyncStatus equality', () {
    test('values with the same payload compare equal', () {
      expect(const SyncStatus.idle(), const SyncStatus.idle());
      expect(
        const SyncStatus.error('boom'),
        const SyncStatus.error('boom'),
      );
      expect(
        const SyncStatus.conflict(3),
        const SyncStatus.conflict(3),
      );
      expect(
        const SyncStatus.pushing(pending: 5),
        const SyncStatus.pushing(pending: 5),
      );
    });
  });
}
