// Riverpod providers for the workspaces feature (F-06 client).
//
// In-memory defaults so the feature is functional on Web before the data
// layer is wired. Override in app composition.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_domain/domain.dart';

import 'data/in_memory_workspaces_repository.dart';
import 'workspaces_repository.dart';

/// Current user id; overridden by the auth feature in app composition.
final workspacesCurrentUserIdProvider = Provider<Ulid>((ref) {
  // TODO(F-auth): provide the real signed-in user id.
  return Ulid('00000000000000000000000001');
});

/// Provides the active [WorkspacesRepository].
///
/// Defaults to an in-memory repository so the switcher renders before the
/// real Drift/API layer is wired. Override in app composition.
final workspacesRepositoryProvider = Provider<WorkspacesRepository>((ref) {
  // TODO(F-06): replace with the real repository in app composition.
  return InMemoryWorkspacesRepository();
});

/// Streams all workspaces for the current user.
///
/// The switcher and create page watch this so the UI reflects inserts and
/// deletes live.
final workspacesStreamProvider = StreamProvider<List<Workspace>>((ref) {
  final repo = ref.watch(workspacesRepositoryProvider);
  final userId = ref.watch(workspacesCurrentUserIdProvider);
  return repo.watchWorkspaces(userId);
});

/// Holds the currently-active workspace id.
///
/// `null` until the first workspace stream emits, after which it defaults to
/// the user's default workspace (or the first available one). Callers switch
/// workspaces by calling [ActiveWorkspaceController.select].
class ActiveWorkspaceController extends StateNotifier<Ulid?> {
  /// Creates the controller with no initial selection.
  ActiveWorkspaceController() : super(null);

  /// Selects [id] as the active workspace.
  void select(Ulid id) => state = id;

  /// Adopts [id] as the active workspace only when nothing is selected yet.
  ///
  /// Used to seed the selection from the first workspace-stream emission
  /// without clobbering an explicit user choice.
  void seedIfUnset(Ulid id) {
    if (state == null) {
      state = id;
    }
  }

  /// Clears the selection (e.g. on sign-out).
  void clear() => state = null;
}

/// The currently-active workspace id (or null before the first emission).
final activeWorkspaceProvider =
    StateNotifierProvider<ActiveWorkspaceController, Ulid?>((ref) {
  final controller = ActiveWorkspaceController();

  // Seed the active workspace from the stream: prefer the default workspace,
  // otherwise the first available one. Only seeds when nothing is selected.
  ref.listen<AsyncValue<List<Workspace>>>(
    workspacesStreamProvider,
    (prev, next) {
      final list = next.valueOrNull;
      if (list == null || list.isEmpty) {
        return;
      }
      final preferred = list.firstWhere(
        (w) => w.isDefault,
        orElse: () => list.first,
      );
      controller.seedIfUnset(preferred.id);
    },
    fireImmediately: true,
  );

  return controller;
});

/// Resolves the active [Workspace] entity, or null when none is selected or
/// the stream has not yet produced data.
final activeWorkspaceEntityProvider = Provider<Workspace?>((ref) {
  final activeId = ref.watch(activeWorkspaceProvider);
  final list = ref.watch(workspacesStreamProvider).valueOrNull;
  if (activeId == null || list == null) {
    return null;
  }
  for (final w in list) {
    if (w.id == activeId) {
      return w;
    }
  }
  return null;
});
