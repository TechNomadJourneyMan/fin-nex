// Shimmer skeleton placeholders for Pocket Flow.
//
// `PfSkeleton` is the base block; `PfSkeletonText`, `PfSkeletonCard` and
// `PfSkeletonCircle` are convenience presets. The shimmer is driven by a
// single [AnimationController] running at [PfMotion.deliberate] (600 ms) with
// `repeat(reverse: true)`, and is painted via a [ShaderMask] sweeping a
// light highlight (`PfColors.neutral100`/`neutral200`) across the base block.
//
// Honours `MediaQuery.disableAnimations` (reduced motion): when set, the
// shimmer freezes at a static mid-tone so the placeholder is still visible
// without movement.

import 'package:flutter/material.dart';
import 'package:pf_core_tokens/pf_core_tokens.dart';

import 'pf_theme_ext.dart';

/// Shape variant for [PfSkeleton].
enum PfSkeletonShape {
  /// Rectangular block.
  rect,

  /// Circular avatar placeholder.
  circle,

  /// Short text line.
  text,
}

/// Shimmering skeleton placeholder.
///
/// Use the named presets ([PfSkeletonText], [PfSkeletonCard],
/// [PfSkeletonCircle]) for common cases, or this widget directly for custom
/// blocks.
class PfSkeleton extends StatefulWidget {
  /// Creates a skeleton block.
  const PfSkeleton({
    super.key,
    this.shape = PfSkeletonShape.rect,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius,
  });

  /// Visual shape.
  final PfSkeletonShape shape;

  /// Width. Ignored for [PfSkeletonShape.circle] (uses [height]).
  final double width;

  /// Height (and diameter for a circle).
  final double height;

  /// Border radius override.
  final BorderRadius? borderRadius;

  @override
  State<PfSkeleton> createState() => _PfSkeletonState();
}

class _PfSkeletonState extends State<PfSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      // Shimmer period: PfMotion.deliberate (600 ms), bouncing back and forth.
      duration: PfMotion.deliberate,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    // Under reduced motion (and in widget tests that enable it), freeze the
    // shimmer at a static mid-tone instead of repeating forever — an
    // ever-repeating controller never lets `pumpAndSettle` complete.
    if (reduceMotion) {
      if (_controller.isAnimating) _controller.stop();
      _controller.value = 0.5;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final BorderRadius radius = widget.borderRadius ??
        (widget.shape == PfSkeletonShape.circle
            ? BorderRadius.circular(widget.height)
            : BorderRadius.circular(
                widget.shape == PfSkeletonShape.text ? 4 : context.fnxRadii.r2,
              ));

    // Base block tinted to the neutral surface; the ShaderMask sweeps a
    // lighter highlight over it.
    final Widget block = ClipRRect(
      borderRadius: radius,
      child: ColoredBox(
        color: PfColors.neutral200,
        child: SizedBox(
          width: widget.shape == PfSkeletonShape.circle
              ? widget.height
              : widget.width,
          height: widget.height,
        ),
      ),
    );

    return Semantics(
      label: 'Loading',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext _, Widget? child) {
          // Static mid-position when reduced motion is on.
          final double t = reduceMotion ? 0.5 : _controller.value;
          return ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment(-1.0 - 2 * (1 - t), 0),
                end: Alignment(1.0 + 2 * t, 0),
                colors: const <Color>[
                  PfColors.neutral200,
                  PfColors.neutral100,
                  PfColors.neutral200,
                ],
                stops: const <double>[0.35, 0.5, 0.65],
              ).createShader(bounds);
            },
            child: child,
          );
        },
        child: block,
      ),
    );
  }
}

/// One or more skeleton text lines.
///
/// Renders [lines] stacked rows; the last line is shortened to
/// [lastLineFraction] of the available width for a natural ragged look.
class PfSkeletonText extends StatelessWidget {
  /// Creates a text skeleton.
  const PfSkeletonText({
    super.key,
    this.lines = 1,
    this.lineHeight = 14,
    this.spacing = 8,
    this.lastLineFraction = 0.6,
  });

  /// Number of lines to render.
  final int lines;

  /// Height of each line.
  final double lineHeight;

  /// Vertical gap between lines.
  final double spacing;

  /// Width fraction for the final line (0–1). Only applied when [lines] > 1.
  final double lastLineFraction;

  @override
  Widget build(BuildContext context) {
    if (lines <= 1) {
      return PfSkeleton(shape: PfSkeletonShape.text, height: lineHeight);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (int i = 0; i < lines; i++) ...<Widget>[
          if (i > 0) SizedBox(height: spacing),
          if (i == lines - 1)
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: lastLineFraction.clamp(0.1, 1.0),
              child: PfSkeleton(
                shape: PfSkeletonShape.text,
                height: lineHeight,
              ),
            )
          else
            PfSkeleton(shape: PfSkeletonShape.text, height: lineHeight),
        ],
      ],
    );
  }
}

/// A rounded-rectangle card-shaped skeleton block.
class PfSkeletonCard extends StatelessWidget {
  /// Creates a card skeleton.
  const PfSkeletonCard({
    super.key,
    this.height = 120,
    this.width = double.infinity,
    this.borderRadius,
  });

  /// Card height.
  final double height;

  /// Card width.
  final double width;

  /// Corner radius (defaults to the card radius token).
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return PfSkeleton(
      width: width,
      height: height,
      borderRadius:
          borderRadius ?? BorderRadius.circular(context.fnxRadii.r4),
    );
  }
}

/// A circular skeleton (avatar / icon placeholder).
class PfSkeletonCircle extends StatelessWidget {
  /// Creates a circular skeleton of the given [size] (diameter).
  const PfSkeletonCircle({super.key, this.size = 40});

  /// Diameter.
  final double size;

  @override
  Widget build(BuildContext context) {
    return PfSkeleton(shape: PfSkeletonShape.circle, height: size);
  }
}
