import 'dart:math';
import 'dart:typed_data';

import 'package:fnx_e2e_crypto/fnx_e2e_crypto.dart';
import 'package:test/test.dart';

void main() {
  group('AES-GCM-256 envelope roundtrip', () {
    test('1000 random payloads roundtrip through the envelope cipher', () async {
      final rng = Random(0xF12E);
      final key = _randomBytes(rng, 32);

      for (var i = 0; i < 1000; i++) {
        final length = rng.nextInt(512); // 0..511 byte payloads
        final plaintext = _randomBytes(rng, length);

        final envelope = await encrypt(key, plaintext);
        expect(envelope.nonce.length, kNonceLengthBytes);
        expect(envelope.mac.length, kMacLengthBytes);
        expect(envelope.ciphertext.length, plaintext.length);

        final decrypted = await decrypt(key, envelope);
        expect(decrypted, equals(plaintext), reason: 'payload #$i mismatch');
      }
    });

    test('roundtrip survives base64 wire encode/decode', () async {
      final rng = Random(7);
      final key = _randomBytes(rng, 32);
      final plaintext = _randomBytes(rng, 256);

      final envelope = await encrypt(key, plaintext);
      final wire = EncryptedBlob.encode(envelope);
      final restored = EncryptedBlob.decode(wire);

      expect(restored, equals(envelope));
      expect(await decrypt(key, restored), equals(plaintext));
    });

    test('two encryptions of the same plaintext use different nonces', () async {
      final rng = Random(3);
      final key = _randomBytes(rng, 32);
      final plaintext = _randomBytes(rng, 64);

      final a = await encrypt(key, plaintext);
      final b = await encrypt(key, plaintext);

      expect(a.nonce, isNot(equals(b.nonce)));
      expect(a.ciphertext, isNot(equals(b.ciphertext)));
    });
  });

  group('authentication failures', () {
    test('decrypt with the wrong key throws EnvelopeAuthException', () async {
      final rng = Random(11);
      final goodKey = _randomBytes(rng, 32);
      final wrongKey = _randomBytes(rng, 32);
      final plaintext = _randomBytes(rng, 128);

      final envelope = await encrypt(goodKey, plaintext);

      expect(
        () => decrypt(wrongKey, envelope),
        throwsA(isA<EnvelopeAuthException>()),
      );
    });

    test('tampered ciphertext throws EnvelopeAuthException', () async {
      final rng = Random(13);
      final key = _randomBytes(rng, 32);
      final envelope = await encrypt(key, _randomBytes(rng, 64));

      final tampered = Uint8List.fromList(envelope.ciphertext);
      tampered[0] ^= 0xff;
      final bad = EncryptedEnvelope(
        nonce: envelope.nonce,
        ciphertext: tampered,
        mac: envelope.mac,
      );

      expect(
        () => decrypt(key, bad),
        throwsA(isA<EnvelopeAuthException>()),
      );
    });

    test('non-32-byte key is rejected', () async {
      expect(
        () => encrypt(List<int>.filled(16, 0), <int>[1, 2, 3]),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('EncryptedBlob codec', () {
    test('decode rejects a too-short blob', () {
      expect(
        () => EncryptedBlob.decode('AAAA'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}

Uint8List _randomBytes(Random rng, int length) {
  final out = Uint8List(length);
  for (var i = 0; i < length; i++) {
    out[i] = rng.nextInt(256);
  }
  return out;
}
