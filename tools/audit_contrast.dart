// WCAG 2.1 contrast auditor for the PocketFlow color tokens.
//
// Computes the contrast ratio for every meaningful (text on surface) pair in
// both the light and dark schemes and prints a Markdown table to stdout. This
// is a *report-only* tool — it never mutates the palette.
//
// Because it imports `package:pf_core_tokens` (which pulls in `dart:ui`'s
// [Color]), run it through Flutter from a package that depends on the tokens.
// The simplest path is to copy it into `apps/pocketflow/test/` and run it with
// `flutter test`, or drive it from a tiny harness that calls [buildReport].
// The output captured in DECISIONS.md was produced this way.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pf_core_tokens/pf_core_tokens.dart';

/// Relative luminance per WCAG 2.1 (sRGB).
double _luminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();

  // `Color.r/g/b` are normalized 0..1 doubles in current Flutter.
  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

/// Contrast ratio between two colors (>= 1.0). Order-independent.
double contrastRatio(Color a, Color b) {
  final double la = _luminance(a);
  final double lb = _luminance(b);
  final double hi = math.max(la, lb);
  final double lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

/// A single foreground/background pair to evaluate.
class ContrastPair {
  /// Const constructor.
  const ContrastPair(this.fgName, this.fg, this.bgName, this.bg);

  /// Foreground (text) token name.
  final String fgName;

  /// Foreground color.
  final Color fg;

  /// Background (surface) token name.
  final String bgName;

  /// Background color.
  final Color bg;
}

List<ContrastPair> _pairsFor(String scheme, PfColors c) {
  final List<MapEntry<String, Color>> surfaces = <MapEntry<String, Color>>[
    MapEntry<String, Color>('surfaceBackground', c.surfaceBackground),
    MapEntry<String, Color>('surfaceDefault', c.surfaceDefault),
    MapEntry<String, Color>('surfaceRaised', c.surfaceRaised),
    MapEntry<String, Color>('surfaceSunken', c.surfaceSunken),
  ];
  final List<MapEntry<String, Color>> texts = <MapEntry<String, Color>>[
    MapEntry<String, Color>('textPrimary', c.textPrimary),
    MapEntry<String, Color>('textSecondary', c.textSecondary),
    MapEntry<String, Color>('textMuted', c.textMuted),
    MapEntry<String, Color>('textBrand', c.textBrand),
    MapEntry<String, Color>('textSuccess', c.textSuccess),
    MapEntry<String, Color>('textError', c.textError),
  ];
  return <ContrastPair>[
    for (final MapEntry<String, Color> t in texts)
      for (final MapEntry<String, Color> s in surfaces)
        ContrastPair('$scheme/${t.key}', t.value, s.key, s.value),
  ];
}

/// Hex string for a [Color] (e.g. `#3D5AFE`).
String hex(Color c) {
  String two(double v) => (v * 255).round().toRadixString(16).padLeft(2, '0');
  return '#${two(c.r)}${two(c.g)}${two(c.b)}'.toUpperCase();
}

/// Builds the full Markdown contrast report for both schemes.
String buildReport() {
  final List<ContrastPair> pairs = <ContrastPair>[
    ..._pairsFor('light', PfColors.light),
    ..._pairsFor('dark', PfColors.dark),
  ];

  final StringBuffer b = StringBuffer()
    ..writeln('| foreground | background | ratio | AA-normal | AA-large |')
    ..writeln('|------------|------------|-------|-----------|----------|');
  for (final ContrastPair p in pairs) {
    final double r = contrastRatio(p.fg, p.bg);
    b.writeln('| ${p.fgName} ${hex(p.fg)} '
        '| ${p.bgName} ${hex(p.bg)} '
        '| ${r.toStringAsFixed(2)} '
        '| ${r >= 4.5 ? 'PASS' : 'FAIL'} '
        '| ${r >= 3.0 ? 'PASS' : 'FAIL'} |');
  }
  return b.toString();
}

void main() {
  // ignore: avoid_print
  print(buildReport());
}
