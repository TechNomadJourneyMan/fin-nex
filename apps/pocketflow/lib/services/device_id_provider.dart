// Stable per-install device identifier for Pocket Flow.
//
// The backend expects an `X-Device-Id` header (a ULID) on every authenticated
// request so it can scope sessions to a device. We generate one lazily on the
// first call and persist it in `shared_preferences` so it survives restarts.

import 'package:pf_domain/pf_domain.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lazily generates and persists a stable device id (ULID).
class DeviceIdStore {
  /// Creates a store backed by [_prefs].
  DeviceIdStore(this._prefs);

  final SharedPreferences _prefs;

  /// `shared_preferences` key holding the device id.
  static const String prefsKey = 'pf.device_id';

  String? _cached;

  /// Returns the persisted device id, generating one on first use.
  ///
  /// The same value is returned for the lifetime of the install. Wired into
  /// [DioFactory.create]'s `getDeviceId` callback.
  Future<String> getDeviceId() async {
    final cached = _cached;
    if (cached != null) {
      return cached;
    }
    final existing = _prefs.getString(prefsKey);
    if (existing != null && existing.isNotEmpty) {
      _cached = existing;
      return existing;
    }
    final generated = Ulid.now().value;
    _cached = generated;
    await _prefs.setString(prefsKey, generated);
    return generated;
  }
}
