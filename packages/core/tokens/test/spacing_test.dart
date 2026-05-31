import 'package:flutter_test/flutter_test.dart';
import 'package:fnx_core_tokens/tokens.dart';

void main() {
  test('FnxSpacing scale matches the 4px base ramp', () {
    expect(FnxSpacing.x0, 0);
    expect(FnxSpacing.x1, 4);
    expect(FnxSpacing.x2, 8);
    expect(FnxSpacing.x3, 12);
    expect(FnxSpacing.x4, 16);
    expect(FnxSpacing.x6, 24);
    expect(FnxSpacing.x8, 32);
    expect(FnxSpacing.x12, 48);
    expect(FnxSpacing.x16, 64);
  });

  test('FnxRadius pill is effectively infinite', () {
    expect(FnxRadius.pill.topLeft.x, greaterThanOrEqualTo(999));
  });

  test('FnxBreakpoints are monotonically increasing', () {
    expect(FnxBreakpoints.sm < FnxBreakpoints.md, isTrue);
    expect(FnxBreakpoints.md < FnxBreakpoints.lg, isTrue);
    expect(FnxBreakpoints.lg < FnxBreakpoints.xl, isTrue);
  });
}
