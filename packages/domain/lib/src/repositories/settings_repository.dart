import '../values/ulid.dart';

/// Per-user preferences blob.
class UserSettings {
  /// Default constructor.
  const UserSettings({
    required this.userId,
    required this.theme,
    required this.weekStartsOn,
    required this.language,
    required this.numberFormat,
    required this.hideBalancesUntilAuth,
    required this.biometricLock,
    this.defaultAccountId,
    this.defaultExpenseCategoryId,
    this.defaultIncomeCategoryId,
    this.quickAddAmounts = const <int>[500, 1000, 2000, 5000],
    this.dailyReminderTime,
  });

  /// User the settings belong to.
  final Ulid userId;

  /// `light` | `dark` | `system`.
  final String theme;

  /// 0 = Sunday … 6 = Saturday.
  final int weekStartsOn;

  /// IETF language tag (`ru`, `kk`, `en`).
  final String language;

  /// BCP-47 number format.
  final String numberFormat;

  /// Mask balances on the dashboard until user authenticates.
  final bool hideBalancesUntilAuth;

  /// Require biometric on app open.
  final bool biometricLock;

  /// Default account for quick-add.
  final Ulid? defaultAccountId;

  /// Default expense category.
  final Ulid? defaultExpenseCategoryId;

  /// Default income category.
  final Ulid? defaultIncomeCategoryId;

  /// Quick-add chip amounts (minor units).
  final List<int> quickAddAmounts;

  /// Daily reminder time-of-day (HH:mm in user's timezone), null = off.
  final String? dailyReminderTime;

  /// Returns a copy with the given fields replaced.
  UserSettings copyWith({
    Ulid? userId,
    String? theme,
    int? weekStartsOn,
    String? language,
    String? numberFormat,
    bool? hideBalancesUntilAuth,
    bool? biometricLock,
    Ulid? defaultAccountId,
    Ulid? defaultExpenseCategoryId,
    Ulid? defaultIncomeCategoryId,
    List<int>? quickAddAmounts,
    String? dailyReminderTime,
  }) =>
      UserSettings(
        userId: userId ?? this.userId,
        theme: theme ?? this.theme,
        weekStartsOn: weekStartsOn ?? this.weekStartsOn,
        language: language ?? this.language,
        numberFormat: numberFormat ?? this.numberFormat,
        hideBalancesUntilAuth:
            hideBalancesUntilAuth ?? this.hideBalancesUntilAuth,
        biometricLock: biometricLock ?? this.biometricLock,
        defaultAccountId: defaultAccountId ?? this.defaultAccountId,
        defaultExpenseCategoryId:
            defaultExpenseCategoryId ?? this.defaultExpenseCategoryId,
        defaultIncomeCategoryId:
            defaultIncomeCategoryId ?? this.defaultIncomeCategoryId,
        quickAddAmounts: quickAddAmounts ?? this.quickAddAmounts,
        dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      );
}

/// Settings persistence contract.
abstract interface class SettingsRepository {
  /// Live stream of settings for [userId].
  Stream<UserSettings> watch(Ulid userId);

  /// Reads the current settings (create-or-load).
  Future<UserSettings> get(Ulid userId);

  /// Replaces the settings record.
  Future<void> save(UserSettings settings);
}
