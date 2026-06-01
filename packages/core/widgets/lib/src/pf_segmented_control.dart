// Segmented control widget for PocketFlow.

import 'package:flutter/material.dart';

import 'pf_theme_ext.dart';

/// PocketFlow segmented control (2-4 options) for time ranges and similar.
class PfSegmentedControl<T> extends StatelessWidget {
  /// Creates a segmented control.
  const PfSegmentedControl({
    super.key,
    required this.segments,
    required this.value,
    required this.onChanged,
  });

  /// Map of value -> label.
  final Map<T, String> segments;

  /// Currently selected value.
  final T value;

  /// Selection callback.
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final typo = context.fnxTypography;
    final radius = context.fnxRadii;

    return Semantics(
      label: 'Segmented control',
      child: Container(
        height: 36,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: colors.surfaceSunken,
          borderRadius: BorderRadius.circular(radius.r3),
        ),
        child: Row(
          children: [
            for (final entry in segments.entries)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: entry.key == value,
                  label: entry.value,
                  child: Material(
                    color: entry.key == value
                        ? colors.surface
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(radius.r2),
                    child: InkWell(
                      onTap: () => onChanged(entry.key),
                      borderRadius: BorderRadius.circular(radius.r2),
                      child: Center(
                        child: Text(
                          entry.value,
                          style: typo.bodySm.copyWith(
                            fontWeight: entry.key == value
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: entry.key == value
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
