import 'package:flutter_test/flutter_test.dart';
import 'package:pf_data_local/pf_data_local.dart';

void main() {
  test('pf_data_local barrel exports the public surface', () {
    // Pure compile-time check: importing the symbols below proves the barrel
    // re-exports the database, DAOs, models, and repositories.
    expect(PfSchema.version, 1);
    expect(SyncState.fromString('synced'), SyncState.synced);
    expect(SyncOp.fromString('upsert'), SyncOp.upsert);
    expect(SystemCategoriesSeed.all().length, 28);
  });
}
