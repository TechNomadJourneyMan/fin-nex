import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnx_core_tokens/tokens.dart';

void main() {
  test('Primitive ramp constants are non-transparent', () {
    final ramp = <Color>[
      FnxColors.indigo50,
      FnxColors.indigo100,
      FnxColors.indigo200,
      FnxColors.indigo300,
      FnxColors.indigo400,
      FnxColors.primary500,
      FnxColors.indigo600,
      FnxColors.indigo700,
      FnxColors.indigo800,
      FnxColors.indigo900,
      FnxColors.mint100,
      FnxColors.mint500,
      FnxColors.mint600,
      FnxColors.coral100,
      FnxColors.coral500,
      FnxColors.amber500,
      FnxColors.neutral0,
      FnxColors.neutral50,
      FnxColors.neutral100,
      FnxColors.neutral200,
      FnxColors.neutral300,
      FnxColors.neutral400,
      FnxColors.neutral500,
      FnxColors.neutral600,
      FnxColors.neutral700,
      FnxColors.neutral800,
      FnxColors.neutral900,
      FnxColors.neutral950,
    ];
    for (final c in ramp) {
      expect(c.alpha, 0xFF, reason: 'Color $c must be fully opaque');
    }
  });

  test('Light + dark semantic bundles expose distinct surfaces', () {
    expect(FnxColors.light.surfaceBackground,
        isNot(equals(FnxColors.dark.surfaceBackground)));
    expect(FnxColors.light.textPrimary,
        isNot(equals(FnxColors.dark.textPrimary)));
  });

  test('Data-viz palette has exactly 8 entries', () {
    expect(FnxColors.datavizLight.length, 8);
    expect(FnxColors.datavizDark.length, 8);
  });

  test('primary500 matches the documented brand hex 0xFF3D5AFE', () {
    expect(FnxColors.primary500.value, 0xFF3D5AFE);
  });
}
