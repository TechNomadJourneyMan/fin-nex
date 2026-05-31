// FinNex app entrypoint.
//
// Wires up Riverpod (with cross-feature provider overrides), error handling
// and the root [FinNexApp] widget. All cross-cutting concerns (theme,
// router, locale) live in [FinNexApp] so that tests can mount it directly.

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'bootstrap.dart';
import 'providers.dart';

/// Application entrypoint.
void main() {
  bootstrap(() {
    runApp(
      ProviderScope(
        overrides: buildAppProviderOverrides(),
        child: const FinNexApp(),
      ),
    );
  });
}
