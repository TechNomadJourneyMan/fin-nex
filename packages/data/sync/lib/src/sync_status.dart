import 'package:meta/meta.dart';

/// State machine values surfaced by the sync engine to the UI.
@immutable
sealed class SyncStatus {
  const SyncStatus();

  /// No sync work in flight.
  const factory SyncStatus.idle() = SyncIdle;

  /// Outbox is being drained towards the server.
  const factory SyncStatus.pushing({int pending}) = SyncPushing;

  /// Server changes are being pulled into the local store.
  const factory SyncStatus.pulling() = SyncPulling;

  /// Sync round-trip failed; [message] is non-localized diagnostic.
  const factory SyncStatus.error(String message) = SyncError;

  /// Server reported [count] conflicts requiring resolution.
  const factory SyncStatus.conflict(int count) = SyncConflict;
}

/// Idle state — nothing to do.
final class SyncIdle extends SyncStatus {
  /// Default const.
  const SyncIdle();
  @override
  bool operator ==(Object other) => other is SyncIdle;
  @override
  int get hashCode => 0;
  @override
  String toString() => 'SyncStatus.idle';
}

/// Push in flight.
final class SyncPushing extends SyncStatus {
  /// Pending count snapshot at the moment the status was emitted.
  const SyncPushing({this.pending = 0});

  /// Number of outbox rows still waiting after this batch.
  final int pending;

  @override
  bool operator ==(Object other) =>
      other is SyncPushing && other.pending == pending;
  @override
  int get hashCode => pending.hashCode;
  @override
  String toString() => 'SyncStatus.pushing(pending=$pending)';
}

/// Pull in flight.
final class SyncPulling extends SyncStatus {
  /// Default const.
  const SyncPulling();
  @override
  bool operator ==(Object other) => other is SyncPulling;
  @override
  int get hashCode => 1;
  @override
  String toString() => 'SyncStatus.pulling';
}

/// Error state.
final class SyncError extends SyncStatus {
  /// [message] is engineering-facing — translate at the UI boundary.
  const SyncError(this.message);

  /// Diagnostic message.
  final String message;

  @override
  bool operator ==(Object other) =>
      other is SyncError && other.message == message;
  @override
  int get hashCode => message.hashCode;
  @override
  String toString() => 'SyncStatus.error($message)';
}

/// Conflict state.
final class SyncConflict extends SyncStatus {
  /// [count] of conflicting rows reported by the server.
  const SyncConflict(this.count);

  /// Number of unresolved conflicts.
  final int count;

  @override
  bool operator ==(Object other) =>
      other is SyncConflict && other.count == count;
  @override
  int get hashCode => count.hashCode;
  @override
  String toString() => 'SyncStatus.conflict($count)';
}
