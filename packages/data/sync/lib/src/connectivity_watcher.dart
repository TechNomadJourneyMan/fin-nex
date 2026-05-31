import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import 'sync_engine.dart';

/// Watches the platform connectivity stream and triggers
/// [SyncEngine.syncAll] when the device regains network.
///
/// Works on web (connectivity_plus returns `wifi`/`none`) and mobile alike.
/// Background isolates are intentionally not used here — `workmanager` and
/// `BGTaskScheduler` integration is deferred to a later milestone.
class ConnectivityWatcher {
  /// Default ctor.
  ConnectivityWatcher({
    required this.engine,
    Connectivity? connectivity,
  }) : _connectivity = connectivity ?? Connectivity();

  /// Engine that gets nudged on network recovery.
  final SyncEngine engine;

  final Connectivity _connectivity;

  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _wasOnline = false;

  /// Starts listening; safe to call multiple times.
  Future<void> start() async {
    await stop();
    final initial = await _connectivity.checkConnectivity();
    _wasOnline = _isOnline(initial);
    _sub = _connectivity.onConnectivityChanged.listen(_onChange);
  }

  /// Stops listening.
  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
  }

  void _onChange(List<ConnectivityResult> results) {
    final online = _isOnline(results);
    if (online && !_wasOnline) {
      // Fire-and-forget: errors surface through `engine.status`.
      unawaited(engine.syncAll());
      if (kDebugMode) debugPrint('ConnectivityWatcher: regained network');
    }
    _wasOnline = online;
  }

  bool _isOnline(List<ConnectivityResult> results) {
    for (final r in results) {
      if (r != ConnectivityResult.none) return true;
    }
    return false;
  }
}
