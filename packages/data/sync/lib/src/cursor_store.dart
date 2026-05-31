import 'package:shared_preferences/shared_preferences.dart';

/// Persists per-table pull cursors so the sync engine resumes where it left
/// off after relaunch.
///
/// Cursors are opaque strings the server returns from `/sync/pull` — we never
/// parse them. See `10_api_spec.md` §1.3.
class CursorStore {
  /// Builds a store backed by [prefs].
  CursorStore(this._prefs);

  /// Convenience factory that resolves [SharedPreferences] lazily.
  static Future<CursorStore> open() async {
    final prefs = await SharedPreferences.getInstance();
    return CursorStore(prefs);
  }

  final SharedPreferences _prefs;

  static const String _prefix = 'fnx.sync.cursor.';

  /// Returns the last cursor saved for [table], or `null` for a cold start.
  String? read(String table) => _prefs.getString('$_prefix$table');

  /// Saves [cursor] for [table]. Passing `null` clears the entry.
  Future<void> write(String table, String? cursor) async {
    final key = '$_prefix$table';
    if (cursor == null) {
      await _prefs.remove(key);
    } else {
      await _prefs.setString(key, cursor);
    }
  }

  /// Wipes every cursor; used when the user signs out or schema bumps.
  Future<void> clearAll() async {
    final keys = _prefs.getKeys().where((k) => k.startsWith(_prefix)).toList();
    for (final k in keys) {
      await _prefs.remove(k);
    }
  }
}
