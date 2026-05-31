// Eight-swatch color picker for a category.

import 'package:flutter/material.dart';
import 'package:fnx_core_widgets/fnx_core_widgets.dart';
import 'package:fnx_domain/domain.dart';

/// Canonical swatch palette for category colors.
const List<String> fnxCategorySwatches = <String>[
  '#FF6B6B',
  '#FFA94D',
  '#FFD43B',
  '#69DB7C',
  '#4ECDC4',
  '#5F8AFB',
  '#8E7CC3',
  '#FF8AC4',
];

/// Horizontal swatch picker. Eight pre-defined colors per spec.
class CategoryColorPicker extends StatelessWidget {
  /// Creates a color picker.
  const CategoryColorPicker({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  /// Currently selected color.
  final CategoryColor selected;

  /// Called when a swatch is tapped.
  final ValueChanged<CategoryColor> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: <Widget>[
        for (final hex in fnxCategorySwatches)
          _Swatch(
            hex: hex,
            isSelected: hex == selected.hex,
            ringColor: colors.brand,
            borderColor: colors.borderSubtle,
            onTap: () => onSelected(CategoryColor(hex)),
          ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.hex,
    required this.isSelected,
    required this.ringColor,
    required this.borderColor,
    required this.onTap,
  });

  final String hex;
  final bool isSelected;
  final Color ringColor;
  final Color borderColor;
  final VoidCallback onTap;

  Color _parseHex() {
    final v = hex.substring(1);
    final n = int.parse(v, radix: 16);
    return Color(0xFF000000 | n);
  }

  @override
  Widget build(BuildContext context) {
    final fill = _parseHex();
    return Semantics(
      button: true,
      selected: isSelected,
      label: hex,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: fill,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? ringColor : borderColor,
              width: isSelected ? 3 : 1,
            ),
          ),
          child: isSelected
              ? const Icon(Icons.check, color: Colors.white, size: 22)
              : null,
        ),
      ),
    );
  }
}
