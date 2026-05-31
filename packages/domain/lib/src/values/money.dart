import 'package:decimal/decimal.dart';
import 'package:equatable/equatable.dart';

import 'currency.dart';

/// Immutable monetary value stored as a [BigInt] amount in minor units
/// (tiyn / cents / kopeks) plus an ISO-4217 [Currency].
///
/// Arithmetic operators (+, -, *) require matching currencies — mixing
/// throws [ArgumentError]. Multiplication is scalar (by int or [Decimal]).
class Money extends Equatable implements Comparable<Money> {
  /// Constructs a [Money] from an exact minor-unit amount.
  const Money(this.minor, this.currency);

  /// Zero value in [currency].
  Money.zero(this.currency) : minor = BigInt.zero;

  /// Constructs from a major-unit decimal (e.g. `Money.fromMajor(Decimal.parse('12.50'), Currency.usd)`).
  factory Money.fromMajor(Decimal major, Currency currency) {
    final scale = BigInt.from(10).pow(currency.minorUnit);
    final scaled = (major * Decimal.fromBigInt(scale));
    final rounded = scaled.round(scale: 0);
    return Money(rounded.toBigInt(), currency);
  }

  /// Convenience for whole-major units (e.g. `Money.major(100, Currency.kzt)`).
  factory Money.major(int majorUnits, Currency currency) {
    final scale = BigInt.from(10).pow(currency.minorUnit);
    return Money(BigInt.from(majorUnits) * scale, currency);
  }

  /// Raw amount in minor units. Always exact, never rounded by FP.
  final BigInt minor;

  /// Currency of this value.
  final Currency currency;

  /// True when the value is exactly zero.
  bool get isZero => minor == BigInt.zero;

  /// True when the value is strictly negative.
  bool get isNegative => minor < BigInt.zero;

  /// Amount expressed in major units as a [Decimal].
  Decimal get major {
    final scale = BigInt.from(10).pow(currency.minorUnit);
    return (Decimal.fromBigInt(minor) / Decimal.fromBigInt(scale))
        .toDecimal(scaleOnInfinitePrecision: 10);
  }

  /// Adds [other]; both must share [currency].
  Money operator +(Money other) {
    _assertSameCurrency(other);
    return Money(minor + other.minor, currency);
  }

  /// Subtracts [other]; both must share [currency].
  Money operator -(Money other) {
    _assertSameCurrency(other);
    return Money(minor - other.minor, currency);
  }

  /// Multiplies by an integer or [Decimal] factor. Result is rounded to the
  /// nearest minor unit (banker-safe via [Decimal.round]).
  Money operator *(Object factor) {
    if (factor is int) {
      return Money(minor * BigInt.from(factor), currency);
    }
    if (factor is BigInt) {
      return Money(minor * factor, currency);
    }
    if (factor is Decimal) {
      final product = Decimal.fromBigInt(minor) * factor;
      return Money(product.round(scale: 0).toBigInt(), currency);
    }
    throw ArgumentError.value(factor, 'factor', 'Must be int, BigInt, or Decimal');
  }

  /// Negation.
  Money operator -() => Money(-minor, currency);

  /// Returns the absolute value.
  Money abs() => Money(minor.abs(), currency);

  bool operator <(Money other) {
    _assertSameCurrency(other);
    return minor < other.minor;
  }

  bool operator <=(Money other) {
    _assertSameCurrency(other);
    return minor <= other.minor;
  }

  bool operator >(Money other) {
    _assertSameCurrency(other);
    return minor > other.minor;
  }

  bool operator >=(Money other) {
    _assertSameCurrency(other);
    return minor >= other.minor;
  }

  @override
  int compareTo(Money other) {
    _assertSameCurrency(other);
    return minor.compareTo(other.minor);
  }

  void _assertSameCurrency(Money other) {
    if (other.currency != currency) {
      throw ArgumentError(
        'Currency mismatch: $currency vs ${other.currency}',
      );
    }
  }

  /// Serializes to a JSON map with raw minor-unit string + ISO code.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'minor': minor.toString(),
        'currency': currency.code,
      };

  /// Reconstructs from [toJson] output.
  factory Money.fromJson(Map<String, dynamic> json) => Money(
        BigInt.parse(json['minor'] as String),
        Currency.parse(json['currency'] as String),
      );

  @override
  String toString() => '${major.toString()} ${currency.code}';

  @override
  List<Object?> get props => <Object?>[minor, currency];
}
