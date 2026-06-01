// Smoke test: ensure [PocketFlowApp] mounts without throwing.

import 'package:pocketflow/app.dart';
import 'package:pocketflow/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('PocketFlowApp mounts without errors', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: buildAppProviderOverrides(),
        child: const PocketFlowApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
  });
}
