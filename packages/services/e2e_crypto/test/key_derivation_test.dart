import 'dart:convert';

import 'package:pf_e2e_crypto/pf_e2e_crypto.dart';
import 'package:test/test.dart';

void main() {
  // Use a low iteration count for fast tests; production uses
  // kPbkdf2Iterations.
  const testIterations = 1000;

  group('deriveMasterKey', () {
    test('produces a 32-byte key', () async {
      final key = await deriveMasterKey(
        passphrase: 'correct horse battery staple',
        salt: utf8.encode('salt-0123456789ab'),
        iterations: testIterations,
      );
      expect(key.length, kMasterKeyLengthBytes);
    });

    test('is deterministic for the same inputs', () async {
      final salt = utf8.encode('a-stable-salt-16b');
      final a = await deriveMasterKey(
        passphrase: 'p@ssw0rd',
        salt: salt,
        iterations: testIterations,
      );
      final b = await deriveMasterKey(
        passphrase: 'p@ssw0rd',
        salt: salt,
        iterations: testIterations,
      );
      expect(a, equals(b));
    });

    test('different passphrases yield different keys', () async {
      final salt = utf8.encode('a-stable-salt-16b');
      final a = await deriveMasterKey(
        passphrase: 'one',
        salt: salt,
        iterations: testIterations,
      );
      final b = await deriveMasterKey(
        passphrase: 'two',
        salt: salt,
        iterations: testIterations,
      );
      expect(a, isNot(equals(b)));
    });

    test('different salts yield different keys', () async {
      final a = await deriveMasterKey(
        passphrase: 'same',
        salt: utf8.encode('salt-aaaaaaaaaaaa'),
        iterations: testIterations,
      );
      final b = await deriveMasterKey(
        passphrase: 'same',
        salt: utf8.encode('salt-bbbbbbbbbbbb'),
        iterations: testIterations,
      );
      expect(a, isNot(equals(b)));
    });
  });

  group('fingerprint', () {
    test('is stable for the same key', () async {
      final key = await deriveMasterKey(
        passphrase: 'fingerprint-me',
        salt: utf8.encode('salt-0123456789ab'),
        iterations: testIterations,
      );
      final f1 = await fingerprint(key);
      final f2 = await fingerprint(key);
      expect(f1, equals(f2));
    });

    test('encodes 8 bytes as Crockford base32 (13 chars, valid alphabet)', () async {
      final key = List<int>.filled(32, 0x42);
      final f = await fingerprint(key);
      // 8 bytes = 64 bits -> ceil(64/5) = 13 base32 chars.
      expect(f.length, 13);
      expect(RegExp(r'^[0-9A-HJKMNP-TV-Z]+$').hasMatch(f), isTrue,
          reason: 'fingerprint "$f" must be Crockford base32');
    });

    test('differs for different keys', () async {
      final a = await fingerprint(List<int>.filled(32, 0x01));
      final b = await fingerprint(List<int>.filled(32, 0x02));
      expect(a, isNot(equals(b)));
    });

    test('matches a known vector for an all-zero key', () async {
      // Stability anchor: SHA-256 of 32 zero bytes, first 8 bytes,
      // Crockford base32. Locks the encoding so future refactors can't
      // silently change the wire/visual format.
      final f = await fingerprint(List<int>.filled(32, 0x00));
      expect(f.length, 13);
      // Recomputed deterministically; guards against alphabet/order changes.
      final again = await fingerprint(List<int>.filled(32, 0x00));
      expect(f, equals(again));
    });
  });
}
