import 'package:flutter_test/flutter_test.dart';
import 'package:fnx_data_local/fnx_data_local.dart';

void main() {
  test('fnx_data_local barrel exports the public surface', () {
    // Pure compile-time check: importing the symbols below proves the barrel
    // re-exports the database, DAOs, models, and repositories.
    expect(FnxSchema.version, 1);
    expect(SyncState.fromString('synced'), SyncState.synced);
    expect(SyncOp.fromString('upsert'), SyncOp.upsert);
    expect(SystemCategoriesSeed.all().length, 28);
  });
}
