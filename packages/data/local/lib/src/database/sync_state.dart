/// Sync state machine values shared by every sync-relevant row.
enum SyncState {
  /// Row has local changes not yet pushed to server.
  pending('pending'),

  /// Row is currently being pushed.
  syncing('syncing'),

  /// Row has been confirmed by the server.
  synced('synced'),

  /// Server rejected the push due to conflict; requires resolution.
  conflict('conflict'),

  /// Permanent error; will not retry without user action.
  error('error');

  const SyncState(this.value);

  /// Canonical string form persisted in SQLite.
  final String value;

  /// Parse a database string into a [SyncState], defaulting to [pending].
  static SyncState fromString(String? raw) {
    for (final s in SyncState.values) {
      if (s.value == raw) return s;
    }
    return SyncState.pending;
  }
}
