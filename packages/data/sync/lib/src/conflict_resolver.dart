import 'package:meta/meta.dart';

/// Per-table strategy enum identifier.
enum ConflictStrategy {
  /// Pick the side with the later `updatedAt`. Ties → server wins.
  lastWriteWins,

  /// Server is authoritative for `is_system = true`; LWW otherwise.
  serverWinsForSystem,

  /// Merge two lists/sets by union of `name` (used for tags).
  mergeByName,
}

/// Outcome of a conflict resolution decision.
enum ConflictDecision {
  /// Keep the local row.
  keepLocal,

  /// Overwrite local with remote.
  takeRemote,

  /// Merge produced a synthetic row; caller writes the merged payload.
  merged,
}

/// A merged conflict resolution outcome.
@immutable
class MergeResult<T> {
  /// Default const ctor.
  const MergeResult({required this.decision, this.merged});

  /// What the caller should do.
  final ConflictDecision decision;

  /// Merged payload when [decision] is [ConflictDecision.merged].
  final T? merged;
}

/// Resolves write conflicts between local and remote row versions according to
/// the per-table policy documented in `08_architecture.md` §7.3.
class ConflictResolver {
  /// Default const ctor.
  const ConflictResolver();

  /// Strategy lookup for the known tables.
  ConflictStrategy strategyFor(String table) {
    switch (table) {
      case 'transactions':
      case 'budgets':
        return ConflictStrategy.lastWriteWins;
      case 'categories':
        return ConflictStrategy.serverWinsForSystem;
      case 'tags':
        return ConflictStrategy.mergeByName;
      default:
        return ConflictStrategy.lastWriteWins;
    }
  }

  /// Last-write-wins by `updatedAt`. Ties prefer remote (server canonical).
  ConflictDecision resolveLastWriteWins({
    required DateTime localUpdatedAt,
    required DateTime remoteUpdatedAt,
  }) {
    if (localUpdatedAt.isAfter(remoteUpdatedAt)) {
      return ConflictDecision.keepLocal;
    }
    return ConflictDecision.takeRemote;
  }

  /// `categories` policy: server wins when the row is a system category,
  /// otherwise LWW by `updatedAt`.
  ConflictDecision resolveCategoryConflict({
    required bool remoteIsSystem,
    required bool localIsSystem,
    required DateTime localUpdatedAt,
    required DateTime remoteUpdatedAt,
  }) {
    if (remoteIsSystem || localIsSystem) {
      return ConflictDecision.takeRemote;
    }
    return resolveLastWriteWins(
      localUpdatedAt: localUpdatedAt,
      remoteUpdatedAt: remoteUpdatedAt,
    );
  }

  /// `tags` policy: union by `name` (case-insensitive). The merged list is
  /// returned for the caller to persist.
  MergeResult<List<TagLike>> mergeTags({
    required List<TagLike> local,
    required List<TagLike> remote,
  }) {
    final byName = <String, TagLike>{};
    for (final t in remote) {
      byName[t.name.toLowerCase()] = t;
    }
    for (final t in local) {
      byName.putIfAbsent(t.name.toLowerCase(), () => t);
    }
    final merged = byName.values.toList(growable: false);
    return MergeResult<List<TagLike>>(
      decision: ConflictDecision.merged,
      merged: merged,
    );
  }

  /// Default entry point used by the sync engine when applying remote rows.
  ConflictDecision resolve({
    required String table,
    required DateTime localUpdatedAt,
    required DateTime remoteUpdatedAt,
    bool localIsSystem = false,
    bool remoteIsSystem = false,
  }) {
    switch (strategyFor(table)) {
      case ConflictStrategy.lastWriteWins:
        return resolveLastWriteWins(
          localUpdatedAt: localUpdatedAt,
          remoteUpdatedAt: remoteUpdatedAt,
        );
      case ConflictStrategy.serverWinsForSystem:
        return resolveCategoryConflict(
          remoteIsSystem: remoteIsSystem,
          localIsSystem: localIsSystem,
          localUpdatedAt: localUpdatedAt,
          remoteUpdatedAt: remoteUpdatedAt,
        );
      case ConflictStrategy.mergeByName:
        return ConflictDecision.merged;
    }
  }
}

/// Minimal contract a tag-shaped row must satisfy for [ConflictResolver.mergeTags].
abstract class TagLike {
  /// Display name of the tag.
  String get name;
}
