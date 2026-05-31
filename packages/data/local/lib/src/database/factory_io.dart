import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Returns the default native sqflite factory.
DatabaseFactory resolvePlatformFactory() => databaseFactory;

/// Resolves an application-documents path for the given [filename].
Future<String> resolveDatabasePath(String filename) async {
  final dir = await getApplicationDocumentsDirectory();
  return p.join(dir.path, filename);
}
