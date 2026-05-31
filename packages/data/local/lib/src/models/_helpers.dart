/// Shared row-mapping helpers for converting between SQLite primitives and
/// Dart types.

/// Convert a SQLite integer (0/1) to a [bool].
bool boolFromInt(Object? v) => (v as int? ?? 0) != 0;

/// Convert a [bool] to a SQLite integer (0/1).
int boolToInt(bool v) => v ? 1 : 0;

/// Parse a stored ISO8601 UTC string into a UTC [DateTime].
DateTime? parseDate(Object? v) {
  if (v == null) return null;
  final s = v as String;
  return DateTime.parse(s).toUtc();
}

/// Format a [DateTime] as an ISO8601 UTC string compatible with the schema.
String formatDate(DateTime d) => d.toUtc().toIso8601String();

/// Format an optional [DateTime] as an ISO8601 UTC string, or `null`.
String? formatDateOrNull(DateTime? d) => d == null ? null : formatDate(d);

/// Current UTC time as the canonical ISO8601 string.
String nowIso() => formatDate(DateTime.now());
