import 'dart:math';

import 'package:equatable/equatable.dart';

/// A 26-character ULID identifier.
///
/// Format: 10 chars of millisecond timestamp + 16 chars of randomness,
/// Crockford base-32 (RFC: `0123456789ABCDEFGHJKMNPQRSTVWXYZ`).
class Ulid extends Equatable {
  /// Wraps an already-formed ULID string. Throws [ArgumentError] for invalid
  /// length or alphabet.
  Ulid(this.value) {
    if (value.length != 26) {
      throw ArgumentError.value(value, 'value', 'ULID must be 26 chars');
    }
    for (final code in value.codeUnits) {
      if (_alphabetSet.indexOf(String.fromCharCode(code)) < 0) {
        throw ArgumentError.value(value, 'value', 'Invalid Crockford base-32');
      }
    }
  }

  /// Generates a new ULID using the current wall-clock and [Random.secure].
  factory Ulid.now({DateTime? at, Random? random}) {
    final ts = (at ?? DateTime.now().toUtc()).millisecondsSinceEpoch;
    final rng = random ?? _secure;
    final buf = StringBuffer();
    _encodeTime(ts, 10, buf);
    _encodeRandom(rng, 16, buf);
    return Ulid._raw(buf.toString());
  }

  Ulid._raw(this.value);

  /// The literal 26-character string.
  final String value;

  /// The millisecond timestamp encoded in the first 10 characters.
  int get timestampMillis {
    var t = 0;
    for (var i = 0; i < 10; i++) {
      t = t * 32 + _alphabetSet.indexOf(value[i]);
    }
    return t;
  }

  /// Decoded creation moment in UTC.
  DateTime get createdAt =>
      DateTime.fromMillisecondsSinceEpoch(timestampMillis, isUtc: true);

  @override
  String toString() => value;

  @override
  List<Object?> get props => <Object?>[value];

  static const String _alphabetSet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';
  static final Random _secure = Random.secure();

  static void _encodeTime(int ts, int length, StringBuffer out) {
    final chars = List<String>.filled(length, '0');
    for (var i = length - 1; i >= 0; i--) {
      chars[i] = _alphabetSet[ts % 32];
      ts ~/= 32;
    }
    for (final c in chars) {
      out.write(c);
    }
  }

  static void _encodeRandom(Random rng, int length, StringBuffer out) {
    for (var i = 0; i < length; i++) {
      out.write(_alphabetSet[rng.nextInt(32)]);
    }
  }
}
