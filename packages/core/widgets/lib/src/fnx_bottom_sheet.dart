// Bottom sheet helper for FinNex.

import 'package:flutter/material.dart';

import 'fnx_theme_ext.dart';

/// Show a themed FinNex bottom sheet.
Future<T?> showFnxBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  bool isDismissible = true,
  bool enableDrag = true,
  String? semanticLabel,
}) {
  final colors = context.fnxColors;
  final radii = context.fnxRadii;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: colors.surfaceRaised,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(radii.r5)),
    ),
    builder: (ctx) {
      return Semantics(
        label: semanticLabel,
        container: true,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ctx.fnxColors.borderDefault,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Flexible(child: builder(ctx)),
            ],
          ),
        ),
      );
    },
  );
}
