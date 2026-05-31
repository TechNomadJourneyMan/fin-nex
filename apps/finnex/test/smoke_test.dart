// Smoke test: ensure [FinNexApp] mounts without throwing.

import 'package:finnex/app.dart';
import 'package:finnex/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('FinNexApp mounts without errors', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: buildAppProviderOverrides(),
        child: const FinNexApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
  });
}
