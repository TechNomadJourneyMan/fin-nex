// Dialog helpers for FinNex.

import 'package:flutter/material.dart';

import 'fnx_button.dart';
import 'fnx_theme_ext.dart';

/// Dialog kind.
enum FnxDialogKind {
  /// Informational dialog.
  info,

  /// Confirmation (primary + cancel).
  confirm,

  /// Destructive (red primary).
  destructive,
}

/// Show a themed FinNex dialog and return the user's selection.
Future<bool?> showFnxDialog({
  required BuildContext context,
  required String title,
  required String message,
  FnxDialogKind kind = FnxDialogKind.info,
  String confirmLabel = 'OK',
  String cancelLabel = 'Cancel',
}) {
  final radii = context.fnxRadii;
  final colors = context.fnxColors;
  final typo = context.fnxTypography;

  return showDialog<bool>(
    context: context,
    builder: (ctx) {
      return Dialog(
        backgroundColor: colors.surfaceRaised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radii.r6),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: typo.heading2),
              const SizedBox(height: 8),
              Text(message,
                  style: typo.bodyMd.copyWith(color: colors.textSecondary)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (kind != FnxDialogKind.info)
                    FnxButton(
                      label: cancelLabel,
                      variant: FnxButtonVariant.ghost,
                      onPressed: () => Navigator.of(ctx).pop(false),
                    ),
                  const SizedBox(width: 8),
                  FnxButton(
                    label: confirmLabel,
                    variant: kind == FnxDialogKind.destructive
                        ? FnxButtonVariant.destructive
                        : FnxButtonVariant.primary,
                    onPressed: () => Navigator.of(ctx).pop(true),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
