import 'package:sqflite/sqflite.dart';

/// Stub fallback when neither dart:io nor dart:html are available.
DatabaseFactory resolvePlatformFactory() {
  throw UnsupportedError(
    'No sqflite platform implementation available for this target.',
  );
}

/// Returns a platform-resolved path under which [filename] should be stored.
Future<String> resolveDatabasePath(String filename) async {
  throw UnsupportedError(
    'No platform path provider available for this target.',
  );
}
