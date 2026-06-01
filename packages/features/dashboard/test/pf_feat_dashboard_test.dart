// Smoke test that the public barrel imports without errors.

import 'package:flutter_test/flutter_test.dart';
import 'package:pf_feat_dashboard/pf_feat_dashboard.dart';

void main() {
  test('pf_feat_dashboard barrel is importable', () {
    // Reference a public symbol to ensure the import is type-checked.
    expect(DashboardPeriod.values, isNotEmpty);
  });
}
