// Snackbar helper for FinNex.

import 'package:flutter/material.dart';

import 'fnx_theme_ext.dart';

/// Optional action attached to a FinNex snackbar.
class FnxSnackAction {
  /// Creates a snack action.
  const FnxSnackAction({required this.label, required this.onPressed});

  /// Label text.
  final String label;

  /// Callback when the user taps the action.
  final VoidCallback onPressed;
}

/// Context extension that surfaces a FinNex-styled snackbar.
extension FnxSnackbarX on BuildContext {
  /// Show a snackbar with the FinNex theme.
  void showFnxSnack(
    String message, {
    FnxSnackAction? action,
    Duration duration = const Duration(seconds: 4),
    bool isError = false,
  }) {
    final colors = fnxColors;
    final messenger = ScaffoldMessenger.maybeOf(this);
    if (messenger == null) {
      return;
    }
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: colors.onBrand),
        ),
        backgroundColor:
            isError ? colors.error : colors.textPrimary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(fnxRadii.r3),
        ),
        duration: duration,
        action: action == null
            ? null
            : SnackBarAction(
                label: action.label,
                textColor: colors.brand,
                onPressed: action.onPressed,
              ),
      ),
    );
  }
}
