// In-memory [CategoriesRepository] used until the data layer is wired in.
//
// This implementation is intentionally simple: it keeps a `List<Category>`
// in memory and broadcasts changes via a `StreamController`. It is safe on
// Web (no dart:io, no native bindings).

import 'dart:async';

import 'package:pf_domain/domain.dart';

/// Volatile, single-process [CategoriesRepository] for dev / preview.
class InMemoryCategoriesRepository implements CategoriesRepository {
  /// Creates an empty repository.
  InMemoryCategoriesRepository();

  /// Creates a repository pre-populated with a small system category set.
  factory InMemoryCategoriesRepository.seeded() {
    final repo = InMemoryCategoriesRepository();
    repo._items.addAll(_seedSystem());
    return repo;
  }

  final List<Category> _items = <Category>[];
  final StreamController<List<Category>> _controller =
      StreamController<List<Category>>.broadcast();

  void _emit() {
    _controller.add(List<Category>.unmodifiable(_items));
  }

  @override
  Stream<List<Category>> watchAll(Ulid userId) async* {
    yield List<Category>.unmodifiable(_items);
    yield* _controller.stream;
  }

  @override
  Future<List<Category>> list(Ulid userId) async =>
      List<Category>.unmodifiable(_items);

  @override
  Future<Category?> getById(Ulid id) async {
    for (final c in _items) {
      if (c.id == id) {
        return c;
      }
    }
    return null;
  }

  @override
  Future<void> upsert(Category category) async {
    final i = _items.indexWhere((c) => c.id == category.id);
    if (i >= 0) {
      _items[i] = category;
    } else {
      _items.add(category);
    }
    _emit();
  }

  @override
  Future<void> softDelete(Ulid id) async {
    final i = _items.indexWhere((c) => c.id == id);
    if (i < 0) {
      return;
    }
    final old = _items[i];
    if (old.isSystem) {
      // System categories are archived, not deleted.
      _items[i] = old.copyWith(isArchived: true, updatedAt: DateTime.now());
    } else {
      _items[i] = old.copyWith(deletedAt: DateTime.now());
    }
    _emit();
  }

  /// Releases the broadcast stream.
  Future<void> dispose() async {
    await _controller.close();
  }
}

List<Category> _seedSystem() {
  final now = DateTime.now().toUtc();
  Category sys(String id, String name, String icon, String hex, int order) =>
      Category(
        id: Ulid(id),
        type: CategoryType.expense,
        name: name,
        iconKey: icon,
        color: CategoryColor(hex),
        isSystem: true,
        isArchived: false,
        sortOrder: order,
        createdAt: now,
        updatedAt: now,
      );

  return <Category>[
    sys('01HSEEDSYSCAT00000000FOOD0', 'Food', 'restaurant', '#FF6B6B', 0),
    sys('01HSEEDSYSCAT00000000GROCS', 'Groceries', 'local_grocery_store',
        '#4ECDC4', 1),
    sys('01HSEEDSYSCAT00000000TXFER', 'Transport', 'directions_car',
        '#5F8AFB', 2),
    sys('01HSEEDSYSCAT00000000RENTX', 'Rent', 'home', '#8E7CC3', 3),
    sys('01HSEEDSYSCAT00000000HEALK', 'Health', 'medical_services',
        '#E26D5C', 4),
    sys('01HSEEDSYSCAT00000000EDUKE', 'Education', 'school', '#3D5AFE', 5),
    sys('01HSEEDSYSCAT00000000OTHER', 'Other', 'category', '#888888', 99),
  ];
}
