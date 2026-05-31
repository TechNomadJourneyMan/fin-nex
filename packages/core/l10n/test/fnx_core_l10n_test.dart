import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fnx_core_l10n/fnx_core_l10n.dart';

void main() {
  group('ARB files', () {
    late Map<String, dynamic> en;
    late Map<String, dynamic> ru;
    late Map<String, dynamic> kk;

    setUpAll(() {
      en = _loadArb('lib/l10n/intl_en.arb');
      ru = _loadArb('lib/l10n/intl_ru.arb');
      kk = _loadArb('lib/l10n/intl_kk.arb');
    });

    test('master English ARB has at least 100 keys', () {
      final keys = en.keys.where((k) => !k.startsWith('@')).toList();
      expect(keys.length, greaterThanOrEqualTo(100));
    });

    test('Russian ARB covers every English key', () {
      final missing = _missingKeys(en, ru);
      expect(missing, isEmpty, reason: 'Missing in ru: $missing');
    });

    test('Kazakh ARB covers every English key', () {
      final missing = _missingKeys(en, kk);
      expect(missing, isEmpty, reason: 'Missing in kk: $missing');
    });

    test('every translatable English key has @-metadata', () {
      final keys = en.keys.where((k) => !k.startsWith('@'));
      final missing = keys.where((k) => !en.containsKey('@$k')).toList();
      expect(missing, isEmpty,
          reason: 'Missing @-metadata for: $missing');
    });

    test('master locale tag is en', () {
      expect(en['@@locale'], 'en');
      expect(ru['@@locale'], 'ru');
      expect(kk['@@locale'], 'kk');
    });
  });

  group('AppL10n delegate', () {
    test('FnxLocales.all contains the three supported locales', () {
      expect(
        FnxLocales.all,
        containsAll(<Locale>[
          const Locale('en'),
          const Locale('ru'),
          const Locale('kk'),
        ]),
      );
    });

    test('delegate isSupported matches supportedLocales', () {
      for (final locale in AppL10n.supportedLocales) {
        expect(AppL10n.delegate.isSupported(locale), isTrue);
      }
      expect(
        AppL10n.delegate.isSupported(const Locale('fr')),
        isFalse,
      );
    });

    testWidgets('loads English strings', (tester) async {
      final l10n = await AppL10n.delegate.load(const Locale('en'));
      expect(l10n.appName, 'FinNex');
      expect(l10n.navHome, 'Home');
      expect(l10n.dashGreeting('Aisha'), 'Hi, Aisha');
      expect(l10n.txCount(0), 'No transactions');
      expect(l10n.txCount(1), '1 transaction');
      expect(l10n.txCount(5), '5 transactions');
      expect(l10n.txDaysAgo(0), 'Today');
      expect(l10n.txDaysAgo(1), 'Yesterday');
      expect(l10n.txDaysAgo(3), '3 days ago');
    });

    testWidgets('loads Russian strings with plurals', (tester) async {
      final l10n = await AppL10n.delegate.load(const Locale('ru'));
      expect(l10n.appName, 'FinNex');
      expect(l10n.navHome, 'Главная');
      expect(l10n.dashGreeting('Айша'), 'Привет, Айша');
      expect(l10n.txCount(0), 'Нет операций');
      expect(l10n.txCount(1), '1 операция');
      expect(l10n.txCount(3), '3 операции');
      expect(l10n.txCount(7), '7 операций');
    });

    testWidgets('loads Kazakh strings', (tester) async {
      final l10n = await AppL10n.delegate.load(const Locale('kk'));
      expect(l10n.appName, 'FinNex');
      expect(l10n.navHome, 'Басты');
      expect(l10n.dashBudgetDaysLeft(12), '12 күн қалды');
      expect(l10n.txDaysAgo(0), 'Бүгін');
      expect(l10n.txDaysAgo(1), 'Кеше');
    });
  });
}

Map<String, dynamic> _loadArb(String relativePath) {
  final file = File(relativePath);
  final raw = file.readAsStringSync();
  return jsonDecode(raw) as Map<String, dynamic>;
}

List<String> _missingKeys(
  Map<String, dynamic> master,
  Map<String, dynamic> other,
) {
  final result = <String>[];
  for (final key in master.keys) {
    if (key.startsWith('@')) continue;
    if (!other.containsKey(key)) result.add(key);
  }
  return result;
}
