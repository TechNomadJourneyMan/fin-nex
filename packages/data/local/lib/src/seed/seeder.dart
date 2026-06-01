import 'package:sqflite/sqflite.dart';

import 'system_categories.dart';

/// Idempotent seeding entrypoints for the PocketFlow local database.
///
/// Seeders are safe to invoke multiple times — they use INSERT OR REPLACE on
/// rows that own a stable primary key.
class PfSeeder {
  const PfSeeder._();

  /// Inserts the canonical 28 system categories.
  ///
  /// Re-running this is safe: the seeded rows use stable English IDs and an
  /// `INSERT OR REPLACE` conflict strategy so user-owned categories are never
  /// touched.
  static Future<void> seedSystemCategories(DatabaseExecutor db) async {
    final rows = SystemCategoriesSeed.all();
    final batch = db.batch();
    for (final row in rows) {
      batch.insert(
        'categories',
        row.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
}
