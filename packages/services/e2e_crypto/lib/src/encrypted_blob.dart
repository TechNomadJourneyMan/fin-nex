import 'dart:convert';
import 'dart:typed_data';

import 'envelope_cipher.dart';

/// Codec that serializes an [EncryptedEnvelope] to and from a single base64
/// wire string.
///
/// Wire layout (before base64): `nonce (12 bytes) || ciphertext (N bytes) ||
/// mac (16 bytes)`. The fixed-size header and trailer let the decoder split
/// the blob unambiguously without any length prefixes.
abstract final class EncryptedBlob {
  /// Encodes [envelope] into a single base64 string.
  static String encode(EncryptedEnvelope envelope) {
    if (envelope.nonce.length != kNonceLengthBytes) {
      throw ArgumentError.value(
        envelope.nonce.length,
        'nonce.length',
        'expected $kNonceLengthBytes-byte nonce',
      );
    }
    if (envelope.mac.length != kMacLengthBytes) {
      throw ArgumentError.value(
        envelope.mac.length,
        'mac.length',
        'expected $kMacLengthBytes-byte mac',
      );
    }
    final out = Uint8List(
      envelope.nonce.length + envelope.ciphertext.length + envelope.mac.length,
    );
    var offset = 0;
    out.setRange(offset, offset += envelope.nonce.length, envelope.nonce);
    out.setRange(
      offset,
      offset += envelope.ciphertext.length,
      envelope.ciphertext,
    );
    out.setRange(offset, offset += envelope.mac.length, envelope.mac);
    return base64.encode(out);
  }

  /// Decodes a base64 [wire] string back into an [EncryptedEnvelope].
  ///
  /// Throws [FormatException] when the blob is malformed or too short to hold
  /// the fixed nonce and mac.
  static EncryptedEnvelope decode(String wire) {
    final bytes = base64.decode(wire);
    const minLength = kNonceLengthBytes + kMacLengthBytes;
    if (bytes.length < minLength) {
      throw FormatException(
        'Encrypted blob too short: ${bytes.length} < $minLength bytes',
      );
    }
    final nonce = bytes.sublist(0, kNonceLengthBytes);
    final mac = bytes.sublist(bytes.length - kMacLengthBytes);
    final ciphertext = bytes.sublist(
      kNonceLengthBytes,
      bytes.length - kMacLengthBytes,
    );
    return EncryptedEnvelope(
      nonce: nonce,
      ciphertext: ciphertext,
      mac: mac,
    );
  }
}
