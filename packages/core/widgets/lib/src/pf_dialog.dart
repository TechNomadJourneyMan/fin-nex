// Dialog helpers for PocketFlow.

import 'package:flutter/material.dart';

import 'pf_button.dart';
import 'pf_theme_ext.dart';

/// Dialog kind.
enum PfDialogKind {
  /// Informational dialog.
  info,

  /// Confirmation (primary + cancel).
  confirm,

  /// Destructive (red primary).
  destructive,
}

/// Show a themed PocketFlow dialog and return the user's selection.
Future<bool?> showPfDialog({
  required BuildContext context,
  required String title,
  required String message,
  PfDialogKind kind = PfDialogKind.info,
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
                  if (kind != PfDialogKind.info)
                    PfButton(
                      label: cancelLabel,
                      variant: PfButtonVariant.ghost,
                      onPressed: () => Navigator.of(ctx).pop(false),
                    ),
                  const SizedBox(width: 8),
                  PfButton(
                    label: confirmLabel,
                    variant: kind == PfDialogKind.destructive
                        ? PfButtonVariant.destructive
                        : PfButtonVariant.primary,
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
