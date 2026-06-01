// Verifies [ThemeController] cycles through and persists ThemeMode.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pf_feat_settings/settings.dart';

void main() {
  group('themeProvider', () {
    late InMemoryPreferencesStore store;
    late ProviderContainer container;

    setUp(() {
      store = InMemoryPreferencesStore();
      container = ProviderContainer(
        overrides: <Override>[
          preferencesStoreProvider.overrideWithValue(store),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('defaults to ThemeMode.system', () {
      expect(container.read(themeProvider), ThemeMode.system);
    });

    test('set persists the new mode', () async {
      await container.read(themeProvider.notifier).set(ThemeMode.dark);
      expect(container.read(themeProvider), ThemeMode.dark);
      expect(await store.getString(PreferenceKeys.theme), 'dark');
    });

    test('toggle cycles system → light → dark → system', () async {
      final ctl = container.read(themeProvider.notifier);
      await ctl.toggle();
      expect(container.read(themeProvider), ThemeMode.light);
      await ctl.toggle();
      expect(container.read(themeProvider), ThemeMode.dark);
      await ctl.toggle();
      expect(container.read(themeProvider), ThemeMode.system);
    });

    test('hydrates from the store on construction', () async {
      final seeded = InMemoryPreferencesStore(<String, Object?>{
        PreferenceKeys.theme: 'light',
      });
      final c = ProviderContainer(
        overrides: <Override>[
          preferencesStoreProvider.overrideWithValue(seeded),
        ],
      );
      addTearDown(c.dispose);
      // Force creation of the controller and let the async hydrate run.
      c.read(themeProvider.notifier);
      await Future<void>.delayed(const Duration(milliseconds: 1));
      expect(c.read(themeProvider), ThemeMode.light);
    });
  });
}
