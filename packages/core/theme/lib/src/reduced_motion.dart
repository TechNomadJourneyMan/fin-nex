import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the user (or the OS) has asked the app to minimize animation.
///
/// Backed by [MediaQueryData.disableAnimations] / [MediaQuery.disableAnimationsOf].
/// Because that flag is only reachable from a [BuildContext], read it inside a
/// [ConsumerWidget] build and feed it into this provider via a scoped override:
///
/// ```dart
/// class MotionScope extends ConsumerWidget {
///   const MotionScope({super.key, required this.child});
///   final Widget child;
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     return ProviderScope(
///       overrides: <Override>[
///         reducedMotionProvider.overrideWithValue(
///           MediaQuery.disableAnimationsOf(context),
///         ),
///       ],
///       child: child,
///     );
///   }
/// }
/// ```
///
/// Defaults to `false` (animations enabled) when no scope override is present,
/// matching Flutter's default. Pair with `PfMotion.effective(context, d)` for
/// the per-call-site duration gating.
final Provider<bool> reducedMotionProvider = Provider<bool>(
  (Ref ref) => false,
  name: 'reducedMotionProvider',
);

/// Reads [MediaQuery.disableAnimationsOf] for [context].
///
/// A convenience so call-sites that already hold a [BuildContext] can ask the
/// question directly without wiring the provider scope. Equivalent to the
/// value [reducedMotionProvider] exposes once overridden.
bool reducedMotionOf(BuildContext context) =>
    MediaQuery.disableAnimationsOf(context);
