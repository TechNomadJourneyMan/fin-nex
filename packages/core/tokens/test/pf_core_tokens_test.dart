import 'package:flutter_test/flutter_test.dart';
import 'package:pf_core_tokens/pf_core_tokens.dart';

void main() {
  test('PfTokens exposes the brand primary color', () {
    expect(PfTokens.brandPrimary, equals(PfColors.primary500));
  });

  test('Spacing scale is monotonically increasing', () {
    expect(PfTokens.space1 < PfTokens.space2, isTrue);
    expect(PfTokens.space2 < PfTokens.space4, isTrue);
    expect(PfTokens.space4 < PfTokens.space8, isTrue);
  });
}
