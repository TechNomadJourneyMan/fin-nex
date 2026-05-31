/// Public API for FinNex localization.
library fnx_core_l10n;

import 'package:flutter/widgets.dart';

export 'generated/app_localizations.dart';

/// Supported app locales. Order is significant: it controls the
/// fallback preference in `MaterialApp.supportedLocales`.
abstract final class FnxLocales {
  /// English (default).
  static const Locale en = Locale('en');

  /// Russian.
  static const Locale ru = Locale('ru');

  /// Kazakh.
  static const Locale kk = Locale('kk');

  /// All supported locales, in fallback order.
  static const List<Locale> all = <Locale>[en, ru, kk];
}
