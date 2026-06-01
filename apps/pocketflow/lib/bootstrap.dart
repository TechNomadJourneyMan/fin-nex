// Zone-guarded bootstrap with central error logging.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Run [body] inside a guarded zone so uncaught exceptions and Flutter
/// framework errors are routed through a single sink.
///
/// In release builds this would forward to a crash reporter (e.g. Sentry).
/// For now it just logs via [debugPrint].
void bootstrap(void Function() body) {
  runZonedGuarded<void>(
    () {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        debugPrint('FlutterError: ${details.exceptionAsString()}');
      };

      body();
    },
    (Object error, StackTrace stack) {
      debugPrint('Uncaught zone error: $error\n$stack');
    },
  );
}
