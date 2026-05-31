// FinNex app entrypoint.
//
// Failsafe bootstrap:
//   1. Install a global ErrorWidget.builder so render errors show a readable
//      card instead of a red screen.
//   2. Open the data module via [AppDataModule.openOrFallback] — never throws.
//   3. If the module fell back to in-memory storage, surface that as a banner
//      via the [bootstrapWarningProvider] so the UI can warn the user.
//
// Any unhandled exception above runApp() is caught by [bootstrap]'s zone
// guard and rendered as a static error screen instead of leaving the splash
// hanging.

import 'package:flutter/foundation.dart' show debugPrint, kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'app_data.dart';
import 'bootstrap.dart';
import 'providers.dart';

/// Exposes a one-line warning when the app booted in degraded mode
/// (in-memory fallback because sqflite failed). The dashboard reads it to
/// show a non-blocking banner. `null` means everything is healthy.
final Provider<String?> bootstrapWarningProvider =
    Provider<String?>((Ref ref) => null);

/// Application entrypoint.
void main() {
  // 1. Friendly render-error widget for the entire app lifetime.
  ErrorWidget.builder = _friendlyErrorWidget;

  bootstrap(() async {
    AppDataModule? module;
    Object? bootError;
    StackTrace? bootStack;

    // Load shared_preferences up-front so the auth session store and device-id
    // provider can hydrate synchronously inside the ProviderScope. Best-effort:
    // a failure here must not block boot, so we fall back to a null instance
    // and skip the auth overrides below.
    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (e, st) {
      debugPrint('SharedPreferences unavailable: $e\n$st');
    }

    try {
      module = await AppDataModule.openOrFallback(demoUserId: kDemoUserId);
    } catch (e, st) {
      // openOrFallback() is designed to never throw, but belt-and-braces:
      // if it does, fall through to the static error screen below.
      bootError = e;
      bootStack = st;
      debugPrint('Bootstrap fatal: $e\n$st');
    }

    if (module == null) {
      runApp(_BootErrorApp(error: bootError, stack: bootStack));
      return;
    }

    // Demo seeding intentionally removed per user request. The app boots
    // with a single seeded "Кошелёк" account (from AppDataModule) and an
    // empty transactions list — pure persisted user data only.

    runApp(
      ProviderScope(
        overrides: <Override>[
          ...buildAppProviderOverrides(module),
          // Auth wiring requires shared_preferences; only install the override
          // (and the backend-backed auth repository it unlocks) when prefs
          // loaded successfully. Otherwise the auth feature keeps its stub.
          if (prefs != null) ...<Override>[
            sharedPreferencesProvider.overrideWithValue(prefs),
            authRepositoryOverride,
          ],
          if (module.fallbackReason != null)
            bootstrapWarningProvider.overrideWithValue(
              'Локальная база недоступна — данные хранятся только в памяти. '
              '(${module.fallbackReason})',
            ),
        ],
        child: const FinNexApp(),
      ),
    );
  });
}

Widget _friendlyErrorWidget(FlutterErrorDetails details) {
  // Released builds get a minimal placeholder; debug builds keep details.
  if (kReleaseMode) {
    return const Material(
      color: Color(0xFFF8F9FA),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Не удалось отрисовать этот экран.\nПерезагрузите приложение.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
        ),
      ),
    );
  }
  return Material(
    color: const Color(0xFFFFF1F0),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              '⚠️ Render error',
              style: TextStyle(
                color: Color(0xFFB10000),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              details.exceptionAsString(),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Color(0xFF300000),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _BootErrorApp extends StatelessWidget {
  const _BootErrorApp({this.error, this.stack});

  final Object? error;
  final StackTrace? stack;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFFFF8F4),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 24),
                const Text(
                  'Pocket Flow не смог запуститься',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Произошла критическая ошибка при инициализации. '
                  'Попробуйте перезагрузить страницу. Если ошибка повторяется, '
                  'очистите кеш браузера (или переустановите приложение).',
                  style: TextStyle(fontSize: 14, color: Color(0xFF4A4A4A)),
                ),
                const SizedBox(height: 24),
                if (error != null) ...<Widget>[
                  const Text(
                    'Детали:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F1F1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$error\n\n${stack ?? ''}',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
