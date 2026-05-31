// AsyncNotifier controller that exposes the current category list and the
// edit / reorder operations used by the UI.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fnx_domain/domain.dart';

import '../providers.dart';

/// AsyncNotifier-backed list of categories visible to the current user.
class CategoriesController extends AsyncNotifier<List<Category>> {
  late CategoriesRepository _repo;
  late Ulid _userId;

  @override
  Future<List<Category>> build() async {
    _repo = ref.watch(categoriesRepositoryProvider);
    _userId = ref.watch(currentUserIdProvider);
    // Pipe stream into state.
    final sub = _repo.watchAll(_userId).listen((items) {
      state = AsyncData<List<Category>>(_sorted(items));
    });
    ref.onDispose(sub.cancel);
    return _sorted(await _repo.list(_userId));
  }

  List<Category> _sorted(List<Category> input) {
    final list = input.where((c) => c.deletedAt == null).toList()
      ..sort((a, b) {
        if (a.isSystem != b.isSystem) {
          return a.isSystem ? -1 : 1;
        }
        return a.sortOrder.compareTo(b.sortOrder);
      });
    return List<Category>.unmodifiable(list);
  }

  /// Inserts or updates [category].
  Future<void> upsert(Category category) async {
    await _repo.upsert(category);
  }

  /// Creates a new custom category for [_userId].
  Future<Category> createCustom({
    required String name,
    required String iconKey,
    required CategoryColor color,
    CategoryType type = CategoryType.expense,
  }) async {
    final now = DateTime.now().toUtc();
    final current = state.valueOrNull ?? const <Category>[];
    final nextOrder = current
            .where((c) => !c.isSystem)
            .fold<int>(0, (m, c) => c.sortOrder > m ? c.sortOrder : m) +
        1;
    final category = Category(
      id: Ulid.now(),
      userId: _userId,
      type: type,
      name: name,
      iconKey: iconKey,
      color: color,
      isSystem: false,
      isArchived: false,
      sortOrder: nextOrder,
      createdAt: now,
      updatedAt: now,
    );
    await _repo.upsert(category);
    return category;
  }

  /// Soft-deletes [id].
  Future<void> remove(Ulid id) => _repo.softDelete(id);

  /// Reorders the custom-categories block.
  ///
  /// Indices are relative to the custom section as displayed.
  Future<void> reorderCustom(int oldIndex, int newIndex) async {
    final current = state.valueOrNull ?? const <Category>[];
    final custom = current.where((c) => !c.isSystem).toList();
    if (oldIndex < 0 ||
        oldIndex >= custom.length ||
        newIndex < 0 ||
        newIndex > custom.length) {
      return;
    }
    var insertAt = newIndex;
    if (insertAt > oldIndex) {
      insertAt -= 1;
    }
    final moved = custom.removeAt(oldIndex);
    custom.insert(insertAt, moved);

    final now = DateTime.now().toUtc();
    for (var i = 0; i < custom.length; i++) {
      final c = custom[i];
      if (c.sortOrder != i) {
        await _repo.upsert(c.copyWith(sortOrder: i, updatedAt: now));
      }
    }
  }
}

/// Provider exposing [CategoriesController].
final categoriesControllerProvider =
    AsyncNotifierProvider<CategoriesController, List<Category>>(
  CategoriesController.new,
);
