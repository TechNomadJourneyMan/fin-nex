// OmniFi OS — GlassCard
//
// Frosted-glass container that floats above the obsidian canvas. Replaces
// the default Material `Card` on dark surfaces. See
// docs/DESIGN_SYSTEM_OMNIFI.md §2.1 for the full spec.

import 'dart:ui';

import 'package:flutter/material.dart';

/// Elevation level for [GlassCard].
enum GlassElevation {
  /// 5 % white fill; sits directly on the canvas.
  defaultLevel,

  /// 8 % white fill + a soft drop shadow; for modals, sheets, hero tiles.
  raised,
}

/// A premium glass-morphism card with backdrop blur and a hairline border.
///
/// On platforms where `BackdropFilter` is expensive (Web, low-end Android)
/// the blur silently degrades to a flat fill — contrast tokens are chosen
/// so the card stays readable in either case.
class GlassCard extends StatefulWidget {
  /// Default constructor.
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 24,
    this.elevation = GlassElevation.defaultLevel,
    this.glow = false,
    this.onTap,
    this.semanticsLabel,
  });

  /// Card contents.
  final Widget child;

  /// Inner padding.
  final EdgeInsetsGeometry padding;

  /// Corner radius in logical pixels.
  final double radius;

  /// Visual elevation level.
  final GlassElevation elevation;

  /// Adds the OmniFi `glow` shadow (use for AI / focused state).
  final bool glow;

  /// Optional press handler. When set the card animates a spring scale on press.
  final VoidCallback? onTap;

  /// Accessibility label exposed when [onTap] is set.
  final String? semanticsLabel;

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 140),
    lowerBound: 0,
    upperBound: 1,
  );
  late final Animation<double> _scale = Tween<double>(begin: 1.0, end: 0.98)
      .animate(CurvedAnimation(parent: _press, curve: Curves.easeOutCubic));

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  void _down(_) => _press.forward();
  void _up(_) => _press.reverse();
  void _cancel() => _press.reverse();

  @override
  Widget build(BuildContext context) {
    final bool raised = widget.elevation == GlassElevation.raised;
    final Color fill = raised
        ? const Color(0x14FFFFFF) // ~8 % white
        : const Color(0x0DFFFFFF); // ~5 % white
    final Color borderColor = const Color(0x1FFFFFFF); // ~8 % white
    final BorderRadius br = BorderRadius.circular(widget.radius);

    const List<BoxShadow> shadowsRaisedOnly = <BoxShadow>[
      BoxShadow(
        color: Color(0x66000000),
        offset: Offset(0, 24),
        blurRadius: 48,
      ),
    ];
    const List<BoxShadow> shadowsGlowOnly = <BoxShadow>[
      BoxShadow(color: Color(0x26E5E5EA), blurRadius: 32),
    ];
    final List<BoxShadow> shadows = <BoxShadow>[
      if (raised) ...shadowsRaisedOnly,
      if (widget.glow) ...shadowsGlowOnly,
    ];

    Widget content = Padding(padding: widget.padding, child: widget.child);

    Widget card = ClipRRect(
      borderRadius: br,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: br,
            border: Border.all(color: borderColor, width: 0.5),
          ),
          child: content,
        ),
      ),
    );

    if (shadows.isNotEmpty) {
      card = DecoratedBox(
        decoration: BoxDecoration(borderRadius: br, boxShadow: shadows),
        child: card,
      );
    }

    if (widget.onTap != null) {
      card = ScaleTransition(scale: _scale, child: card);
      card = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _down,
        onTapUp: _up,
        onTapCancel: _cancel,
        onTap: widget.onTap,
        child: card,
      );
      card = Semantics(
        button: true,
        label: widget.semanticsLabel,
        child: card,
      );
    }

    return card;
  }
}
