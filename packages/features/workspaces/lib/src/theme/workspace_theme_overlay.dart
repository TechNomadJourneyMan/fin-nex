// Theme overlay that tints a subtree based on the active workspace's color.
//
// Per PRD F-06, personal workspaces lean Tech Dark Blue (indigo) and business
// workspaces lean Tech Emerald Green (mint). The workspace's own `colorHex`
// takes precedence; the type only supplies the fallback accent.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fnx_domain/domain.dart';

import '../providers.dart';

/// PRD F-06 accent for personal workspaces — Tech Dark Blue (indigo).
const Color kWorkspacePersonalAccent = Color(0xFF3D5AFE);

/// PRD F-06 accent for business workspaces — Tech Emerald Green (mint).
const Color kWorkspaceBusinessAccent = Color(0xFF00A87D);

/// Parses a `#RRGGBB` (or `RRGGBB`) hex string into a [Color], returning
/// [fallback] when the string is null or malformed.
Color workspaceColorFromHex(String? hex, {required Color fallback}) {
  if (hex == null) {
    return fallback;
  }
  var v = hex.trim();
  if (v.startsWith('#')) {
    v = v.substring(1);
  }
  if (v.length != 6) {
    return fallback;
  }
  final value = int.tryParse(v, radix: 16);
  if (value == null) {
    return fallback;
  }
  return Color(0xFF000000 | value);
}

/// Resolves the accent color for [workspace]: its explicit [Workspace.colorHex]
/// if valid, otherwise the type-based PRD fallback.
Color workspaceAccentColor(Workspace workspace) {
  final fallback = workspace.type == WorkspaceType.business
      ? kWorkspaceBusinessAccent
      : kWorkspacePersonalAccent;
  return workspaceColorFromHex(workspace.colorHex, fallback: fallback);
}

/// Wraps [child] in a [Theme] whose color scheme is nudged toward the active
/// workspace's accent color.
///
/// Tinting is intentionally subtle: only the seed/primary and a faint surface
/// tint are adjusted so the workspace identity reads without overwhelming the
/// design-system palette. When no workspace is active the [child] is returned
/// with the ambient theme untouched.
class WorkspaceThemeOverlay extends ConsumerWidget {
  /// Wraps [child] with the active workspace's tint.
  const WorkspaceThemeOverlay({super.key, required this.child});

  /// The subtree to tint.
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workspace = ref.watch(activeWorkspaceEntityProvider);
    if (workspace == null) {
      return child;
    }
    return WorkspaceThemeScope(
      accent: workspaceAccentColor(workspace),
      child: child,
    );
  }
}

/// Applies an [accent]-tinted theme to [child]. Pulled out from
/// [WorkspaceThemeOverlay] so it can be exercised in widget tests without a
/// Riverpod scope.
class WorkspaceThemeScope extends StatelessWidget {
  /// Tints [child] with [accent].
  const WorkspaceThemeScope({
    super.key,
    required this.accent,
    required this.child,
  });

  /// The workspace accent color driving the tint.
  final Color accent;

  /// The subtree to tint.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final scheme = base.colorScheme.copyWith(
      primary: accent,
      secondary: accent,
      // Faintly tint the surface so the workspace identity is felt.
      surfaceTint: accent,
    );
    return Theme(
      data: base.copyWith(
        colorScheme: scheme,
        primaryColor: accent,
      ),
      child: child,
    );
  }
}
