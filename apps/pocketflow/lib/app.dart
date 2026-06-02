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
import 'package:pf_feat_dashboard/dashboard.dart' as dashboard;
import 'package:pf_feat_notifications/pf_feat_notifications.dart' as notif;
import 'package:pf_feat_settings/settings.dart' as settings;
import 'package:pf_feat_subscriptions/subscriptions.dart' as subs;
import 'package:pf_feat_transactions/transactions.dart' as transactions;

import 'intents.dart';
import 'routes.dart';
import 'services/home_surface_updater.dart';
import 'services/test_env.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      // These startup side-effects (recurring-rule materialisation, native
      // notification permission, home-widget refresh) reach into DB streams
      // and platform plugins. Under `flutter test` kIsWeb is false, so those
      // paths would execute with no platform channel behind them and leave
      // pending timers; skip the whole block in the test harness.
      if (isFlutterTest) {
        return;
      }
      // Materialise any due recurring rules on app start. Idempotent — safe to
      // run unconditionally; no-op when there are no due rules.
      // ignore: discarded_futures
      transactions.runRecurringEngine(ref);
      // Initialise + request local-notification permission on native when the
      // payment-push reminder setting is on (no-op on web).
      if (!kIsWeb && ref.read(notif.paymentPushEnabledProvider)) {
        // ignore: discarded_futures
        ref.read(notif.notificationsServiceProvider).requestPermission();
      }
      // Push the initial home-screen widget payload + payment reminders.
      // ignore: discarded_futures
      ref.read(homeSurfaceUpdaterProvider).refresh();
    });
  }

  /// Refreshes the home-screen widget + local payment reminders whenever the
  /// balance (dashboard) or upcoming payments (subscriptions) change.
  void _refreshHomeSurfaces() {
    // Skip under `flutter test` — the refresh reaches native notification /
    // home-widget plugins that have no platform channel in the test harness.
    if (isFlutterTest) {
      return;
    }
    // ignore: discarded_futures
    ref.read(homeSurfaceUpdaterProvider).refresh();
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

    // Keep the home-screen widget + local payment reminders in sync with the
    // live data. Fires on balance/account changes (dashboard) and on
    // subscription add/remove/re-date (subscriptions stream).
    ref.listen<AsyncValue<dashboard.DashboardSnapshot>>(
      dashboard.dashboardControllerProvider,
      (_, __) => _refreshHomeSurfaces(),
    );
    ref.listen<AsyncValue<List<subs.DetectedSubscription>>>(
      subs.detectedSubscriptionsStreamProvider,
      (_, __) => _refreshHomeSurfaces(),
    );

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
