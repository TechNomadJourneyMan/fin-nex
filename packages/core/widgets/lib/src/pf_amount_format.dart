// Shared amount formatting helpers for PocketFlow widgets.

import 'package:intl/intl.dart';

/// Default currency symbol shown after amounts.
const String kPfDefaultCurrencySymbol = '₸';

/// Format an integer amount in minor units to a localized display string.
///
/// Example: `formatAmount(102450, locale: 'ru')` -> `"1 024,50"`.
String formatPfAmount(
  int minorUnits, {
  String locale = 'ru',
  int fractionDigits = 0,
  String? currencySymbol = kPfDefaultCurrencySymbol,
}) {
  final divisor = fractionDigits == 0 ? 1 : 100;
  final number = minorUnits / divisor;
  final formatter = NumberFormat.decimalPattern(locale)
    ..minimumFractionDigits = fractionDigits
    ..maximumFractionDigits = fractionDigits;
  final formatted = formatter.format(number);
  if (currencySymbol == null || currencySymbol.isEmpty) {
    return formatted;
  }
  return '$formatted $currencySymbol';
}

/// Format an amount with explicit sign prefix.
///
/// Income is shown without prefix (callers use color/icon); expense uses the
/// Unicode minus sign U+2212 instead of an ASCII hyphen.
String formatPfSignedAmount(
  int signedMinorUnits, {
  String locale = 'ru',
  int fractionDigits = 0,
  String? currencySymbol = kPfDefaultCurrencySymbol,
}) {
  final magnitude = signedMinorUnits.abs();
  final body = formatPfAmount(
    magnitude,
    locale: locale,
    fractionDigits: fractionDigits,
    currencySymbol: currencySymbol,
  );
  if (signedMinorUnits < 0) {
    return '−$body';
  }
  return body;
}
