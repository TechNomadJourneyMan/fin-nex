// Bottom sheet helper for PocketFlow.

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pf_core_tokens/pf_core_tokens.dart';

import 'pf_theme_ext.dart';

/// Show a themed PocketFlow bottom sheet.
///
/// When [backdropBlur] is true (default) the sheet's barrier renders an
/// animated `BackdropFilter` that ramps from sigma 0 → 12 over
/// [PfMotion.base], honoring `MediaQuery.disableAnimationsOf`. The blur is
/// suppressed automatically on reduced-motion.
Future<T?> showPfBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  bool isDismissible = true,
  bool enableDrag = true,
  String? semanticLabel,
  bool backdropBlur = true,
}) {
  final colors = context.fnxColors;
  final radii = context.fnxRadii;
  final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: colors.surfaceRaised,
    // Letting the barrier paint a transparent color lets our blur layer be
    // the *only* visual scrim, so it animates cleanly. Material still uses
    // the default barrier when backdropBlur is off.
    barrierColor: backdropBlur ? Colors.black.withValues(alpha: 0.0) : null,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(radii.r5)),
    ),
    builder: (ctx) {
      final Widget sheet = Semantics(
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
      if (!backdropBlur) return sheet;
      // Render the blur as an overlay behind the sheet content via a Stack:
      // the parent route already centers `builder(ctx)` at the bottom, so
      // wrapping with a same-height blur layer simply tints what's behind.
      return _AnimatedBackdropBlur(
        duration: reduceMotion ? Duration.zero : PfMotion.base,
        child: sheet,
      );
    },
  );
}

/// Internal helper — animates `BackdropFilter`'s sigma from 0 → 12 once,
/// using [TweenAnimationBuilder] so the blur fades up as the sheet slides in.
class _AnimatedBackdropBlur extends StatelessWidget {
  const _AnimatedBackdropBlur({
    required this.child,
    required this.duration,
  });

  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    // The blur layer sits *behind* the sheet content (Positioned.fill expanded
    // upward via OverflowBox) so it tints the visible portion of the underlying
    // page during the slide-in.
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Positioned.fill(
          child: IgnorePointer(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 12),
              duration: duration,
              curve: PfEasing.standard,
              builder: (BuildContext ctx, double sigma, Widget? _) {
                return BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: 0.0),
                  ),
                );
              },
            ),
          ),
        ),
        child,
      ],
    );
  }
}
