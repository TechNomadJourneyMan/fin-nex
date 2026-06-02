// Web-safe detection of the `flutter test` environment.
//
// `flutter test` runs on the Dart VM with `kIsWeb == false`, so any startup
// side-effect that is gated only on `!kIsWeb` (e.g. native notification or
// home-widget plugin calls) would execute under test with no platform channel
// behind it and leave pending timers. This flag lets startup code skip those
// native side-effects while running under the test harness.
//
// The implementation is selected by conditional import: the web build resolves
// the stub (always `false`); native/VM builds resolve the `dart:io` variant
// that inspects `Platform.environment['FLUTTER_TEST']`.
import 'test_env_stub.dart' if (dart.library.io) 'test_env_io.dart';

/// `true` when running under `flutter test`; `false` in production / on web.
bool get isFlutterTest => isFlutterTestImpl();
