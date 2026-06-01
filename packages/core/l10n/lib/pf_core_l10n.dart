/// Public API for PocketFlow localization.
library pf_core_l10n;

import 'package:flutter/widgets.dart';

export 'generated/app_localizations.dart';

// Backwards-compatibility alias. The l10n.yaml renames the generated class
// to `AppL10n`, but feature packages (insights, notifications) historically
// imported it under its default name `AppLocalizations`. Keep this typedef
// until those imports are migrated to `AppL10n`.
import 'generated/app_localizations.dart' show AppL10n;

/// Legacy alias for [AppL10n]. Prefer `AppL10n` in new code.
typedef AppLocalizations = AppL10n;

/// Supported app locales. Order is significant: it controls the
/// fallback preference in `MaterialApp.supportedLocales`.
abstract final class PfLocales {
  /// English (default).
  static const Locale en = Locale('en');

  /// Russian.
  static const Locale ru = Locale('ru');

  /// Kazakh.
  static const Locale kk = Locale('kk');

  /// All supported locales, in fallback order.
  static const List<Locale> all = <Locale>[en, ru, kk];
}
