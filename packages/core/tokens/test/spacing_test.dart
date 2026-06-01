import 'package:flutter_test/flutter_test.dart';
import 'package:pf_core_tokens/tokens.dart';

void main() {
  test('PfSpacing scale matches the 4px base ramp', () {
    expect(PfSpacing.x0, 0);
    expect(PfSpacing.x1, 4);
    expect(PfSpacing.x2, 8);
    expect(PfSpacing.x3, 12);
    expect(PfSpacing.x4, 16);
    expect(PfSpacing.x6, 24);
    expect(PfSpacing.x8, 32);
    expect(PfSpacing.x12, 48);
    expect(PfSpacing.x16, 64);
  });

  test('PfRadius pill is effectively infinite', () {
    expect(PfRadius.pill.topLeft.x, greaterThanOrEqualTo(999));
  });

  test('PfBreakpoints are monotonically increasing', () {
    expect(PfBreakpoints.sm < PfBreakpoints.md, isTrue);
    expect(PfBreakpoints.md < PfBreakpoints.lg, isTrue);
    expect(PfBreakpoints.lg < PfBreakpoints.xl, isTrue);
  });
}
