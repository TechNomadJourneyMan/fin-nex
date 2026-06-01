// Date picker wrapper for PocketFlow.

import 'package:flutter/material.dart';

import 'pf_theme_ext.dart';

/// Show a themed PocketFlow date picker.
Future<DateTime?> showPfDatePicker({
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
