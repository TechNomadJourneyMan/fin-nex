// Date picker wrapper for FinNex.

import 'package:flutter/material.dart';

import 'fnx_theme_ext.dart';

/// Show a themed FinNex date picker.
Future<DateTime?> showFnxDatePicker({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
  String? helpText,
}) {
  final colors = context.fnxColors;
  final now = DateTime.now();
  return showDatePicker(
    context: context,
    initialDate: initialDate ?? now,
    firstDate: firstDate ?? DateTime(now.year - 5),
    lastDate: lastDate ?? DateTime(now.year + 1),
    helpText: helpText,
    builder: (ctx, child) {
      return Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: colors.brand,
                onPrimary: colors.onBrand,
                surface: colors.surface,
              ),
        ),
        child: child ?? const SizedBox.shrink(),
      );
    },
  );
}
