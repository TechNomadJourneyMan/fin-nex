/// Helpers for turning Kazakhstan bank money strings into integer minor units.
///
/// KZT has 2 minor digits (tiyn): `1 ₸ == 100 tiyn`. Banks render amounts with
/// a thousands separator that may be a regular space (`5 000`), a non-breaking
/// space (`5 000`), a narrow no-break space (`5 000`) or an
/// apostrophe (`5'000`), and a decimal separator that is either `.` or `,`
/// (`1 234.56`, `1234,56`). This normalizer copes with all of those.
library;

/// Number of minor units in one major KZT unit.
const int kztMinorPerMajor = 100;

/// Characters banks use as a thousands grouping separator.
const String _groupingChars = '   \'';

/// Parses a Kazakh-formatted money [text] into integer minor units (tiyn),
/// or returns `null` if it does not look like a number.
///
/// Examples:
/// * `'5 000'`        -> `500000`
/// * `'1 234.56'`     -> `123456`
/// * `'1234,5'`       -> `123450`   (trailing zero padding)
/// * `'12 345'`  -> `1234500`
int? parseKztMinor(String text) {
  var s = text.trim();
  if (s.isEmpty) {
    return null;
  }

  // Strip grouping separators (spaces of every flavour + apostrophes).
  for (final ch in _groupingChars.split('')) {
    s = s.replaceAll(ch, '');
  }

  // Normalize the decimal separator to '.'. Only the *last* '.' or ',' is the
  // decimal point; any earlier ones would have been grouping and are gone now.
  final lastDot = s.lastIndexOf('.');
  final lastComma = s.lastIndexOf(',');
  String integerPart;
  String fractionPart;
  if (lastDot == -1 && lastComma == -1) {
    integerPart = s;
    fractionPart = '';
  } else {
    final sepIndex = lastDot > lastComma ? lastDot : lastComma;
    integerPart = s.substring(0, sepIndex);
    fractionPart = s.substring(sepIndex + 1);
  }

  if (integerPart.isEmpty) {
    integerPart = '0';
  }
  if (!_isDigits(integerPart) ||
      (fractionPart.isNotEmpty && !_isDigits(fractionPart))) {
    return null;
  }

  // Pad / truncate the fraction to exactly 2 tiyn digits.
  final tiynStr = fractionPart.padRight(2, '0').substring(0, 2);
  final major = int.tryParse(integerPart);
  final tiyn = int.tryParse(tiynStr);
  if (major == null || tiyn == null) {
    return null;
  }
  return major * kztMinorPerMajor + tiyn;
}

bool _isDigits(String s) {
  if (s.isEmpty) {
    return false;
  }
  for (final code in s.codeUnits) {
    if (code < 0x30 || code > 0x39) {
      return false;
    }
  }
  return true;
}

/// Regex fragment that matches a Kazakh-formatted money number (without the
/// currency token). Grouped so callers can pull the matched amount out.
///
/// Matches `5 000`, `1 234.56`, `12 345`, `1234,5`, `7'000`.
const String kztAmountPattern = r"\d[\d   ']*(?:[.,]\d{1,2})?";
