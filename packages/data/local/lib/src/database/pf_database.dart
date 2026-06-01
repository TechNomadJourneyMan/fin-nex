import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../schema/schema.dart';
import '../seed/seeder.dart';
import 'factory_stub.dart'
    if (dart.library.io) 'factory_io.dart'
    if (dart.library.html) 'factory_web.dart';

/// Default filename for the application database.
const String kPfDatabaseFilename = 'finnex.db';

/// In-memory broadcaster used by DAOs to publish "table changed" events so
/// repository layers can build `Stream` watchers without polling.
class PfChangeBus {
  final _controller = StreamController<String>.broadcast();

  /// Stream of table names that just received a mutation.
  Stream<String> get stream => _controller.stream;

  /// Stream filtered to mutations on [table].
  Stream<void> watch(String table) =>
      _controller.stream.where((t) => t == table || t == '*').map((_) {});

  /// Emits a change event for [table]. Pass `'*'` to wake all watchers.
  void notify(String table) {
    if (_controller.isClosed) return;
    _controller.add(table);
  }

  /// Releases the underlying stream controller.
  Future<void> dispose() => _controller.close();
}

/// Singleton-style wrapper around the application's SQLite database.
///
/// The class is intentionally lightweight: it owns the [Database] handle, the
/// schema lifecycle (create / migrate), and a [PfChangeBus] used by DAOs to
/// publish change notifications. All higher-level logic lives in the DAOs and
/// repositories that compose on top of this object.
class PfDatabase {
  PfDatabase._(this._db, this.changeBus);

  final Database _db;

  /// Bus used by DAOs to fan out change notifications to watchers.
  final PfChangeBus changeBus;

  /// The raw sqflite [Database] handle. Prefer using DAOs for queries.
  Database get raw => _db;

  /// Opens (or creates) the application database at the platform-default
  /// location.
  static Future<PfDatabase> open({
    String filename = kPfDatabaseFilename,
    bool seedSystemData = true,
  }) async {
    final factory = resolvePlatformFactory();
    final path = await resolveDatabasePath(filename);
    return _openWith(factory, path, seedSystemData: seedSystemData);
  }

  /// Opens an in-memory database. Useful for tests and previews.
  static Future<PfDatabase> openInMemory({
    DatabaseFactory? factory,
    bool seedSystemData = true,
  }) async {
    final f = factory ?? resolvePlatformFactory();
    return _openWith(
      f,
      inMemoryDatabasePath,
      seedSystemData: seedSystemData,
    );
  }

  static Future<PfDatabase> _openWith(
    DatabaseFactory factory,
    String path, {
    required bool seedSystemData,
  }) async {
    final db = await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: PfSchema.version,
        onConfigure: _onConfigure,
        onCreate: (db, version) => _onCreate(db, version, seedSystemData),
        onUpgrade: _onUpgrade,
      ),
    );
    return PfDatabase._(db, PfChangeBus());
  }

  static Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON;');
  }

  static Future<void> _onCreate(
    Database db,
    int version,
    bool seedSystemData,
  ) async {
    final batch = db.batch();
    for (final stmt in PfSchema.createStatements) {
      batch.execute(stmt);
    }
    await batch.commit(noResult: true);

    if (seedSystemData) {
      await PfSeeder.seedSystemCategories(db);
    }
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // v1 is the baseline; no migrations yet. Future migrations should be
    // registered here as ordered, idempotent blocks per (oldVersion -> next).
    debugPrint('PfDatabase migrate $oldVersion -> $newVersion (no-op)');
  }

  /// Closes the database and tears down the change bus.
  Future<void> close() async {
    await changeBus.dispose();
    await _db.close();
  }
}
