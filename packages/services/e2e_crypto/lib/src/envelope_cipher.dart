import 'package:cryptography/cryptography.dart';
import 'package:meta/meta.dart';

/// Length, in bytes, of the AES-GCM nonce (96-bit, the GCM-recommended size).
const int kNonceLengthBytes = 12;

/// Length, in bytes, of the AES-GCM authentication tag (128-bit).
const int kMacLengthBytes = 16;

/// A self-contained AES-GCM-256 encrypted envelope.
///
/// Holds everything needed to decrypt a single payload given the master key:
/// the random [nonce], the [ciphertext], and the GCM authentication [mac].
@immutable
class EncryptedEnvelope {
  /// Default const ctor.
  const EncryptedEnvelope({
    required this.nonce,
    required this.ciphertext,
    required this.mac,
  });

  /// 96-bit random nonce, unique per encryption under a given key.
  final List<int> nonce;

  /// AES-GCM ciphertext (same length as the plaintext).
  final List<int> ciphertext;

  /// 128-bit GCM authentication tag.
  final List<int> mac;

  @override
  bool operator ==(Object other) =>
      other is EncryptedEnvelope &&
      _listEquals(nonce, other.nonce) &&
      _listEquals(ciphertext, other.ciphertext) &&
      _listEquals(mac, other.mac);

  @override
  int get hashCode => Object.hash(
        Object.hashAll(nonce),
        Object.hashAll(ciphertext),
        Object.hashAll(mac),
      );
}

/// Thrown when an [EncryptedEnvelope] fails authentication during [decrypt],
/// e.g. the wrong key was supplied or the ciphertext/mac was tampered with.
class EnvelopeAuthException implements Exception {
  /// Default const ctor.
  const EnvelopeAuthException(
      [this.message = 'Envelope authentication failed']);

  /// Human-readable reason.
  final String message;

  @override
  String toString() => 'EnvelopeAuthException: $message';
}

final AesGcm _aesGcm = AesGcm.with256bits();

/// Encrypts [plaintext] under [masterKey] (a 32-byte key) using AES-GCM-256,
/// returning a fresh [EncryptedEnvelope] with a random nonce.
Future<EncryptedEnvelope> encrypt(
  List<int> masterKey,
  List<int> plaintext,
) async {
  _assertKeyLength(masterKey);
  final secretBox = await _aesGcm.encrypt(
    plaintext,
    secretKey: SecretKey(masterKey),
  );
  return EncryptedEnvelope(
    nonce: secretBox.nonce,
    ciphertext: secretBox.cipherText,
    mac: secretBox.mac.bytes,
  );
}

/// Decrypts an [envelope] under [masterKey], returning the original plaintext.
///
/// Throws [EnvelopeAuthException] when authentication fails (wrong key or
/// tampered data).
Future<List<int>> decrypt(
  List<int> masterKey,
  EncryptedEnvelope envelope,
) async {
  _assertKeyLength(masterKey);
  final secretBox = SecretBox(
    envelope.ciphertext,
    nonce: envelope.nonce,
    mac: Mac(envelope.mac),
  );
  try {
    return await _aesGcm.decrypt(secretBox, secretKey: SecretKey(masterKey));
  } on SecretBoxAuthenticationError catch (e) {
    throw EnvelopeAuthException(e.toString());
  }
}

void _assertKeyLength(List<int> key) {
  if (key.length != 32) {
    throw ArgumentError.value(
      key.length,
      'masterKey.length',
      'AES-GCM-256 requires a 32-byte key',
    );
  }
}

bool _listEquals(List<int> a, List<int> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
