import 'package:flutter/foundation.dart';

/// PocketFlow responsive breakpoints (logical pixels).
@immutable
class PfBreakpoints {
  /// Const constructor — values are static.
  const PfBreakpoints();

  /// Small phones — 375 px.
  static const double sm = 375;

  /// Tablet portrait — 600 px.
  static const double md = 600;

  /// Tablet landscape / small desktop — 960 px.
  static const double lg = 960;

  /// Large desktop — 1280 px.
  static const double xl = 1280;
}
