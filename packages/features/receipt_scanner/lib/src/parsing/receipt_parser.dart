import 'package:pf_domain/pf_domain.dart';

import 'parsed_receipt.dart';

/// Pure-Dart heuristic parser for Kazakhstan retail receipts.
///
/// The parser is intentionally tolerant: OCR output is noisy, so every
/// heuristic degrades gracefully (missing total -> 0, missing date -> [now]).
/// It never throws on malformed input.
///
/// Heuristics:
/// * Grand total = amount on the line tagged `ИТОГО` / `ИТОГ` / `TOTAL`
///   (the last such line wins, since subtotals often precede the final total).
/// * Date = first `dd.MM.yyyy` or `yyyy-MM-dd` match scanned top-to-bottom.
/// * Merchant = first mostly-alphabetic line near the top that is not a
///   keyword, address, or amount line.
/// * Tax lines (`НДС`, `НДС 12%`, `VAT`, `КАССА`, `ФИСКАЛЬНЫЙ`) are excluded
///   from line items.
class ReceiptParser {
  /// Creates a stateless parser.
  const ReceiptParser();

  /// Keywords that mark the grand-total line.
  static const List<String> _totalKeywords = <String>[
    'ИТОГО',
    'ИТОГ',
    'TOTAL',
    'К ОПЛАТЕ',
    'ВСЕГО',
  ];

  /// Keywords whose lines are never treated as products.
  static const List<String> _noiseKeywords = <String>[
    'НДС',
    'VAT',
    'КАССА',
    'КАССИР',
    'ЧЕК',
    'ФИСКАЛЬНЫЙ',
    'ФП',
    'ФН',
    'ИИН',
    'БИН',
    'СДАЧА',
    'НАЛИЧНЫЕ',
    'КАРТА',
    'ОПЛАТА',
    'СКИДКА',
    'ПОДЫТОГ',
    'СУБТОТАЛ',
    'SUBTOTAL',
    'CHANGE',
    'CASH',
    'CARD',
    'TAX',
  ];

  /// Number of leading non-empty lines considered "near the top" for merchant
  /// and date detection.
  static const int _topWindow = 6;

  // dd.MM.yyyy or dd/MM/yyyy or dd-MM-yyyy
  static final RegExp _ddmmyyyy =
      RegExp(r'\b(\d{2})[.\-/](\d{2})[.\-/](\d{4})\b');

  // yyyy-MM-dd or yyyy.MM.dd or yyyy/MM/dd
  static final RegExp _yyyymmdd =
      RegExp(r'\b(\d{4})[.\-/](\d{2})[.\-/](\d{2})\b');

  // Optional time HH:mm(:ss) appearing anywhere on a line.
  static final RegExp _time = RegExp(r'\b(\d{2}):(\d{2})(?::(\d{2}))?\b');

  // A money amount: 1234,56 / 1 234.56 / 1234 — captures integer + optional
  // fractional part. Thousands separators (space / nbsp) are tolerated.
  static final RegExp _amount = RegExp(
    r'(\d{1,3}(?:[  ]\d{3})*|\d+)(?:[.,](\d{1,2}))?',
  );

  // A line that is "just an amount" (qty/price detail rows on their own line).
  static final RegExp _amountOnlyLine = RegExp(
    r'^[^\d]*\d[\d  .,]*$',
  );

  // Street/city address header (Russian abbreviations), e.g.
  // "г. Алматы, ул. Розыбакиева 247", "пр. Назарбаева".
  static final RegExp _addressLine = RegExp(
    r'(?:^|[\s,])(?:г\.|ул\.|пр\.|просп\.|мкр\.|д\.|кв\.|обл\.)',
    caseSensitive: false,
  );

  // Quantity x unit-price form, e.g. "2 x 450,00" / "2 шт x 450" / "3*120".
  static final RegExp _qtyTimesPrice = RegExp(
    r'(\d+)\s*(?:шт\.?|pcs\.?)?\s*[xх*×]\s*'
    r'(\d{1,3}(?:[  ]\d{3})*|\d+)(?:[.,](\d{1,2}))?',
    caseSensitive: false,
  );

  /// Parses raw OCR [text] into a [ParsedReceipt].
  ///
  /// [now] is injectable for deterministic tests; defaults to the wall clock.
  /// [currency] defaults to KZT (Kazakhstan-first launch).
  ParsedReceipt parse(
    String text, {
    DateTime? now,
    Currency currency = Currency.kzt,
  }) {
    final DateTime nowResolved = now ?? DateTime.now();
    final List<String> lines = _normalizeLines(text);

    final int totalMinor = _findTotalMinor(lines, currency);
    final DateTime occurredAt = _findDate(lines, fallback: nowResolved);
    final String? merchant = _findMerchant(lines);
    final List<ReceiptLineItem> items =
        _findLineItems(lines, currency, totalMinor);

    return ParsedReceipt(
      totalMinor: totalMinor,
      currency: currency,
      merchant: merchant,
      occurredAt: occurredAt,
      lineItems: items,
      rawText: text,
    );
  }

  List<String> _normalizeLines(String text) {
    return text
        .split(RegExp(r'\r?\n'))
        .map((String l) => l.trim())
        .where((String l) => l.isNotEmpty)
        .toList();
  }

  /// Whole-word keyword match.
  ///
  /// A naive `contains` would mis-fire on embedded substrings — e.g. the tax
  /// keyword `НДС` lives inside the product name `ГОЛЛАНДСКИЙ`. We therefore
  /// require the keyword to be bounded by a non-letter (or string edge) on
  /// both sides. Multi-word keywords (`К ОПЛАТЕ`) are matched literally.
  bool _containsKeyword(String upper, List<String> keywords) {
    for (final String k in keywords) {
      final String escaped = RegExp.escape(k);
      final RegExp re = RegExp(
        '(?<![A-Za-zА-Яа-яЁё])$escaped(?![A-Za-zА-Яа-яЁё])',
      );
      if (re.hasMatch(upper)) {
        return true;
      }
    }
    return false;
  }

  /// Converts a matched amount (integer group + optional fraction group) into
  /// minor units for [currency].
  int _amountToMinor(String intPart, String? fracPart, Currency currency) {
    final String cleanInt = intPart.replaceAll(RegExp(r'[  ]'), '');
    final BigInt major = BigInt.tryParse(cleanInt) ?? BigInt.zero;
    final BigInt scale = BigInt.from(10).pow(currency.minorUnit);

    BigInt minorFrac = BigInt.zero;
    if (fracPart != null && fracPart.isNotEmpty) {
      // Pad/truncate the fraction to the currency's minor-unit width.
      final String padded =
          fracPart.padRight(currency.minorUnit, '0').substring(
                0,
                currency.minorUnit,
              );
      minorFrac = BigInt.tryParse(padded) ?? BigInt.zero;
    }
    return (major * scale + minorFrac).toInt();
  }

  /// Returns the rightmost (last) amount on a line, in minor units, or null.
  int? _lastAmountMinor(String line, Currency currency) {
    final Iterable<RegExpMatch> matches = _amount.allMatches(line);
    RegExpMatch? last;
    for (final RegExpMatch m in matches) {
      // Ignore standalone integers that are clearly not money (e.g. percent in
      // "НДС 12%") — handled by caller filtering; here keep the last numeric.
      last = m;
    }
    if (last == null) {
      return null;
    }
    return _amountToMinor(last.group(1)!, last.group(2), currency);
  }

  int _findTotalMinor(List<String> lines, Currency currency) {
    int total = 0;
    for (final String line in lines) {
      final String upper = line.toUpperCase();
      // "ПОДЫТОГ"/"SUBTOTAL" must not be mistaken for the grand total.
      if (_containsKeyword(upper, const <String>['ПОДЫТОГ', 'SUBTOTAL'])) {
        continue;
      }
      if (_containsKeyword(upper, _totalKeywords)) {
        final int? amount = _lastAmountMinor(line, currency);
        if (amount != null && amount > 0) {
          // Last matching total line wins.
          total = amount;
        }
      }
    }
    return total;
  }

  DateTime _findDate(List<String> lines, {required DateTime fallback}) {
    final int window = lines.length < _topWindow ? lines.length : _topWindow;
    // Search the top window first (dates usually print near the header),
    // then fall back to the whole document.
    for (final String line in lines.take(window)) {
      final DateTime? d = _parseDateFromLine(line);
      if (d != null) {
        return d;
      }
    }
    for (final String line in lines) {
      final DateTime? d = _parseDateFromLine(line);
      if (d != null) {
        return d;
      }
    }
    return fallback;
  }

  DateTime? _parseDateFromLine(String line) {
    int hour = 0;
    int minute = 0;
    final RegExpMatch? t = _time.firstMatch(line);
    if (t != null) {
      hour = int.tryParse(t.group(1)!) ?? 0;
      minute = int.tryParse(t.group(2)!) ?? 0;
      if (hour > 23 || minute > 59) {
        hour = 0;
        minute = 0;
      }
    }

    final RegExpMatch? iso = _yyyymmdd.firstMatch(line);
    if (iso != null) {
      final int y = int.parse(iso.group(1)!);
      final int mo = int.parse(iso.group(2)!);
      final int d = int.parse(iso.group(3)!);
      final DateTime? dt = _safeDate(y, mo, d, hour, minute);
      if (dt != null) {
        return dt;
      }
    }

    final RegExpMatch? dmy = _ddmmyyyy.firstMatch(line);
    if (dmy != null) {
      final int d = int.parse(dmy.group(1)!);
      final int mo = int.parse(dmy.group(2)!);
      final int y = int.parse(dmy.group(3)!);
      final DateTime? dt = _safeDate(y, mo, d, hour, minute);
      if (dt != null) {
        return dt;
      }
    }
    return null;
  }

  DateTime? _safeDate(int y, int mo, int d, int h, int min) {
    if (mo < 1 || mo > 12 || d < 1 || d > 31) {
      return null;
    }
    final DateTime dt = DateTime(y, mo, d, h, min);
    // Reject overflow normalization (e.g. month 13 -> next year).
    if (dt.year != y || dt.month != mo || dt.day != d) {
      return null;
    }
    return dt;
  }

  String? _findMerchant(List<String> lines) {
    final int window = lines.length < _topWindow ? lines.length : _topWindow;
    for (final String line in lines.take(window)) {
      final String upper = line.toUpperCase();
      if (_containsKeyword(upper, _totalKeywords) ||
          _containsKeyword(upper, _noiseKeywords)) {
        continue;
      }
      // Skip pure amount/date lines.
      if (_amountOnlyLine.hasMatch(line)) {
        continue;
      }
      if (_parseDateFromLine(line) != null) {
        continue;
      }
      // Must contain at least a couple of letters to be a name.
      final int letters =
          line.replaceAll(RegExp(r'[^A-Za-zА-Яа-яЁё]'), '').length;
      if (letters >= 2) {
        return line;
      }
    }
    return null;
  }

  List<ReceiptLineItem> _findLineItems(
    List<String> lines,
    Currency currency,
    int totalMinor,
  ) {
    final List<ReceiptLineItem> items = <ReceiptLineItem>[];
    for (final String line in lines) {
      final String upper = line.toUpperCase();

      // Exclude totals, taxes, payment, and header noise.
      if (_containsKeyword(upper, _totalKeywords) ||
          _containsKeyword(upper, _noiseKeywords)) {
        continue;
      }
      if (_parseDateFromLine(line) != null) {
        continue;
      }
      // Exclude address / location header lines (e.g. "г. Алматы, ул. ...").
      if (_addressLine.hasMatch(line)) {
        continue;
      }

      final int? priceMinor = _lastAmountMinor(line, currency);
      if (priceMinor == null || priceMinor <= 0) {
        // Lines with no amount are not items.
        continue;
      }

      // The name is everything before the first numeric run, stripped of
      // qty markers and trailing separators.
      final String name = _extractItemName(line);
      if (name.isEmpty) {
        continue;
      }
      // A bare amount with no name (e.g. a stray subtotal) is skipped.
      final int nameLetters =
          name.replaceAll(RegExp(r'[^A-Za-zА-Яа-яЁё]'), '').length;
      if (nameLetters < 2) {
        continue;
      }

      int quantity = 1;
      final RegExpMatch? qm = _qtyTimesPrice.firstMatch(line);
      if (qm != null) {
        quantity = int.tryParse(qm.group(1)!) ?? 1;
        if (quantity < 1) {
          quantity = 1;
        }
      }

      items.add(
        ReceiptLineItem(
          name: name,
          quantity: quantity,
          priceMinor: priceMinor,
        ),
      );
    }
    return items;
  }

  /// Extracts the product name from an item line.
  ///
  /// Product names legitimately embed numbers (sizes such as "1л", "500мг",
  /// "200г"), so we cut at the *price column* — the trailing amount(s) and any
  /// `qty x unit-price` run — rather than at the first digit.
  String _extractItemName(String line) {
    int cut = line.length;

    // If a `qty x price` group exists, the name ends where it begins.
    final RegExpMatch? qm = _qtyTimesPrice.firstMatch(line);
    if (qm != null) {
      cut = qm.start;
    } else {
      // Otherwise the name ends at the last (rightmost) standalone amount,
      // which is the price column.
      final List<RegExpMatch> amounts = _amount.allMatches(line).toList();
      if (amounts.isNotEmpty) {
        cut = amounts.last.start;
      }
    }

    String head = line.substring(0, cut);
    head = head
        .replaceAll(RegExp(r'[xх*×]\s*$', caseSensitive: false), '')
        .replaceAll(RegExp(r'[\s.\-:|]+$'), '')
        .trim();
    return head;
  }
}
