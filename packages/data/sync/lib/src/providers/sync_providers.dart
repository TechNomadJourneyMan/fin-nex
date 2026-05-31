import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../conflict_resolver.dart';
import '../connectivity_watcher.dart';
import '../cursor_store.dart';
import '../outbox_processor.dart';
import '../sync_contracts.dart';
import '../sync_engine.dart';
import '../sync_status.dart';

/// Provider for the shared [CursorStore]. Must be overridden in `main()` with
/// an instance bootstrapped from [CursorStore.open].
final cursorStoreProvider = Provider<CursorStore>((ref) {
  throw UnimplementedError(
    'cursorStoreProvider must be overridden with CursorStore.open() result.',
  );
});

/// Provider for the platform [OutboxStore] adapter. Overridden by
/// `fnx_data_local`'s bootstrap once DAOs are wired.
final outboxStoreProvider = Provider<OutboxStore>((ref) {
  throw UnimplementedError('outboxStoreProvider must be overridden.');
});

/// Provider for the [SyncService] transport (Dio-backed in production,
/// in-memory fake in tests).
final syncServiceProvider = Provider<SyncService>((ref) {
  throw UnimplementedError('syncServiceProvider must be overridden.');
});

/// Provider for the per-table [RemoteApplier] map.
final remoteAppliersProvider = Provider<Map<String, RemoteApplier>>((ref) {
  return const <String, RemoteApplier>{};
});

/// Default [ConflictResolver] (stateless).
final conflictResolverProvider = Provider<ConflictResolver>((ref) {
  return const ConflictResolver();
});

/// Default [OutboxProcessor] wired from the above providers.
final outboxProcessorProvider = Provider<OutboxProcessor>((ref) {
  return OutboxProcessor(
    outbox: ref.watch(outboxStoreProvider),
    service: ref.watch(syncServiceProvider),
  );
});

/// Main [SyncEngine] provider. Disposes the engine on container teardown.
final syncEngineProvider = Provider<SyncEngine>((ref) {
  final engine = SyncEngine(
    outbox: ref.watch(outboxProcessorProvider),
    service: ref.watch(syncServiceProvider),
    cursors: ref.watch(cursorStoreProvider),
    resolver: ref.watch(conflictResolverProvider),
    appliers: ref.watch(remoteAppliersProvider),
  );
  ref.onDispose(engine.dispose);
  return engine;
});

/// Stream of the engine's current [SyncStatus]. Seeded with [SyncStatus.idle].
final syncStatusProvider = StreamProvider<SyncStatus>((ref) async* {
  final engine = ref.watch(syncEngineProvider);
  yield const SyncStatus.idle();
  yield* engine.status;
});

/// [ConnectivityWatcher] that triggers `syncAll()` on network recovery.
/// Listen to it from `main()` (e.g. via `ref.listen`) to ensure it starts.
final connectivityWatcherProvider = Provider<ConnectivityWatcher>((ref) {
  final watcher = ConnectivityWatcher(engine: ref.watch(syncEngineProvider));
  // Caller is responsible for invoking `start()`. We cannot await here because
  // Provider builders are synchronous.
  ref.onDispose(watcher.stop);
  return watcher;
});
