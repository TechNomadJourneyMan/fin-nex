// Sectioned list of categories: built-in (System) and user (Custom).
//
// - Tap a row to edit.
// - Custom rows are drag-to-reorder via [ReorderableListView]; this works
//   identically on Web because Flutter uses pointer events for the drag.
// - Pull-to-refresh would be added once the real repo streams remotely.

import 'package:flutter/material.dart' hide Category;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';
import 'package:pf_domain/domain.dart';
import 'package:go_router/go_router.dart';

import '../controllers/categories_controller.dart';
import '../widgets/category_icon_picker.dart';

/// Sectioned categories list. System rows are read-only; custom rows are
/// drag-to-reorder and tap-to-edit.
class CategoriesListPage extends ConsumerWidget {
  /// Creates the categories list page.
  const CategoriesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final state = ref.watch(categoriesControllerProvider);
    final colors = context.fnxColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(title: Text(l10n.catScreenTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/categories/new'),
        icon: const Icon(Icons.add),
        label: Text(l10n.catAdd),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('$e', style: TextStyle(color: colors.error)),
        ),
        data: (items) {
          final system = items.where((c) => c.isSystem).toList();
          final custom = items.where((c) => !c.isSystem).toList();
          if (system.isEmpty && custom.isEmpty) {
            return PfEmptyState(
              icon: Icons.category_outlined,
              title: l10n.catScreenTitle,
              body: l10n.catAdd,
              ctaLabel: l10n.catAdd,
              onCta: () => context.push('/categories/new'),
            );
          }
          return CustomScrollView(
            slivers: <Widget>[
              if (system.isNotEmpty) ...[
                _SectionHeader(label: l10n.catSectionSystem),
                SliverList.builder(
                  itemCount: system.length,
                  itemBuilder: (context, i) => _CategoryTile(
                    category: system[i],
                    onTap: () =>
                        context.push('/categories/${system[i].id.value}/edit'),
                  ),
                ),
              ],
              if (custom.isNotEmpty) ...[
                _SectionHeader(label: l10n.catSectionCustom),
                SliverToBoxAdapter(
                  child: _ReorderableCustom(
                    items: custom,
                    onTap: (c) =>
                        context.push('/categories/${c.id.value}/edit'),
                    onReorder: (oldI, newI) => ref
                        .read(categoriesControllerProvider.notifier)
                        .reorderCustom(oldI, newI),
                  ),
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 96)),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final typo = context.fnxTypography;
    final colors = context.fnxColors;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
        child: Text(
          label.toUpperCase(),
          style: typo.overline.copyWith(color: colors.textSecondary),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({super.key, required this.category, required this.onTap});

  final Category category;
  final VoidCallback onTap;

  Color _swatchColor() {
    final v = category.color.hex.substring(1);
    final n = int.parse(v, radix: 16);
    return Color(0xFF000000 | n);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final typo = context.fnxTypography;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _swatchColor().withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  fnxCategoryIconFor(category.iconKey),
                  color: _swatchColor(),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(category.name, style: typo.bodyLg)),
              if (category.isSystem)
                Icon(Icons.lock_outline, size: 16, color: colors.textMuted)
              else
                Icon(Icons.chevron_right, color: colors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReorderableCustom extends StatelessWidget {
  const _ReorderableCustom({
    required this.items,
    required this.onTap,
    required this.onReorder,
  });

  final List<Category> items;
  final ValueChanged<Category> onTap;
  final void Function(int oldIndex, int newIndex) onReorder;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: true,
      onReorder: onReorder,
      itemCount: items.length,
      itemBuilder: (context, i) {
        final c = items[i];
        return _CategoryTile(
          key: ValueKey<String>(c.id.value),
          category: c,
          onTap: () => onTap(c),
        );
      },
    );
  }
}
