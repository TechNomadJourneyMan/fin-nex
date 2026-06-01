import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:meta/meta.dart';

/// Direction of a parsed bank notification relative to the user's account.
///
/// Kept as plain strings (`'income'` / `'expense'`) rather than a domain enum
/// so this package stays dependency-free and trivially serializable. The app
/// layer maps these onto `TransactionType` when persisting.
class ParsedTxnType {
  const ParsedTxnType._();

  /// Money coming into the account (deposits, transfers received, refunds).
  static const String income = 'income';

  /// Money leaving the account (purchases, withdrawals, payments).
  static const String expense = 'expense';
}

/// The structured result of parsing a single bank SMS or push notification.
///
/// This is a transport DTO: it is intentionally decoupled from the `pf_domain`
/// `Transaction`/`Money`/`Ulid` types. The consuming app converts it into a
/// domain `Transaction` (e.g. via the IdMapper bridge and `Money(minor, ...)`).
@immutable
class ParsedTransaction {
  /// Creates a parsed transaction. Prefer [ParsedTransaction.create] which also
  /// derives [externalRef] from [raw].
  const ParsedTransaction({
    required this.amountMinor,
    required this.currency,
    required this.type,
    required this.raw,
    required this.occurredAt,
    required this.externalRef,
    this.merchant,
  });

  /// Builds a [ParsedTransaction], deriving [externalRef] as the SHA-1 of
  /// [raw] so the same notification de-duplicates deterministically across
  /// devices and re-parses.
  factory ParsedTransaction.create({
    required int amountMinor,
    required String type,
    required String raw,
    required DateTime occurredAt,
    String currency = 'KZT',
    String? merchant,
  }) {
    return ParsedTransaction(
      amountMinor: amountMinor,
      currency: currency,
      type: type,
      merchant: merchant,
      raw: raw,
      occurredAt: occurredAt,
      externalRef: sha1OfRaw(raw),
    );
  }

  /// Amount in minor units (tiyn for KZT — 1 ₸ == 100 tiyn). Always positive;
  /// direction is carried by [type].
  final int amountMinor;

  /// ISO-4217 currency code. Always `'KZT'` for the bundled KZ parsers.
  final String currency;

  /// `'income'` or `'expense'` — see [ParsedTxnType].
  final String type;

  /// Best-effort merchant / counterparty extracted from the message, if any.
  final String? merchant;

  /// The original notification text, unmodified.
  final String raw;

  /// When the transaction occurred. Parsers that cannot recover a timestamp
  /// from the text fall back to the parse time supplied by the registry.
  final DateTime occurredAt;

  /// SHA-1 hex digest of [raw]; used as the external de-dup reference.
  final String externalRef;

  /// Computes the SHA-1 hex digest of a raw notification string.
  static String sha1OfRaw(String raw) =>
      sha1.convert(utf8.encode(raw)).toString();

  /// Serializes to a plain JSON map.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'amount_minor': amountMinor,
        'currency': currency,
        'type': type,
        'merchant': merchant,
        'raw': raw,
        'occurred_at': occurredAt.toUtc().toIso8601String(),
        'external_ref': externalRef,
      };

  @override
  bool operator ==(Object other) =>
      other is ParsedTransaction &&
      other.amountMinor == amountMinor &&
      other.currency == currency &&
      other.type == type &&
      other.merchant == merchant &&
      other.raw == raw &&
      other.occurredAt == occurredAt &&
      other.externalRef == externalRef;

  @override
  int get hashCode => Object.hash(
        amountMinor,
        currency,
        type,
        merchant,
        raw,
        occurredAt,
        externalRef,
      );

  @override
  String toString() =>
      'ParsedTransaction(amountMinor: $amountMinor, currency: $currency, '
      'type: $type, merchant: $merchant, externalRef: $externalRef)';
}
