// Root [MaterialApp.router] widget for FinNex.
//
// Reads the active theme mode and locale from the settings feature so user
// preferences take effect app-wide. Falls back to system defaults when the
// settings provider is overridden in tests.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fnx_core_l10n/fnx_core_l10n.dart';
import 'package:fnx_core_theme/fnx_core_theme.dart';
import 'package:fnx_feat_settings/settings.dart' as settings;

import 'routes.dart';

/// Top-level application widget. Hosts the router, theme and locale.
class FinNexApp extends ConsumerWidget {
  /// Create the root FinNex application widget.
  const FinNexApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode themeMode = ref.watch(settings.themeProvider);
    final Locale? locale = ref.watch(settings.localeProvider);

    return MaterialApp.router(
      title: 'FinNex',
      debugShowCheckedModeBanner: false,
      theme: FnxTheme.light(),
      darkTheme: FnxTheme.dark(),
      themeMode: themeMode,
      locale: locale,
      supportedLocales: FnxLocales.all,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppL10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: finnexRouter,
    );
  }
}
