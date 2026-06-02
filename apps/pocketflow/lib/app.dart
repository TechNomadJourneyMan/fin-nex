// Root [MaterialApp.router] widget for PocketFlow.
//
// Reads the active theme mode and locale from the settings feature so user
// preferences take effect app-wide. Falls back to system defaults when the
// settings provider is overridden in tests.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_core_l10n/pf_core_l10n.dart';
import 'package:pf_core_theme/pf_core_theme.dart';
import 'package:pf_feat_settings/settings.dart' as settings;
import 'package:pf_feat_transactions/transactions.dart' as transactions;

import 'intents.dart';
import 'routes.dart';
import 'widgets/command_palette.dart';

/// Top-level application widget. Hosts the router, theme and locale.
class PocketFlowApp extends ConsumerStatefulWidget {
  /// Create the root PocketFlow application widget.
  const PocketFlowApp({super.key});

  @override
  ConsumerState<PocketFlowApp> createState() => _PocketFlowAppState();
}

class _PocketFlowAppState extends ConsumerState<PocketFlowApp> {
  /// True while a palette dialog is open, so repeated Cmd+K presses don't
  /// stack dialogs.
  bool _paletteOpen = false;

  @override
  void initState() {
    super.initState();
    // Materialise any due recurring rules on app start. Idempotent — safe to
    // run unconditionally; no-op when there are no due rules.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      // ignore: discarded_futures
      transactions.runRecurringEngine(ref);
    });
  }

  void _openCommandPalette() {
    // Command palette is a web/desktop affordance; no-op on touch platforms.
    if (!kIsWeb) {
      return;
    }
    // Use the router's root navigator context so the dialog route resolves
    // against a Navigator (the MaterialApp.router builder context does not
    // include one).
    final BuildContext? ctx = rootNavigatorKey.currentContext;
    if (ctx == null || _paletteOpen) {
      return;
    }
    _paletteOpen = true;
    showCommandPalette(ctx).whenComplete(() => _paletteOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    // OmniFi OS: dark mode is the canonical look — premium obsidian +
    // glassmorphism surfaces. Light mode is still available via the settings
    // page but the app launches into dark.
    final ThemeMode themeMode = ref.watch(settings.themeProvider);
    final ThemeMode resolvedMode =
        themeMode == ThemeMode.system ? ThemeMode.dark : themeMode;
    final Locale? locale = ref.watch(settings.localeProvider);

    // High-contrast accessibility theme swaps in the pure black/white +
    // saturated-brand variants for both brightnesses.
    final bool highContrast = ref.watch(settings.highContrastProvider);
    final ThemeData lightTheme =
        highContrast ? PfTheme.lightHighContrast() : PfTheme.light();
    final ThemeData darkTheme =
        highContrast ? PfTheme.darkHighContrast() : PfTheme.dark();

    // App-wide keyboard shortcuts (web/desktop). Cmd+K / Ctrl+K opens the
    // command palette; Esc maps to Flutter's built-in DismissIntent, which
    // dialogs and bottom sheets already honor to close.
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.keyK, meta: true):
            OpenCommandPaletteIntent(),
        SingleActivator(LogicalKeyboardKey.keyK, control: true):
            OpenCommandPaletteIntent(),
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          OpenCommandPaletteIntent:
              OpenCommandPaletteAction(_openCommandPalette),
        },
        child: MaterialApp.router(
          title: 'Pocket Flow',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: resolvedMode,
          locale: locale,
          supportedLocales: PfLocales.all,
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            AppL10n.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: pocketFlowRouter,
        ),
      ),
    );
  }
}
