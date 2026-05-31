/// ISO-4217 currency codes supported by FinNex.
///
/// Only the subset relevant to the Kazakhstan-first launch is enumerated.
enum Currency {
  kzt('KZT', 2, '₸'),
  usd('USD', 2, r'$'),
  eur('EUR', 2, '€'),
  rub('RUB', 2, '₽');

  const Currency(this.code, this.minorUnit, this.symbol);

  /// Three-letter ISO-4217 code.
  final String code;

  /// Number of digits after the decimal separator for this currency.
  final int minorUnit;

  /// Conventional UI symbol.
  final String symbol;

  /// Parses a case-insensitive ISO code into a [Currency], or throws
  /// [ArgumentError] if unknown.
  static Currency parse(String code) {
    final normalized = code.toUpperCase();
    for (final c in Currency.values) {
      if (c.code == normalized) {
        return c;
      }
    }
    throw ArgumentError.value(code, 'code', 'Unknown currency');
  }

  /// Like [parse] but returns `null` when the code is unknown.
  static Currency? tryParse(String? code) {
    if (code == null) {
      return null;
    }
    try {
      return parse(code);
    } on ArgumentError {
      return null;
    }
  }
}
