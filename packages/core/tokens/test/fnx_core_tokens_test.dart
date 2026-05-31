import 'package:flutter_test/flutter_test.dart';
import 'package:fnx_core_tokens/fnx_core_tokens.dart';

void main() {
  test('FnxTokens exposes the brand primary color', () {
    expect(FnxTokens.brandPrimary, equals(FnxColors.primary500));
  });

  test('Spacing scale is monotonically increasing', () {
    expect(FnxTokens.space1 < FnxTokens.space2, isTrue);
    expect(FnxTokens.space2 < FnxTokens.space4, isTrue);
    expect(FnxTokens.space4 < FnxTokens.space8, isTrue);
  });
}
