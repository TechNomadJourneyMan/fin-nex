import 'dart:convert';

import 'package:meta/meta.dart';

import '_helpers.dart';

/// Persisted shape of per-user app settings.
@immutable
class SettingRow {
  /// Creates an immutable settings row.
  const SettingRow({
    required this.userId,
    required this.updatedAt,
    this.theme = 'system',
    this.weekStartsOn = 1,
    this.numberFormat = 'ru-KZ',
    this.decimalSeparator = ',',
    this.thousandSeparator = ' ',
    this.hideBalancesUntilAuth = false,
    this.biometricLock = false,
    this.defaultAccountId,
    this.defaultExpenseCategoryId,
    this.defaultIncomeCategoryId,
    this.quickAddAmounts = const <int>[500, 1000, 2000, 5000],
    this.budgetCarryoverDefault = false,
    this.dailyReminderTime,
    this.showAccountTotalOnHome = true,
    this.language = 'ru',
    this.version = 1,
  });

  /// Builds a [SettingRow] from a sqflite result map.
  factory SettingRow.fromMap(Map<String, Object?> m) => SettingRow(
        userId: m['user_id']! as String,
        theme: m['theme'] as String? ?? 'system',
        weekStartsOn: m['week_starts_on']! as int,
        numberFormat: m['number_format'] as String? ?? 'ru-KZ',
        decimalSeparator: m['decimal_separator'] as String? ?? ',',
        thousandSeparator: m['thousand_separator'] as String? ?? ' ',
        hideBalancesUntilAuth: boolFromInt(m['hide_balances_until_auth']),
        biometricLock: boolFromInt(m['biometric_lock']),
        defaultAccountId: m['default_account_id'] as String?,
        defaultExpenseCategoryId: m['default_expense_category_id'] as String?,
        defaultIncomeCategoryId: m['default_income_category_id'] as String?,
        quickAddAmounts: _parseInts(m['quick_add_amounts'] as String?),
        budgetCarryoverDefault: boolFromInt(m['budget_carryover_default']),
        dailyReminderTime: m['daily_reminder_time'] as String?,
        showAccountTotalOnHome: boolFromInt(m['show_account_total_on_home']),
        language: m['language'] as String? ?? 'ru',
        updatedAt: parseDate(m['updated_at'])!,
        version: m['version']! as int,
      );

  static List<int> _parseInts(String? raw) {
    if (raw == null || raw.isEmpty) return const <int>[];
    final decoded = jsonDecode(raw);
    if (decoded is List) return decoded.cast<int>();
    return const <int>[];
  }

  /// Owner user ULID (primary key).
  final String userId;

  /// `light` | `dark` | `system`.
  final String theme;

  /// First day of the week, 0=Sun..6=Sat.
  final int weekStartsOn;

  /// Locale tag used for number formatting (`ru-KZ`, `en-US`, ...).
  final String numberFormat;

  /// Decimal separator character.
  final String decimalSeparator;

  /// Thousands separator character.
  final String thousandSeparator;

  /// Hide balances until the user re-authenticates.
  final bool hideBalancesUntilAuth;

  /// Require biometric auth to open the app.
  final bool biometricLock;

  /// Default account ULID for Quick Add.
  final String? defaultAccountId;

  /// Default expense category ULID for Quick Add.
  final String? defaultExpenseCategoryId;

  /// Default income category ULID for Quick Add.
  final String? defaultIncomeCategoryId;

  /// Preset amounts shown in the Quick Add sheet.
  final List<int> quickAddAmounts;

  /// Default value for "Carry over unspent" on new budgets.
  final bool budgetCarryoverDefault;

  /// Local time-of-day for the daily reminder (`HH:mm` string).
  final String? dailyReminderTime;

  /// Whether the home screen shows total across accounts.
  final bool showAccountTotalOnHome;

  /// `ru` | `kk` | `en`.
  final String language;

  /// Last update timestamp (UTC).
  final DateTime updatedAt;

  /// Lamport version counter (for field-level LWW merge).
  final int version;

  /// Serialises to a sqflite-friendly map.
  Map<String, Object?> toMap() => <String, Object?>{
        'user_id': userId,
        'theme': theme,
        'week_starts_on': weekStartsOn,
        'number_format': numberFormat,
        'decimal_separator': decimalSeparator,
        'thousand_separator': thousandSeparator,
        'hide_balances_until_auth': boolToInt(hideBalancesUntilAuth),
        'biometric_lock': boolToInt(biometricLock),
        'default_account_id': defaultAccountId,
        'default_expense_category_id': defaultExpenseCategoryId,
        'default_income_category_id': defaultIncomeCategoryId,
        'quick_add_amounts': jsonEncode(quickAddAmounts),
        'budget_carryover_default': boolToInt(budgetCarryoverDefault),
        'daily_reminder_time': dailyReminderTime,
        'show_account_total_on_home': boolToInt(showAccountTotalOnHome),
        'language': language,
        'updated_at': formatDate(updatedAt),
        'version': version,
      };
}
