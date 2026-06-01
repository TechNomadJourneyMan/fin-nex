import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pf_core_tokens/tokens.dart';

void main() {
  test('Primitive ramp constants are non-transparent', () {
    final ramp = <Color>[
      PfColors.indigo50,
      PfColors.indigo100,
      PfColors.indigo200,
      PfColors.indigo300,
      PfColors.indigo400,
      PfColors.primary500,
      PfColors.indigo600,
      PfColors.indigo700,
      PfColors.indigo800,
      PfColors.indigo900,
      PfColors.mint100,
      PfColors.mint500,
      PfColors.mint600,
      PfColors.coral100,
      PfColors.coral500,
      PfColors.amber500,
      PfColors.neutral0,
      PfColors.neutral50,
      PfColors.neutral100,
      PfColors.neutral200,
      PfColors.neutral300,
      PfColors.neutral400,
      PfColors.neutral500,
      PfColors.neutral600,
      PfColors.neutral700,
      PfColors.neutral800,
      PfColors.neutral900,
      PfColors.neutral950,
    ];
    for (final c in ramp) {
      expect(c.alpha, 0xFF, reason: 'Color $c must be fully opaque');
    }
  });

  test('Light + dark semantic bundles expose distinct surfaces', () {
    expect(PfColors.light.surfaceBackground,
        isNot(equals(PfColors.dark.surfaceBackground)));
    expect(PfColors.light.textPrimary,
        isNot(equals(PfColors.dark.textPrimary)));
  });

  test('Data-viz palette has exactly 8 entries', () {
    expect(PfColors.datavizLight.length, 8);
    expect(PfColors.datavizDark.length, 8);
  });

  test('primary500 matches the documented brand hex 0xFF3D5AFE', () {
    expect(PfColors.primary500.value, 0xFF3D5AFE);
  });
}
