// Persistence and query contract for [Workspace] (F-06 client).
//
// Declared here in the feature package rather than in `fnx_domain` so the
// workspaces module is self-contained. If/when the domain layer ships a
// canonical `WorkspacesRepository`, this can be replaced by a re-export.
//
// Depends on the `Workspace` entity assumed to live in `fnx_domain`
// (entities/workspace.dart) with the shape:
//   Workspace { id, userId, name, type, baseCurrency, colorHex,
//               iconKey?, createdAt, updatedAt, isDefault }

import 'package:fnx_domain/domain.dart';

/// Persistence and query contract for [Workspace].
abstract interface class WorkspacesRepository {
  /// Live list of all workspaces belonging to [userId].
  Stream<List<Workspace>> watchWorkspaces(Ulid userId);

  /// Snapshot list of workspaces for [userId].
  Future<List<Workspace>> listWorkspaces(Ulid userId);

  /// Fetches a single workspace by id, or null if not found.
  Future<Workspace?> getById(Ulid id);

  /// Inserts or updates [workspace].
  Future<void> upsert(Workspace workspace);

  /// Soft-deletes the workspace [id].
  Future<void> softDelete(Ulid id);
}
