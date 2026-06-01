import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// PocketFlow motion tokens — Material 3 durations and easing curves.
@immutable
class PfMotion extends ThemeExtension<PfMotion> {
  /// Const constructor.
  const PfMotion();

  /// 75 ms — micro interactions.
  static const Duration instant = Duration(milliseconds: 75);
  /// 150 ms — button press, toggle.
  static const Duration fast = Duration(milliseconds: 150);
  /// 250 ms — default for most transitions.
  static const Duration base = Duration(milliseconds: 250);
  /// 400 ms — page transitions, container transform.
  static const Duration slow = Duration(milliseconds: 400);
  /// 600 ms — onboarding sequences, celebrations.
  static const Duration deliberate = Duration(milliseconds: 600);

  /// Default — most transitions.
  static const Cubic standard = Cubic(0.2, 0.0, 0.0, 1.0);
  /// Hero transitions / primary CTAs.
  static const Cubic emphasized = Cubic(0.2, 0.0, 0.0, 1.0);
  /// Entering content.
  static const Cubic decelerated = Cubic(0.0, 0.0, 0.0, 1.0);
  /// Exiting content.
  static const Cubic accelerated = Cubic(0.3, 0.0, 1.0, 1.0);

  @override
  PfMotion copyWith() => const PfMotion();

  @override
  ThemeExtension<PfMotion> lerp(ThemeExtension<PfMotion>? other, double t) =>
      this;
}
