import 'dart:convert';

import 'package:cryptography/cryptography.dart';

/// Number of PBKDF2 iterations used to stretch a user passphrase into a
/// master key. Chosen as a balance between mobile-CPU cost and brute-force
/// resistance. Bump (never lower) this if the threat model tightens; the
/// value is part of the derivation and must travel with any stored key
/// material.
const int kPbkdf2Iterations = 200000;

/// Length, in bytes, of the derived master key (256-bit, matching AES-256).
const int kMasterKeyLengthBytes = 32;

/// Crockford base32 alphabet (no I, L, O, U to avoid ambiguity).
const String _crockfordAlphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';

/// Derives a 32-byte (256-bit) master key from a [passphrase] and [salt] using
/// PBKDF2-HMAC-SHA256 with [iterations] (default [kPbkdf2Iterations]).
///
/// The [salt] should be a per-user random value of at least 16 bytes, stored
/// alongside the account so the same key can be re-derived on any device.
///
/// Pure Dart — works on web, native, and the Dart VM (tests).
Future<List<int>> deriveMasterKey({
  required String passphrase,
  required List<int> salt,
  int iterations = kPbkdf2Iterations,
}) async {
  final pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: iterations,
    bits: kMasterKeyLengthBytes * 8,
  );
  final secretKey = await pbkdf2.deriveKey(
    secretKey: SecretKey(utf8.encode(passphrase)),
    nonce: salt,
  );
  return secretKey.extractBytes();
}

/// Computes a short, human-comparable fingerprint of a [masterKey].
///
/// The fingerprint is the first 8 bytes of `SHA-256(masterKey)`, encoded with
/// Crockford base32 (no padding). It is deterministic and stable for a given
/// key, letting two devices visually confirm they derived the same key without
/// exposing the key itself.
Future<String> fingerprint(List<int> masterKey) async {
  final digest = await Sha256().hash(masterKey);
  final first8 = digest.bytes.sublist(0, 8);
  return _crockfordBase32(first8);
}

/// Encodes [bytes] using Crockford base32 (5 bits per output char, no padding).
String _crockfordBase32(List<int> bytes) {
  final buffer = StringBuffer();
  var bits = 0;
  var value = 0;
  for (final b in bytes) {
    value = (value << 8) | (b & 0xff);
    bits += 8;
    while (bits >= 5) {
      bits -= 5;
      buffer.write(_crockfordAlphabet[(value >> bits) & 0x1f]);
    }
  }
  if (bits > 0) {
    buffer.write(_crockfordAlphabet[(value << (5 - bits)) & 0x1f]);
  }
  return buffer.toString();
}
