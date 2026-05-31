// Category picker grid for FinNex.

import 'package:flutter/material.dart';

import 'fnx_theme_ext.dart';

/// Single category option used by [FnxCategoryPicker].
class FnxCategoryOption {
  /// Creates a category option.
  const FnxCategoryOption({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
  });

  /// Stable identifier.
  final String id;

  /// Display label.
  final String label;

  /// Icon glyph.
  final IconData icon;

  /// Brand color for the category.
  final Color color;
}

/// Grid-based category picker.
class FnxCategoryPicker extends StatelessWidget {
  /// Creates a picker.
  const FnxCategoryPicker({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelected,
    this.crossAxisCount = 4,
  });

  /// Available categories.
  final List<FnxCategoryOption> categories;

  /// Currently selected id.
  final String? selectedId;

  /// Selection callback.
  final ValueChanged<FnxCategoryOption> onSelected;

  /// Grid columns.
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final typo = context.fnxTypography;
    final radius = context.fnxRadii;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: categories.length,
      itemBuilder: (ctx, index) {
        final cat = categories[index];
        final selected = cat.id == selectedId;
        return Semantics(
          button: true,
          selected: selected,
          label: cat.label,
          child: Material(
            color: selected ? cat.color.withValues(alpha: 0.12) : colors.surface,
            borderRadius: BorderRadius.circular(radius.r3),
            child: InkWell(
              onTap: () => onSelected(cat),
              borderRadius: BorderRadius.circular(radius.r3),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius.r3),
                  border: Border.all(
                    color: selected ? cat.color : colors.borderSubtle,
                    width: selected ? 2 : 1,
                  ),
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(cat.icon, color: cat.color, size: 28),
                    const SizedBox(height: 8),
                    Text(
                      cat.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: typo.bodySm.copyWith(color: colors.textPrimary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
