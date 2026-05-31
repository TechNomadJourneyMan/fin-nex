/// Pocket Flow client-side end-to-end encryption primitives.
///
/// Provides PBKDF2 key derivation, an AES-GCM-256 envelope cipher, and a
/// base64 wire codec. Pure Dart — usable on web, native, and the Dart VM.
///
/// The server only ever sees ciphertext; keys never leave the device.
library fnx_e2e_crypto;

export 'src/encrypted_blob.dart';
export 'src/envelope_cipher.dart';
export 'src/key_derivation.dart';
