// Shimmer skeleton placeholder for FinNex.

import 'package:flutter/material.dart';

import 'fnx_theme_ext.dart';

/// Shape variant for [FnxSkeleton].
enum FnxSkeletonShape {
  /// Rectangular block.
  rect,

  /// Circular avatar placeholder.
  circle,

  /// Short text line.
  text,
}

/// Shimmering skeleton placeholder.
class FnxSkeleton extends StatefulWidget {
  /// Creates a skeleton.
  const FnxSkeleton({
    super.key,
    this.shape = FnxSkeletonShape.rect,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius,
  });

  /// Visual shape.
  final FnxSkeletonShape shape;

  /// Width.
  final double width;

  /// Height.
  final double height;

  /// Border radius override.
  final BorderRadius? borderRadius;

  @override
  State<FnxSkeleton> createState() => _FnxSkeletonState();
}

class _FnxSkeletonState extends State<FnxSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.fnxColors;
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final radius = widget.borderRadius ??
        (widget.shape == FnxSkeletonShape.circle
            ? BorderRadius.circular(widget.height)
            : BorderRadius.circular(widget.shape == FnxSkeletonShape.text
                ? 4
                : context.fnxRadii.r2));

    return Semantics(
      label: 'Loading',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          final t = reduceMotion ? 0.5 : _controller.value;
          return Container(
            width: widget.shape == FnxSkeletonShape.circle
                ? widget.height
                : widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: LinearGradient(
                begin: Alignment(-1.0 + 2 * t, 0),
                end: Alignment(1.0 + 2 * t, 0),
                colors: [
                  colors.surfaceSunken,
                  colors.borderSubtle,
                  colors.surfaceSunken,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
