// OmniFi OS — DynamicIslandActions
//
// Floating glass pill that hosts 2–4 quick actions above the canvas. See
// docs/DESIGN_SYSTEM_OMNIFI.md §2.3 for the full spec.

import 'dart:ui';

import 'package:flutter/material.dart';

/// One slot of [DynamicIslandActions].
class IslandAction {
  /// Default constructor.
  const IslandAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  /// Icon to render. Use outlined variants for a thin, premium look.
  final IconData icon;

  /// Accessibility label and tooltip text.
  final String label;

  /// Press handler.
  final VoidCallback onTap;
}

/// Floating, glass-frosted action pill that hovers above the bottom safe area.
class DynamicIslandActions extends StatefulWidget {
  /// Default constructor. Provide 2 – 4 actions.
  const DynamicIslandActions({
    super.key,
    required this.actions,
    this.expanded = false,
    this.pulsingIndex,
  }) : assert(
          actions.length >= 1 && actions.length <= 4,
          'Provide 1 – 4 actions for the dynamic island.',
        );

  /// 2 – 4 action slots.
  final List<IslandAction> actions;

  /// When true, shows labels next to icons (good for tablet/desktop).
  final bool expanded;

  /// If set, the action at that index gets a breathing glow (AI prompt).
  final int? pulsingIndex;

  @override
  State<DynamicIslandActions> createState() => _DynamicIslandActionsState();
}

class _DynamicIslandActionsState extends State<DynamicIslandActions>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color borderColor = Color(0x1FFFFFFF);
    const Color fill = Color(0x14FFFFFF);
    final BorderRadius br = BorderRadius.circular(999);

    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: br,
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x66000000),
                  offset: Offset(0, 24),
                  blurRadius: 48,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: br,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Container(
                  decoration: BoxDecoration(
                    color: fill,
                    borderRadius: br,
                    border: Border.all(color: borderColor, width: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      for (int i = 0;
                          i < widget.actions.length;
                          i++) ...<Widget>[
                        _IslandIconButton(
                          action: widget.actions[i],
                          expanded: widget.expanded,
                          pulse: widget.pulsingIndex == i ? _pulse : null,
                        ),
                        if (i < widget.actions.length - 1)
                          const SizedBox(width: 12),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IslandIconButton extends StatefulWidget {
  const _IslandIconButton({
    required this.action,
    required this.expanded,
    this.pulse,
  });

  final IslandAction action;
  final bool expanded;
  final Animation<double>? pulse;

  @override
  State<_IslandIconButton> createState() => _IslandIconButtonState();
}

class _IslandIconButtonState extends State<_IslandIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 140),
    lowerBound: 0,
    upperBound: 1,
  );
  late final Animation<double> _scale = Tween<double>(begin: 1.0, end: 1.06)
      .animate(CurvedAnimation(parent: _press, curve: Curves.easeOutCubic));

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final IconData icon = widget.action.icon;
    const Color iconColor = Color(0xFFF2F2F3);

    Widget glowWrap(Widget child) {
      if (widget.pulse == null) return child;
      return AnimatedBuilder(
        animation: widget.pulse!,
        builder: (BuildContext _, Widget? c) {
          final double t = widget.pulse!.value;
          return DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: const Color(0xFFE5E5EA)
                      .withValues(alpha: 0.10 + 0.20 * t),
                  blurRadius: 16 + 16 * t,
                ),
              ],
            ),
            child: c,
          );
        },
        child: child,
      );
    }

    Widget content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: iconColor, size: 22),
          if (widget.expanded) ...<Widget>[
            const SizedBox(width: 8),
            Text(
              widget.action.label,
              style: const TextStyle(
                color: Color(0xFFF2F2F3),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );

    content = ScaleTransition(scale: _scale, child: content);

    return Tooltip(
      message: widget.action.label,
      child: Semantics(
        button: true,
        label: widget.action.label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _press.forward(),
          onTapUp: (_) => _press.reverse(),
          onTapCancel: () => _press.reverse(),
          onTap: widget.action.onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            child: glowWrap(content),
          ),
        ),
      ),
    );
  }
}
