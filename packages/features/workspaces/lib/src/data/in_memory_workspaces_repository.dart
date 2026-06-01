// Volatile, in-memory implementation of [WorkspacesRepository].
//
// Web-safe; used as the default until the data layer wires real persistence.
// Seeds a single default "Personal" workspace so the switcher renders with
// content before the user creates anything.

import 'dart:async';

import 'package:pf_domain/domain.dart';

import '../workspaces_repository.dart';

/// Simple in-process [WorkspacesRepository].
class InMemoryWorkspacesRepository implements WorkspacesRepository {
  /// Creates a repository, optionally seeded with [seed] workspaces.
  InMemoryWorkspacesRepository({List<Workspace>? seed})
      : _workspaces = <Workspace>[...?seed];

  final List<Workspace> _workspaces;
  final StreamController<List<Workspace>> _ctrl =
      StreamController<List<Workspace>>.broadcast();

  void _emit() => _ctrl.add(List<Workspace>.unmodifiable(_workspaces));

  @override
  Stream<List<Workspace>> watchWorkspaces(Ulid userId) async* {
    yield List<Workspace>.unmodifiable(
      _workspaces.where((w) => w.userId == userId),
    );
    yield* _ctrl.stream.map(
      (all) => List<Workspace>.unmodifiable(
        all.where((w) => w.userId == userId),
      ),
    );
  }

  @override
  Future<List<Workspace>> listWorkspaces(Ulid userId) async =>
      List<Workspace>.unmodifiable(
        _workspaces.where((w) => w.userId == userId),
      );

  @override
  Future<Workspace?> getById(Ulid id) async {
    for (final w in _workspaces) {
      if (w.id == id) {
        return w;
      }
    }
    return null;
  }

  @override
  Future<void> upsert(Workspace workspace) async {
    final i = _workspaces.indexWhere((w) => w.id == workspace.id);
    if (i >= 0) {
      _workspaces[i] = workspace;
    } else {
      _workspaces.add(workspace);
    }
    _emit();
  }

  @override
  Future<void> softDelete(Ulid id) async {
    _workspaces.removeWhere((w) => w.id == id);
    _emit();
  }

  /// Releases the broadcast controller.
  Future<void> dispose() async {
    await _ctrl.close();
  }
}
