import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// Returns the WASM-backed sqflite factory for the browser.
DatabaseFactory resolvePlatformFactory() => databaseFactoryFfiWeb;

/// On web the filename itself is the storage key (IndexedDB-backed).
Future<String> resolveDatabasePath(String filename) async => filename;
