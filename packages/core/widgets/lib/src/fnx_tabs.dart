// Segmented tabs widget for FinNex.

import 'package:flutter/material.dart';

import 'fnx_theme_ext.dart';

/// Pill-style segmented tab control.
class FnxTabs extends StatelessWidget {
  /// Creates segmented tabs.
  const FnxTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
  });

  /// Tab labels.
  final List<String> tabs;

  /// Currently selected index.
  final int selectedIndex;

  /// Selection callback.
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final typo = context.fnxTypography;
    final radius = context.fnxRadii;

    return Semantics(
      label: 'Tabs',
      child: Container(
        height: 36,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: colors.surfaceSunken,
          borderRadius: BorderRadius.circular(radius.full),
        ),
        child: Row(
          children: [
            for (var i = 0; i < tabs.length; i++)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: i == selectedIndex,
                  label: tabs[i],
                  child: Material(
                    color: i == selectedIndex
                        ? colors.surface
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(radius.full),
                    child: InkWell(
                      onTap: () => onChanged(i),
                      borderRadius: BorderRadius.circular(radius.full),
                      child: Center(
                        child: Text(
                          tabs[i],
                          style: typo.bodySm.copyWith(
                            fontWeight: i == selectedIndex
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: i == selectedIndex
                                ? colors.textPrimary
                                : colors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
