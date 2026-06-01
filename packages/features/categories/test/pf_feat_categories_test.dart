// Tests for the categories feature.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pf_domain/domain.dart';

import 'package:pf_feat_categories/pf_feat_categories.dart';
import 'package:pf_feat_categories/src/data/in_memory_categories_repository.dart';

void main() {
  test('icon picker exposes 60+ icons', () {
    expect(fnxCategoryIcons.length, greaterThanOrEqualTo(60));
  });

  test('color picker exposes 8 swatches', () {
    expect(fnxCategorySwatches.length, equals(8));
  });

  test('controller reorder swaps custom sort orders', () async {
    final repo = InMemoryCategoriesRepository();
    final container = ProviderContainer(
      overrides: <Override>[
        categoriesRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);

    final userId = container.read(currentUserIdProvider);
    final now = DateTime.now().toUtc();
    Category mk(String id, int order) => Category(
          id: Ulid(id),
          userId: userId,
          type: CategoryType.expense,
          name: 'C$order',
          iconKey: 'category',
          color: CategoryColor('#888888'),
          isSystem: false,
          isArchived: false,
          sortOrder: order,
          createdAt: now,
          updatedAt: now,
        );

    await repo.upsert(mk('01ABCDEFGHJKMNPQRSTVWXYZ00', 0));
    await repo.upsert(mk('01ABCDEFGHJKMNPQRSTVWXYZ01', 1));
    await repo.upsert(mk('01ABCDEFGHJKMNPQRSTVWXYZ02', 2));

    await container.read(categoriesControllerProvider.future);
    await container
        .read(categoriesControllerProvider.notifier)
        .reorderCustom(0, 3);

    final result = await container.read(categoriesControllerProvider.future);
    final custom = result.where((c) => !c.isSystem).toList();
    expect(custom.first.name, 'C1');
    expect(custom.last.name, 'C0');
  });
}
