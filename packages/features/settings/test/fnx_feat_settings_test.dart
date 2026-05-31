// Smoke test that the public barrel imports without errors.

import 'package:flutter_test/flutter_test.dart';
import 'package:fnx_feat_settings/fnx_feat_settings.dart';

void main() {
  test('fnx_feat_settings barrel is importable', () {
    // Reference a public symbol to ensure the import is type-checked.
    expect(PreferenceKeys.theme, isNotEmpty);
  });
}
