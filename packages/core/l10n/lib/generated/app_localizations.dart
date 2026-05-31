// Hand-authored counterpart of `flutter gen-l10n` output.
// Keep in sync with ARB files under lib/l10n/.
//
// ignore_for_file: public_member_api_docs, type=lint

import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

/// Alias kept for compatibility with feature packages that import
/// `AppLocalizations` (the conventional Flutter gen-l10n class name).
typedef AppLocalizations = AppL10n;

/// Localized strings for FinNex. Use [AppL10n.of] to access in widgets.
abstract class AppL10n {
  AppL10n(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    final l10n = Localizations.of<AppL10n>(context, AppL10n);
    assert(l10n != null, 'No AppL10n found in context');
    return l10n!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('kk'),
  ];

  String get appName;

  String get commonCancel;
  String get commonSave;
  String get commonDelete;
  String get commonEdit;
  String get commonSearch;
  String get commonRetry;
  String get commonOk;
  String get commonYes;
  String get commonNo;
  String get commonDone;
  String get commonClose;
  String get commonNext;
  String get commonBack;
  String get commonContinue;
  String get commonLoading;
  String get commonAll;
  String get commonNone;
  String get commonOptional;
  String get commonRequired;

  String get navHome;
  String get navAnalytics;
  String get navCalendar;
  String get navSettings;
  String get navTransactions;
  String get navBudgets;

  String get splashLoadingLong;
  String get splashLoadingError;

  String get onbSkip;
  String get onbNext;
  String get onbStart;
  String get onbHaveAccount;
  String get onbP1Title;
  String get onbP1Body;
  String get onbP2Title;
  String get onbP2Body;
  String get onbP3Title;
  String get onbP3Body;
  String get onbP4Title;
  String get onbP4Body;

  String get authTitle;
  String get authSubtitle;
  String get authCtaSendCode;
  String get authOr;
  String get authContinueApple;
  String get authContinueGoogle;
  String get authContinueEmail;
  String get authSignUp;
  String get authOtpTitle;
  String authOtpSubtitle(String phone);
  String authOtpResendIn(String time);
  String get authOtpResend;
  String get authOtpHelp;
  String get authBiometricPrompt;
  String get authBiometricReason;
  String get authErrorNetwork;
  String get authErrorInvalidCode;
  String get authErrorRateLimit;
  String authLegal(String terms, String privacy);

  String dashGreeting(String name);
  String get dashPeriodDay;
  String get dashPeriodWeek;
  String get dashPeriodMonth;
  String dashDeltaUp(int percent);
  String dashDeltaDown(int percent);
  String get dashBudgetTitle;
  String dashBudgetDaysLeft(int days);
  String dashBudgetOver(String amount);
  String get dashRecent;
  String get dashSeeAll;
  String get dashEmptyTitle;
  String get dashEmptyCta;
  String get dashFab;
  String get dashOfflineBanner;

  String get qaExpenseTitle;
  String get qaIncomeTitle;
  String get qaTransferTitle;
  String get qaAmountRequired;
  String get qaDetails;
  String get qaNotePlaceholder;
  String get qaDateToday;
  String qaSavedExpense(String amount);
  String qaSavedIncome(String amount);
  String get qaSaveErrorOffline;
  String qaLimitNear(String spent, String budget);
  String qaLimitExceedTitle(String amount);
  String get qaLimitExceedSave;
  String get qaLimitExceedAdjust;
  String get qaIncomeRecurringHint;
  String qaIncomeProgress(String current, String expected);

  String get txFieldAmount;
  String get txFieldCategory;
  String get txFieldAccount;
  String get txFieldDate;
  String get txFieldTime;
  String get txFieldNote;
  String get txFieldTags;
  String get txFieldReceipt;
  String get txFieldLocation;
  String get txFieldRepeat;
  String get txFieldExcludeBudget;
  String get txTitleNewExpense;
  String get txTitleEditExpense;
  String get txUnsavedTitle;
  String get txUnsavedDiscard;
  String get txUnsavedKeep;
  String get txDeleteConfirm;
  String get txDeleted;
  String get txUndo;
  String get txEdit;
  String get txDuplicate;
  String get txShare;
  String get txDelete;
  String get txSourceWidget;
  String get txSourceManual;
  String get txSourceImport;
  String get txSyncQueued;
  String get txNotFound;
  String txCount(int count);
  String txDaysAgo(int days);
  String txItemsSelected(int count);

  String get catFood;
  String get catGroceries;
  String get catCafe;
  String get catRestaurants;
  String get catTransport;
  String get catTaxi;
  String get catFuel;
  String get catShopping;
  String get catClothing;
  String get catElectronics;
  String get catEntertainment;
  String get catSubscriptions;
  String get catBills;
  String get catUtilities;
  String get catRent;
  String get catHealth;
  String get catPharmacy;
  String get catEducation;
  String get catTravel;
  String get catHome;
  String get catGifts;
  String get catKids;
  String get catPets;
  String get catSports;
  String get catBeauty;
  String get catCharity;
  String get catTaxes;
  String get catFees;
  String get catOther;
  String get catIncSalary;
  String get catIncAdvance;
  String get catIncFreelance;
  String get catIncGift;
  String get catIncRefund;
  String get catIncCashback;
  String get catIncDividends;
  String get catIncInterest;

  String get catScreenTitle;
  String get catTabExpense;
  String get catTabIncome;
  String get catSectionCustom;
  String get catSectionSystem;
  String get catAdd;
  String get catFieldName;
  String get catFieldIcon;
  String get catFieldColor;
  String get catFieldParent;

  String get budgetsTitle;
  String get budgetsEmpty;
  String get budgetsCreate;
  String get budgetFieldName;
  String get budgetFieldLimit;
  String get budgetFieldPeriod;
  String get budgetFieldCategory;
  String get budgetPeriodWeek;
  String get budgetPeriodMonth;
  String get budgetPeriodYear;
  String get budgetAlertAt80;
  String budgetProgressLabel(String spent, String limit);

  String get anTitle;
  String get anPeriodDay;
  String get anPeriodWeek;
  String get anPeriodMonth;
  String get anPeriodYear;
  String get anPeriodCustom;
  String get anSumExpense;
  String get anSumIncome;
  String get anSumBalance;
  String get anByCategory;
  String get anByWeek;
  String get anByMonth;
  String get anCashFlow;
  String get anEmpty;

  String get calTitle;
  String get calViewMonth;
  String get calViewWeek;
  String get calDayEmpty;
  String get calDayAdd;

  String get notifTitle;
  String get notifEmpty;
  String get notifDailyReminderTitle;
  String get notifDailyReminderBody;
  String get notifWeeklyRecapTitle;
  String notifWeeklyRecapBody(String amount);
  String get notifLimitWarningTitle;
  String notifLimitWarningBody(String category, int percent);
  String get notifInsightReadyTitle;
  String get notifInsightReadyBody;

  String get setTitle;
  String get setProfile;
  String get setAppearance;
  String get setTheme;
  String get setThemeSystem;
  String get setThemeLight;
  String get setThemeDark;
  String get setLanguage;
  String get setLanguageEn;
  String get setLanguageRu;
  String get setLanguageKk;
  String get setCurrency;
  String get setSecurity;
  String get setBiometric;
  String get setPin;
  String get setNotifications;
  String get setNotifDaily;
  String get setNotifWeekly;
  String get setNotifLimit;
  String get setNotifInsights;
  String get setData;
  String get setExport;
  String get setImport;
  String get setSync;
  String get setAbout;
  String setVersion(String version);
  String get setSignOut;
  String get setDeleteAccount;
  String get setDeleteAccountConfirm;

  String get errorNetwork;
  String get errorServer;
  String get errorValidation;
  String get errorSyncConflict;
  String get errorOffline;
  String get errorUnknown;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(_lookup(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>{'en', 'ru', 'kk'}.contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;

  AppL10n _lookup(Locale locale) {
    switch (locale.languageCode) {
      case 'ru':
        return AppL10nRu();
      case 'kk':
        return AppL10nKk();
      case 'en':
      default:
        return AppL10nEn();
    }
  }
}

// ---------------------------------------------------------------------------
// English
// ---------------------------------------------------------------------------
class AppL10nEn extends AppL10n {
  AppL10nEn() : super('en');

  @override
  String get appName => 'FinNex';

  @override
  String get commonCancel => 'Cancel';
  @override
  String get commonSave => 'Save';
  @override
  String get commonDelete => 'Delete';
  @override
  String get commonEdit => 'Edit';
  @override
  String get commonSearch => 'Search';
  @override
  String get commonRetry => 'Retry';
  @override
  String get commonOk => 'OK';
  @override
  String get commonYes => 'Yes';
  @override
  String get commonNo => 'No';
  @override
  String get commonDone => 'Done';
  @override
  String get commonClose => 'Close';
  @override
  String get commonNext => 'Next';
  @override
  String get commonBack => 'Back';
  @override
  String get commonContinue => 'Continue';
  @override
  String get commonLoading => 'Loading…';
  @override
  String get commonAll => 'All';
  @override
  String get commonNone => 'None';
  @override
  String get commonOptional => 'Optional';
  @override
  String get commonRequired => 'Required';

  @override
  String get navHome => 'Home';
  @override
  String get navAnalytics => 'Analytics';
  @override
  String get navCalendar => 'Calendar';
  @override
  String get navSettings => 'Settings';
  @override
  String get navTransactions => 'Transactions';
  @override
  String get navBudgets => 'Budgets';

  @override
  String get splashLoadingLong => 'Loading your data…';
  @override
  String get splashLoadingError => "Couldn't start the app";

  @override
  String get onbSkip => 'Skip';
  @override
  String get onbNext => 'Next';
  @override
  String get onbStart => 'Get started';
  @override
  String get onbHaveAccount => 'I already have an account';
  @override
  String get onbP1Title => 'Track in 3 seconds';
  @override
  String get onbP1Body => 'Log expenses in one tap. No clunky forms.';
  @override
  String get onbP2Title => 'Categories your way';
  @override
  String get onbP2Body => 'Ready-made KZ categories. Add your own.';
  @override
  String get onbP3Title => 'One tap, expense logged';
  @override
  String get onbP3Body =>
      'Widgets for iOS and Android. No need to open the app.';
  @override
  String get onbP4Title => 'Ready to begin?';
  @override
  String get onbP4Body => 'Pick language and currency — 10 seconds.';

  @override
  String get authTitle => 'Sign in to FinNex';
  @override
  String get authSubtitle => 'No password. Just your phone.';
  @override
  String get authCtaSendCode => 'Get code';
  @override
  String get authOr => 'or';
  @override
  String get authContinueApple => 'Continue with Apple';
  @override
  String get authContinueGoogle => 'Continue with Google';
  @override
  String get authContinueEmail => 'Continue with email';
  @override
  String get authSignUp => 'Create account';
  @override
  String get authOtpTitle => 'Enter code';
  @override
  String authOtpSubtitle(String phone) => 'We sent an SMS to $phone.';
  @override
  String authOtpResendIn(String time) => 'Resend in $time';
  @override
  String get authOtpResend => 'Resend code';
  @override
  String get authOtpHelp => "Didn't get the code?";
  @override
  String get authBiometricPrompt => 'Use biometrics to sign in';
  @override
  String get authBiometricReason => "Confirm it's you to open FinNex";
  @override
  String get authErrorNetwork => 'Check your connection';
  @override
  String get authErrorInvalidCode => 'Wrong code';
  @override
  String get authErrorRateLimit =>
      'Too many attempts. Try again in 5 minutes.';
  @override
  String authLegal(String terms, String privacy) =>
      'By continuing, you agree to $terms and $privacy.';

  @override
  String dashGreeting(String name) => 'Hi, $name';
  @override
  String get dashPeriodDay => 'Today';
  @override
  String get dashPeriodWeek => 'Week';
  @override
  String get dashPeriodMonth => 'Month';
  @override
  String dashDeltaUp(int percent) => '+$percent% vs last week';
  @override
  String dashDeltaDown(int percent) => '−$percent% vs last week';
  @override
  String get dashBudgetTitle => 'Monthly budget';
  @override
  String dashBudgetDaysLeft(int days) {
    return intl.Intl.pluralLogic(
      days,
      locale: localeName,
      one: '1 day left',
      other: '$days days left',
    );
  }

  @override
  String dashBudgetOver(String amount) => 'Over budget: $amount';
  @override
  String get dashRecent => 'Recent activity';
  @override
  String get dashSeeAll => 'See all';
  @override
  String get dashEmptyTitle => 'No expenses yet';
  @override
  String get dashEmptyCta => 'Add your first expense';
  @override
  String get dashFab => 'Add';
  @override
  String get dashOfflineBanner => 'Offline. Changes will sync.';

  @override
  String get qaExpenseTitle => 'Expense';
  @override
  String get qaIncomeTitle => 'Income';
  @override
  String get qaTransferTitle => 'Transfer';
  @override
  String get qaAmountRequired => 'Enter amount';
  @override
  String get qaDetails => 'Details';
  @override
  String get qaNotePlaceholder => 'Note (optional)';
  @override
  String get qaDateToday => 'Today';
  @override
  String qaSavedExpense(String amount) => 'Expense $amount added';
  @override
  String qaSavedIncome(String amount) => 'Income $amount added';
  @override
  String get qaSaveErrorOffline => "Couldn't save. Queued.";
  @override
  String qaLimitNear(String spent, String budget) =>
      'Near limit: $spent / $budget';
  @override
  String qaLimitExceedTitle(String amount) =>
      'This exceeds your limit by $amount';
  @override
  String get qaLimitExceedSave => 'Save anyway';
  @override
  String get qaLimitExceedAdjust => 'Change amount';
  @override
  String get qaIncomeRecurringHint => 'Make this recurring?';
  @override
  String qaIncomeProgress(String current, String expected) =>
      '$current of $expected';

  @override
  String get txFieldAmount => 'Amount';
  @override
  String get txFieldCategory => 'Category';
  @override
  String get txFieldAccount => 'Account';
  @override
  String get txFieldDate => 'Date';
  @override
  String get txFieldTime => 'Time';
  @override
  String get txFieldNote => 'Note';
  @override
  String get txFieldTags => 'Tags';
  @override
  String get txFieldReceipt => 'Receipt';
  @override
  String get txFieldLocation => 'Location';
  @override
  String get txFieldRepeat => 'Repeat';
  @override
  String get txFieldExcludeBudget => 'Exclude from budget';
  @override
  String get txTitleNewExpense => 'Expense';
  @override
  String get txTitleEditExpense => 'Edit expense';
  @override
  String get txUnsavedTitle => 'Discard changes?';
  @override
  String get txUnsavedDiscard => 'Discard';
  @override
  String get txUnsavedKeep => 'Keep editing';
  @override
  String get txDeleteConfirm => 'Delete this transaction? Cannot be undone.';
  @override
  String get txDeleted => 'Deleted';
  @override
  String get txUndo => 'Undo';
  @override
  String get txEdit => 'Edit';
  @override
  String get txDuplicate => 'Duplicate';
  @override
  String get txShare => 'Share';
  @override
  String get txDelete => 'Delete';
  @override
  String get txSourceWidget => 'Widget';
  @override
  String get txSourceManual => 'Manual';
  @override
  String get txSourceImport => 'Import';
  @override
  String get txSyncQueued => 'Queued for sync';
  @override
  String get txNotFound => 'Transaction not found';
  @override
  String txCount(int count) {
    return intl.Intl.pluralLogic(
      count,
      locale: localeName,
      zero: 'No transactions',
      one: '1 transaction',
      other: '$count transactions',
    );
  }

  @override
  String txDaysAgo(int days) {
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    return '$days days ago';
  }

  @override
  String txItemsSelected(int count) {
    return intl.Intl.pluralLogic(
      count,
      locale: localeName,
      one: '1 item selected',
      other: '$count items selected',
    );
  }

  @override
  String get catFood => 'Food';
  @override
  String get catGroceries => 'Groceries';
  @override
  String get catCafe => 'Café';
  @override
  String get catRestaurants => 'Restaurants';
  @override
  String get catTransport => 'Transport';
  @override
  String get catTaxi => 'Taxi';
  @override
  String get catFuel => 'Fuel';
  @override
  String get catShopping => 'Shopping';
  @override
  String get catClothing => 'Clothing';
  @override
  String get catElectronics => 'Electronics';
  @override
  String get catEntertainment => 'Entertainment';
  @override
  String get catSubscriptions => 'Subscriptions';
  @override
  String get catBills => 'Bills';
  @override
  String get catUtilities => 'Utilities';
  @override
  String get catRent => 'Rent';
  @override
  String get catHealth => 'Health';
  @override
  String get catPharmacy => 'Pharmacy';
  @override
  String get catEducation => 'Education';
  @override
  String get catTravel => 'Travel';
  @override
  String get catHome => 'Home';
  @override
  String get catGifts => 'Gifts';
  @override
  String get catKids => 'Kids';
  @override
  String get catPets => 'Pets';
  @override
  String get catSports => 'Sports';
  @override
  String get catBeauty => 'Beauty';
  @override
  String get catCharity => 'Charity';
  @override
  String get catTaxes => 'Taxes';
  @override
  String get catFees => 'Fees';
  @override
  String get catOther => 'Other';
  @override
  String get catIncSalary => 'Salary';
  @override
  String get catIncAdvance => 'Advance';
  @override
  String get catIncFreelance => 'Freelance';
  @override
  String get catIncGift => 'Gift';
  @override
  String get catIncRefund => 'Refund';
  @override
  String get catIncCashback => 'Cashback';
  @override
  String get catIncDividends => 'Dividends';
  @override
  String get catIncInterest => 'Interest';

  @override
  String get catScreenTitle => 'Categories';
  @override
  String get catTabExpense => 'Expenses';
  @override
  String get catTabIncome => 'Income';
  @override
  String get catSectionCustom => 'My categories';
  @override
  String get catSectionSystem => 'Built-in';
  @override
  String get catAdd => 'Add category';
  @override
  String get catFieldName => 'Name';
  @override
  String get catFieldIcon => 'Icon';
  @override
  String get catFieldColor => 'Color';
  @override
  String get catFieldParent => 'Parent category';

  @override
  String get budgetsTitle => 'Budgets';
  @override
  String get budgetsEmpty => 'No budgets yet';
  @override
  String get budgetsCreate => 'Create budget';
  @override
  String get budgetFieldName => 'Name';
  @override
  String get budgetFieldLimit => 'Limit';
  @override
  String get budgetFieldPeriod => 'Period';
  @override
  String get budgetFieldCategory => 'Category';
  @override
  String get budgetPeriodWeek => 'Weekly';
  @override
  String get budgetPeriodMonth => 'Monthly';
  @override
  String get budgetPeriodYear => 'Yearly';
  @override
  String get budgetAlertAt80 => 'Alert me at 80%';
  @override
  String budgetProgressLabel(String spent, String limit) =>
      '$spent of $limit';

  @override
  String get anTitle => 'Analytics';
  @override
  String get anPeriodDay => 'Day';
  @override
  String get anPeriodWeek => 'Week';
  @override
  String get anPeriodMonth => 'Month';
  @override
  String get anPeriodYear => 'Year';
  @override
  String get anPeriodCustom => 'Custom';
  @override
  String get anSumExpense => 'Expenses';
  @override
  String get anSumIncome => 'Income';
  @override
  String get anSumBalance => 'Balance';
  @override
  String get anByCategory => 'By category';
  @override
  String get anByWeek => 'By week';
  @override
  String get anByMonth => 'By month';
  @override
  String get anCashFlow => 'Cash flow';
  @override
  String get anEmpty => 'No data for this period';

  @override
  String get calTitle => 'Calendar';
  @override
  String get calViewMonth => 'Month';
  @override
  String get calViewWeek => 'Week';
  @override
  String get calDayEmpty => 'No transactions';
  @override
  String get calDayAdd => 'Add for this day';

  @override
  String get notifTitle => 'Notifications';
  @override
  String get notifEmpty => 'All caught up';
  @override
  String get notifDailyReminderTitle => "Log today's expenses";
  @override
  String get notifDailyReminderBody => 'Takes 3 seconds. Tap to add.';
  @override
  String get notifWeeklyRecapTitle => 'Your week in numbers';
  @override
  String notifWeeklyRecapBody(String amount) =>
      'You spent $amount this week.';
  @override
  String get notifLimitWarningTitle => 'Budget alert';
  @override
  String notifLimitWarningBody(String category, int percent) =>
      '$category is at $percent% of its limit.';
  @override
  String get notifInsightReadyTitle => 'New insight';
  @override
  String get notifInsightReadyBody => 'Open FinNex to see what changed.';

  @override
  String get setTitle => 'Settings';
  @override
  String get setProfile => 'Profile';
  @override
  String get setAppearance => 'Appearance';
  @override
  String get setTheme => 'Theme';
  @override
  String get setThemeSystem => 'System';
  @override
  String get setThemeLight => 'Light';
  @override
  String get setThemeDark => 'Dark';
  @override
  String get setLanguage => 'Language';
  @override
  String get setLanguageEn => 'English';
  @override
  String get setLanguageRu => 'Русский';
  @override
  String get setLanguageKk => 'Қазақша';
  @override
  String get setCurrency => 'Currency';
  @override
  String get setSecurity => 'Security';
  @override
  String get setBiometric => 'Unlock with biometrics';
  @override
  String get setPin => 'App PIN';
  @override
  String get setNotifications => 'Notifications';
  @override
  String get setNotifDaily => 'Daily reminder';
  @override
  String get setNotifWeekly => 'Weekly recap';
  @override
  String get setNotifLimit => 'Budget alerts';
  @override
  String get setNotifInsights => 'Insights';
  @override
  String get setData => 'Data';
  @override
  String get setExport => 'Export data';
  @override
  String get setImport => 'Import data';
  @override
  String get setSync => 'Sync now';
  @override
  String get setAbout => 'About';
  @override
  String setVersion(String version) => 'Version $version';
  @override
  String get setSignOut => 'Sign out';
  @override
  String get setDeleteAccount => 'Delete account';
  @override
  String get setDeleteAccountConfirm =>
      'Delete your account? All data will be erased.';

  @override
  String get errorNetwork => 'Network error. Check your connection.';
  @override
  String get errorServer => 'Something went wrong on our end.';
  @override
  String get errorValidation => 'Please check the highlighted fields.';
  @override
  String get errorSyncConflict =>
      'Sync conflict. We kept your latest changes.';
  @override
  String get errorOffline =>
      "You're offline. Changes are saved locally.";
  @override
  String get errorUnknown => 'Unexpected error';
}

// ---------------------------------------------------------------------------
// Russian
// ---------------------------------------------------------------------------
class AppL10nRu extends AppL10n {
  AppL10nRu() : super('ru');

  @override
  String get appName => 'FinNex';

  @override
  String get commonCancel => 'Отмена';
  @override
  String get commonSave => 'Сохранить';
  @override
  String get commonDelete => 'Удалить';
  @override
  String get commonEdit => 'Изменить';
  @override
  String get commonSearch => 'Поиск';
  @override
  String get commonRetry => 'Повторить';
  @override
  String get commonOk => 'ОК';
  @override
  String get commonYes => 'Да';
  @override
  String get commonNo => 'Нет';
  @override
  String get commonDone => 'Готово';
  @override
  String get commonClose => 'Закрыть';
  @override
  String get commonNext => 'Далее';
  @override
  String get commonBack => 'Назад';
  @override
  String get commonContinue => 'Продолжить';
  @override
  String get commonLoading => 'Загрузка…';
  @override
  String get commonAll => 'Все';
  @override
  String get commonNone => 'Нет';
  @override
  String get commonOptional => 'Необязательно';
  @override
  String get commonRequired => 'Обязательно';

  @override
  String get navHome => 'Главная';
  @override
  String get navAnalytics => 'Аналитика';
  @override
  String get navCalendar => 'Календарь';
  @override
  String get navSettings => 'Настройки';
  @override
  String get navTransactions => 'Операции';
  @override
  String get navBudgets => 'Бюджеты';

  @override
  String get splashLoadingLong => 'Загружаем ваши данные…';
  @override
  String get splashLoadingError => 'Не удалось запустить приложение';

  @override
  String get onbSkip => 'Пропустить';
  @override
  String get onbNext => 'Дальше';
  @override
  String get onbStart => 'Начать';
  @override
  String get onbHaveAccount => 'У меня уже есть аккаунт';
  @override
  String get onbP1Title => 'Учёт за 3 секунды';
  @override
  String get onbP1Body => 'Запишите расход одним тапом. Без сложных форм.';
  @override
  String get onbP2Title => 'Категории под вас';
  @override
  String get onbP2Body =>
      'Готовые категории для Казахстана. Добавляйте свои.';
  @override
  String get onbP3Title => 'Один тап — расход записан';
  @override
  String get onbP3Body =>
      'Виджет для iOS и Android. Не нужно открывать приложение.';
  @override
  String get onbP4Title => 'Готовы начать?';
  @override
  String get onbP4Body =>
      'Выберите язык и валюту — займёт 10 секунд.';

  @override
  String get authTitle => 'Войти в FinNex';
  @override
  String get authSubtitle => 'Без пароля. Только номер телефона.';
  @override
  String get authCtaSendCode => 'Получить код';
  @override
  String get authOr => 'или';
  @override
  String get authContinueApple => 'Войти через Apple';
  @override
  String get authContinueGoogle => 'Войти через Google';
  @override
  String get authContinueEmail => 'Войти через email';
  @override
  String get authSignUp => 'Создать аккаунт';
  @override
  String get authOtpTitle => 'Введите код';
  @override
  String authOtpSubtitle(String phone) => 'Отправили SMS на $phone.';
  @override
  String authOtpResendIn(String time) => 'Отправить заново через $time';
  @override
  String get authOtpResend => 'Отправить заново';
  @override
  String get authOtpHelp => 'Не получили код?';
  @override
  String get authBiometricPrompt => 'Войти по биометрии';
  @override
  String get authBiometricReason => 'Подтвердите вход в FinNex';
  @override
  String get authErrorNetwork => 'Проверьте интернет';
  @override
  String get authErrorInvalidCode => 'Неверный код';
  @override
  String get authErrorRateLimit =>
      'Слишком много попыток. Попробуйте через 5 минут.';
  @override
  String authLegal(String terms, String privacy) =>
      'Продолжая, вы принимаете $terms и $privacy.';

  @override
  String dashGreeting(String name) => 'Привет, $name';
  @override
  String get dashPeriodDay => 'Сегодня';
  @override
  String get dashPeriodWeek => 'Неделя';
  @override
  String get dashPeriodMonth => 'Месяц';
  @override
  String dashDeltaUp(int percent) => '+$percent% к прошлой неделе';
  @override
  String dashDeltaDown(int percent) => '−$percent% к прошлой неделе';
  @override
  String get dashBudgetTitle => 'Бюджет на месяц';
  @override
  String dashBudgetDaysLeft(int days) {
    return intl.Intl.pluralLogic(
      days,
      locale: localeName,
      one: 'остался $days день',
      few: 'осталось $days дня',
      many: 'осталось $days дней',
      other: 'осталось $days дня',
    );
  }

  @override
  String dashBudgetOver(String amount) => 'Сверх бюджета: $amount';
  @override
  String get dashRecent => 'Последние операции';
  @override
  String get dashSeeAll => 'Все';
  @override
  String get dashEmptyTitle => 'Пока нет расходов';
  @override
  String get dashEmptyCta => 'Добавить первый расход';
  @override
  String get dashFab => 'Добавить';
  @override
  String get dashOfflineBanner => 'Офлайн. Изменения сохранятся.';

  @override
  String get qaExpenseTitle => 'Расход';
  @override
  String get qaIncomeTitle => 'Доход';
  @override
  String get qaTransferTitle => 'Перевод';
  @override
  String get qaAmountRequired => 'Введите сумму';
  @override
  String get qaDetails => 'Детали';
  @override
  String get qaNotePlaceholder => 'Заметка (необязательно)';
  @override
  String get qaDateToday => 'Сегодня';
  @override
  String qaSavedExpense(String amount) => 'Расход $amount добавлен';
  @override
  String qaSavedIncome(String amount) => 'Доход $amount добавлен';
  @override
  String get qaSaveErrorOffline => 'Не сохранилось. Запись в очереди.';
  @override
  String qaLimitNear(String spent, String budget) =>
      'Скоро лимит: $spent / $budget';
  @override
  String qaLimitExceedTitle(String amount) =>
      'Превысите лимит на $amount';
  @override
  String get qaLimitExceedSave => 'Всё равно записать';
  @override
  String get qaLimitExceedAdjust => 'Изменить сумму';
  @override
  String get qaIncomeRecurringHint => 'Сделать регулярным?';
  @override
  String qaIncomeProgress(String current, String expected) =>
      '$current из $expected';

  @override
  String get txFieldAmount => 'Сумма';
  @override
  String get txFieldCategory => 'Категория';
  @override
  String get txFieldAccount => 'Счёт';
  @override
  String get txFieldDate => 'Дата';
  @override
  String get txFieldTime => 'Время';
  @override
  String get txFieldNote => 'Заметка';
  @override
  String get txFieldTags => 'Теги';
  @override
  String get txFieldReceipt => 'Чек';
  @override
  String get txFieldLocation => 'Место';
  @override
  String get txFieldRepeat => 'Повтор';
  @override
  String get txFieldExcludeBudget => 'Не учитывать в бюджете';
  @override
  String get txTitleNewExpense => 'Расход';
  @override
  String get txTitleEditExpense => 'Изменить расход';
  @override
  String get txUnsavedTitle => 'Отменить изменения?';
  @override
  String get txUnsavedDiscard => 'Отменить';
  @override
  String get txUnsavedKeep => 'Продолжить';
  @override
  String get txDeleteConfirm => 'Удалить операцию? Это нельзя отменить.';
  @override
  String get txDeleted => 'Удалено';
  @override
  String get txUndo => 'Отменить';
  @override
  String get txEdit => 'Редактировать';
  @override
  String get txDuplicate => 'Дублировать';
  @override
  String get txShare => 'Поделиться';
  @override
  String get txDelete => 'Удалить';
  @override
  String get txSourceWidget => 'Виджет';
  @override
  String get txSourceManual => 'Ручной ввод';
  @override
  String get txSourceImport => 'Импорт';
  @override
  String get txSyncQueued => 'В очереди на синхронизацию';
  @override
  String get txNotFound => 'Операция не найдена';
  @override
  String txCount(int count) {
    return intl.Intl.pluralLogic(
      count,
      locale: localeName,
      zero: 'Нет операций',
      one: '$count операция',
      few: '$count операции',
      many: '$count операций',
      other: '$count операции',
    );
  }

  @override
  String txDaysAgo(int days) {
    if (days == 0) return 'Сегодня';
    if (days == 1) return 'Вчера';
    return intl.Intl.pluralLogic(
      days,
      locale: localeName,
      one: '$days день назад',
      few: '$days дня назад',
      many: '$days дней назад',
      other: '$days дня назад',
    );
  }

  @override
  String txItemsSelected(int count) {
    return intl.Intl.pluralLogic(
      count,
      locale: localeName,
      one: 'Выбран $count элемент',
      few: 'Выбрано $count элемента',
      many: 'Выбрано $count элементов',
      other: 'Выбрано $count элемента',
    );
  }

  @override
  String get catFood => 'Еда';
  @override
  String get catGroceries => 'Продукты';
  @override
  String get catCafe => 'Кафе';
  @override
  String get catRestaurants => 'Рестораны';
  @override
  String get catTransport => 'Транспорт';
  @override
  String get catTaxi => 'Такси';
  @override
  String get catFuel => 'Топливо';
  @override
  String get catShopping => 'Покупки';
  @override
  String get catClothing => 'Одежда';
  @override
  String get catElectronics => 'Электроника';
  @override
  String get catEntertainment => 'Развлечения';
  @override
  String get catSubscriptions => 'Подписки';
  @override
  String get catBills => 'Счета';
  @override
  String get catUtilities => 'Коммунальные';
  @override
  String get catRent => 'Аренда';
  @override
  String get catHealth => 'Здоровье';
  @override
  String get catPharmacy => 'Аптека';
  @override
  String get catEducation => 'Образование';
  @override
  String get catTravel => 'Путешествия';
  @override
  String get catHome => 'Дом';
  @override
  String get catGifts => 'Подарки';
  @override
  String get catKids => 'Дети';
  @override
  String get catPets => 'Питомцы';
  @override
  String get catSports => 'Спорт';
  @override
  String get catBeauty => 'Красота';
  @override
  String get catCharity => 'Благотворительность';
  @override
  String get catTaxes => 'Налоги';
  @override
  String get catFees => 'Комиссии';
  @override
  String get catOther => 'Прочее';
  @override
  String get catIncSalary => 'Зарплата';
  @override
  String get catIncAdvance => 'Аванс';
  @override
  String get catIncFreelance => 'Фриланс';
  @override
  String get catIncGift => 'Подарок';
  @override
  String get catIncRefund => 'Возврат';
  @override
  String get catIncCashback => 'Кэшбэк';
  @override
  String get catIncDividends => 'Дивиденды';
  @override
  String get catIncInterest => 'Проценты';

  @override
  String get catScreenTitle => 'Категории';
  @override
  String get catTabExpense => 'Расходы';
  @override
  String get catTabIncome => 'Доходы';
  @override
  String get catSectionCustom => 'Мои категории';
  @override
  String get catSectionSystem => 'Системные';
  @override
  String get catAdd => 'Добавить категорию';
  @override
  String get catFieldName => 'Название';
  @override
  String get catFieldIcon => 'Иконка';
  @override
  String get catFieldColor => 'Цвет';
  @override
  String get catFieldParent => 'Родительская категория';

  @override
  String get budgetsTitle => 'Бюджеты';
  @override
  String get budgetsEmpty => 'Бюджетов пока нет';
  @override
  String get budgetsCreate => 'Создать бюджет';
  @override
  String get budgetFieldName => 'Название';
  @override
  String get budgetFieldLimit => 'Лимит';
  @override
  String get budgetFieldPeriod => 'Период';
  @override
  String get budgetFieldCategory => 'Категория';
  @override
  String get budgetPeriodWeek => 'Неделя';
  @override
  String get budgetPeriodMonth => 'Месяц';
  @override
  String get budgetPeriodYear => 'Год';
  @override
  String get budgetAlertAt80 => 'Предупредить при 80%';
  @override
  String budgetProgressLabel(String spent, String limit) =>
      '$spent из $limit';

  @override
  String get anTitle => 'Аналитика';
  @override
  String get anPeriodDay => 'День';
  @override
  String get anPeriodWeek => 'Неделя';
  @override
  String get anPeriodMonth => 'Месяц';
  @override
  String get anPeriodYear => 'Год';
  @override
  String get anPeriodCustom => 'Свой';
  @override
  String get anSumExpense => 'Расходы';
  @override
  String get anSumIncome => 'Доходы';
  @override
  String get anSumBalance => 'Баланс';
  @override
  String get anByCategory => 'По категориям';
  @override
  String get anByWeek => 'По неделям';
  @override
  String get anByMonth => 'По месяцам';
  @override
  String get anCashFlow => 'Денежный поток';
  @override
  String get anEmpty => 'Нет данных за этот период';

  @override
  String get calTitle => 'Календарь';
  @override
  String get calViewMonth => 'Месяц';
  @override
  String get calViewWeek => 'Неделя';
  @override
  String get calDayEmpty => 'Нет операций';
  @override
  String get calDayAdd => 'Добавить за этот день';

  @override
  String get notifTitle => 'Уведомления';
  @override
  String get notifEmpty => 'Всё прочитано';
  @override
  String get notifDailyReminderTitle => 'Запишите расходы за сегодня';
  @override
  String get notifDailyReminderBody =>
      'Займёт 3 секунды. Нажмите, чтобы добавить.';
  @override
  String get notifWeeklyRecapTitle => 'Ваша неделя в цифрах';
  @override
  String notifWeeklyRecapBody(String amount) =>
      'За эту неделю вы потратили $amount.';
  @override
  String get notifLimitWarningTitle => 'Бюджетный алерт';
  @override
  String notifLimitWarningBody(String category, int percent) =>
      'Категория $category достигла $percent% лимита.';
  @override
  String get notifInsightReadyTitle => 'Новый инсайт';
  @override
  String get notifInsightReadyBody =>
      'Откройте FinNex, чтобы узнать подробности.';

  @override
  String get setTitle => 'Настройки';
  @override
  String get setProfile => 'Профиль';
  @override
  String get setAppearance => 'Оформление';
  @override
  String get setTheme => 'Тема';
  @override
  String get setThemeSystem => 'Системная';
  @override
  String get setThemeLight => 'Светлая';
  @override
  String get setThemeDark => 'Тёмная';
  @override
  String get setLanguage => 'Язык';
  @override
  String get setLanguageEn => 'English';
  @override
  String get setLanguageRu => 'Русский';
  @override
  String get setLanguageKk => 'Қазақша';
  @override
  String get setCurrency => 'Валюта';
  @override
  String get setSecurity => 'Безопасность';
  @override
  String get setBiometric => 'Вход по биометрии';
  @override
  String get setPin => 'PIN-код';
  @override
  String get setNotifications => 'Уведомления';
  @override
  String get setNotifDaily => 'Ежедневное напоминание';
  @override
  String get setNotifWeekly => 'Еженедельная сводка';
  @override
  String get setNotifLimit => 'Бюджетные алерты';
  @override
  String get setNotifInsights => 'Инсайты';
  @override
  String get setData => 'Данные';
  @override
  String get setExport => 'Экспорт данных';
  @override
  String get setImport => 'Импорт данных';
  @override
  String get setSync => 'Синхронизировать';
  @override
  String get setAbout => 'О приложении';
  @override
  String setVersion(String version) => 'Версия $version';
  @override
  String get setSignOut => 'Выйти';
  @override
  String get setDeleteAccount => 'Удалить аккаунт';
  @override
  String get setDeleteAccountConfirm =>
      'Удалить аккаунт? Все данные будут стёрты.';

  @override
  String get errorNetwork => 'Ошибка сети. Проверьте подключение.';
  @override
  String get errorServer => 'Что-то пошло не так на нашей стороне.';
  @override
  String get errorValidation => 'Проверьте подсвеченные поля.';
  @override
  String get errorSyncConflict =>
      'Конфликт синхронизации. Мы сохранили последние изменения.';
  @override
  String get errorOffline =>
      'Вы офлайн. Изменения сохранены локально.';
  @override
  String get errorUnknown => 'Непредвиденная ошибка';
}

// ---------------------------------------------------------------------------
// Kazakh
// ---------------------------------------------------------------------------
class AppL10nKk extends AppL10n {
  AppL10nKk() : super('kk');

  @override
  String get appName => 'FinNex';

  @override
  String get commonCancel => 'Болдырмау';
  @override
  String get commonSave => 'Сақтау';
  @override
  String get commonDelete => 'Жою';
  @override
  String get commonEdit => 'Өзгерту';
  @override
  String get commonSearch => 'Іздеу';
  @override
  String get commonRetry => 'Қайталау';
  @override
  String get commonOk => 'Жарайды';
  @override
  String get commonYes => 'Иә';
  @override
  String get commonNo => 'Жоқ';
  @override
  String get commonDone => 'Дайын';
  @override
  String get commonClose => 'Жабу';
  @override
  String get commonNext => 'Әрі қарай';
  @override
  String get commonBack => 'Артқа';
  @override
  String get commonContinue => 'Жалғастыру';
  @override
  String get commonLoading => 'Жүктелуде…';
  @override
  String get commonAll => 'Барлығы';
  @override
  String get commonNone => 'Жоқ';
  @override
  String get commonOptional => 'Міндетті емес';
  @override
  String get commonRequired => 'Міндетті';

  @override
  String get navHome => 'Басты';
  @override
  String get navAnalytics => 'Аналитика';
  @override
  String get navCalendar => 'Күнтізбе';
  @override
  String get navSettings => 'Баптаулар';
  @override
  String get navTransactions => 'Операциялар';
  @override
  String get navBudgets => 'Бюджеттер';

  @override
  String get splashLoadingLong => 'Деректер жүктелуде…';
  @override
  String get splashLoadingError => 'Қолданба іске қосылмады';

  @override
  String get onbSkip => 'Өткізіп жіберу';
  @override
  String get onbNext => 'Әрі қарай';
  @override
  String get onbStart => 'Бастау';
  @override
  String get onbHaveAccount => 'Менің аккаунтым бар';
  @override
  String get onbP1Title => '3 секундта есепке алу';
  @override
  String get onbP1Body =>
      'Бір рет түртіп шығынды жазыңыз. Күрделі формасыз.';
  @override
  String get onbP2Title => 'Сізге арналған санаттар';
  @override
  String get onbP2Body =>
      'Қазақстанға арналған дайын санаттар. Өзіңіздікін қосыңыз.';
  @override
  String get onbP3Title => 'Бір түрту — шығын жазылды';
  @override
  String get onbP3Body =>
      'iOS пен Android виджеті. Қолданбаны ашудың қажеті жоқ.';
  @override
  String get onbP4Title => 'Бастауға дайынсыз ба?';
  @override
  String get onbP4Body =>
      'Тіл мен валютаны таңдаңыз — 10 секундты алады.';

  @override
  String get authTitle => 'FinNex-ке кіру';
  @override
  String get authSubtitle => 'Парольсіз. Тек телефон нөмірі.';
  @override
  String get authCtaSendCode => 'Кодты алу';
  @override
  String get authOr => 'немесе';
  @override
  String get authContinueApple => 'Apple арқылы кіру';
  @override
  String get authContinueGoogle => 'Google арқылы кіру';
  @override
  String get authContinueEmail => 'Email арқылы кіру';
  @override
  String get authSignUp => 'Аккаунт құру';
  @override
  String get authOtpTitle => 'Кодты енгізіңіз';
  @override
  String authOtpSubtitle(String phone) => 'SMS жіберілді: $phone.';
  @override
  String authOtpResendIn(String time) => '$time кейін қайта жіберу';
  @override
  String get authOtpResend => 'Қайта жіберу';
  @override
  String get authOtpHelp => 'Кодты алмадыңыз ба?';
  @override
  String get authBiometricPrompt => 'Биометрия арқылы кіру';
  @override
  String get authBiometricReason => 'FinNex-ке кіруді растаңыз';
  @override
  String get authErrorNetwork => 'Интернетті тексеріңіз';
  @override
  String get authErrorInvalidCode => 'Қате код';
  @override
  String get authErrorRateLimit =>
      'Тым көп әрекет. 5 минуттан кейін көріңіз.';
  @override
  String authLegal(String terms, String privacy) =>
      'Жалғастыра отырып, сіз $terms және $privacy қабылдайсыз.';

  @override
  String dashGreeting(String name) => 'Сәлем, $name';
  @override
  String get dashPeriodDay => 'Бүгін';
  @override
  String get dashPeriodWeek => 'Апта';
  @override
  String get dashPeriodMonth => 'Ай';
  @override
  String dashDeltaUp(int percent) => 'Өткен аптадан $percent% көп';
  @override
  String dashDeltaDown(int percent) => 'Өткен аптадан $percent% аз';
  @override
  String get dashBudgetTitle => 'Айлық бюджет';
  @override
  String dashBudgetDaysLeft(int days) => '$days күн қалды';

  @override
  String dashBudgetOver(String amount) => 'Бюджеттен тыс: $amount';
  @override
  String get dashRecent => 'Соңғы операциялар';
  @override
  String get dashSeeAll => 'Барлығы';
  @override
  String get dashEmptyTitle => 'Шығындар әлі жоқ';
  @override
  String get dashEmptyCta => 'Алғашқы шығынды қосу';
  @override
  String get dashFab => 'Қосу';
  @override
  String get dashOfflineBanner => 'Офлайн. Өзгерістер сақталады.';

  @override
  String get qaExpenseTitle => 'Шығын';
  @override
  String get qaIncomeTitle => 'Кіріс';
  @override
  String get qaTransferTitle => 'Аударым';
  @override
  String get qaAmountRequired => 'Соманы енгізіңіз';
  @override
  String get qaDetails => 'Толығырақ';
  @override
  String get qaNotePlaceholder => 'Ескертпе (міндетті емес)';
  @override
  String get qaDateToday => 'Бүгін';
  @override
  String qaSavedExpense(String amount) => 'Шығын $amount қосылды';
  @override
  String qaSavedIncome(String amount) => 'Кіріс $amount қосылды';
  @override
  String get qaSaveErrorOffline => 'Сақталмады. Кезекте.';
  @override
  String qaLimitNear(String spent, String budget) =>
      'Лимит жақын: $spent / $budget';
  @override
  String qaLimitExceedTitle(String amount) =>
      'Лимиттен $amount асып кетесіз';
  @override
  String get qaLimitExceedSave => 'Сонда да жазу';
  @override
  String get qaLimitExceedAdjust => 'Соманы өзгерту';
  @override
  String get qaIncomeRecurringHint => 'Тұрақты етесіз бе?';
  @override
  String qaIncomeProgress(String current, String expected) =>
      '$expected ішінен $current';

  @override
  String get txFieldAmount => 'Сома';
  @override
  String get txFieldCategory => 'Санат';
  @override
  String get txFieldAccount => 'Шот';
  @override
  String get txFieldDate => 'Күн';
  @override
  String get txFieldTime => 'Уақыт';
  @override
  String get txFieldNote => 'Ескертпе';
  @override
  String get txFieldTags => 'Тегтер';
  @override
  String get txFieldReceipt => 'Чек';
  @override
  String get txFieldLocation => 'Орын';
  @override
  String get txFieldRepeat => 'Қайталау';
  @override
  String get txFieldExcludeBudget => 'Бюджетке кірмесін';
  @override
  String get txTitleNewExpense => 'Шығын';
  @override
  String get txTitleEditExpense => 'Шығынды өзгерту';
  @override
  String get txUnsavedTitle => 'Өзгерістерді болдырмайсыз ба?';
  @override
  String get txUnsavedDiscard => 'Болдырмау';
  @override
  String get txUnsavedKeep => 'Жалғастыру';
  @override
  String get txDeleteConfirm => 'Операцияны жоясыз ба? Қайтарылмайды.';
  @override
  String get txDeleted => 'Жойылды';
  @override
  String get txUndo => 'Қайтару';
  @override
  String get txEdit => 'Өзгерту';
  @override
  String get txDuplicate => 'Көшіру';
  @override
  String get txShare => 'Бөлісу';
  @override
  String get txDelete => 'Жою';
  @override
  String get txSourceWidget => 'Виджет';
  @override
  String get txSourceManual => 'Қолмен';
  @override
  String get txSourceImport => 'Импорт';
  @override
  String get txSyncQueued => 'Синхрондау кезегінде';
  @override
  String get txNotFound => 'Операция табылмады';
  @override
  String txCount(int count) {
    if (count == 0) return 'Операция жоқ';
    return '$count операция';
  }

  @override
  String txDaysAgo(int days) {
    if (days == 0) return 'Бүгін';
    if (days == 1) return 'Кеше';
    return '$days күн бұрын';
  }

  @override
  String txItemsSelected(int count) => '$count элемент таңдалды';

  @override
  String get catFood => 'Тағам';
  @override
  String get catGroceries => 'Азық-түлік';
  @override
  String get catCafe => 'Кафе';
  @override
  String get catRestaurants => 'Мейрамханалар';
  @override
  String get catTransport => 'Көлік';
  @override
  String get catTaxi => 'Такси';
  @override
  String get catFuel => 'Жанармай';
  @override
  String get catShopping => 'Сатып алу';
  @override
  String get catClothing => 'Киім';
  @override
  String get catElectronics => 'Электроника';
  @override
  String get catEntertainment => 'Ойын-сауық';
  @override
  String get catSubscriptions => 'Жазылымдар';
  @override
  String get catBills => 'Шоттар';
  @override
  String get catUtilities => 'Коммуналды';
  @override
  String get catRent => 'Жалдау';
  @override
  String get catHealth => 'Денсаулық';
  @override
  String get catPharmacy => 'Дәріхана';
  @override
  String get catEducation => 'Білім';
  @override
  String get catTravel => 'Саяхат';
  @override
  String get catHome => 'Үй';
  @override
  String get catGifts => 'Сыйлықтар';
  @override
  String get catKids => 'Балалар';
  @override
  String get catPets => 'Үй жануарлары';
  @override
  String get catSports => 'Спорт';
  @override
  String get catBeauty => 'Сұлулық';
  @override
  String get catCharity => 'Қайырымдылық';
  @override
  String get catTaxes => 'Салықтар';
  @override
  String get catFees => 'Комиссиялар';
  @override
  String get catOther => 'Басқа';
  @override
  String get catIncSalary => 'Жалақы';
  @override
  String get catIncAdvance => 'Аванс';
  @override
  String get catIncFreelance => 'Фриланс';
  @override
  String get catIncGift => 'Сыйлық';
  @override
  String get catIncRefund => 'Қайтару';
  @override
  String get catIncCashback => 'Кэшбэк';
  @override
  String get catIncDividends => 'Дивидендтер';
  @override
  String get catIncInterest => 'Пайыздар';

  @override
  String get catScreenTitle => 'Санаттар';
  @override
  String get catTabExpense => 'Шығындар';
  @override
  String get catTabIncome => 'Кірістер';
  @override
  String get catSectionCustom => 'Менің санаттарым';
  @override
  String get catSectionSystem => 'Жүйелік';
  @override
  String get catAdd => 'Санат қосу';
  @override
  String get catFieldName => 'Атауы';
  @override
  String get catFieldIcon => 'Белгіше';
  @override
  String get catFieldColor => 'Түс';
  @override
  String get catFieldParent => 'Аталық санат';

  @override
  String get budgetsTitle => 'Бюджеттер';
  @override
  String get budgetsEmpty => 'Бюджет әлі жоқ';
  @override
  String get budgetsCreate => 'Бюджет жасау';
  @override
  String get budgetFieldName => 'Атауы';
  @override
  String get budgetFieldLimit => 'Лимит';
  @override
  String get budgetFieldPeriod => 'Кезең';
  @override
  String get budgetFieldCategory => 'Санат';
  @override
  String get budgetPeriodWeek => 'Апталық';
  @override
  String get budgetPeriodMonth => 'Айлық';
  @override
  String get budgetPeriodYear => 'Жылдық';
  @override
  String get budgetAlertAt80 => '80%-да ескерту';
  @override
  String budgetProgressLabel(String spent, String limit) =>
      '$limit ішінен $spent';

  @override
  String get anTitle => 'Аналитика';
  @override
  String get anPeriodDay => 'Күн';
  @override
  String get anPeriodWeek => 'Апта';
  @override
  String get anPeriodMonth => 'Ай';
  @override
  String get anPeriodYear => 'Жыл';
  @override
  String get anPeriodCustom => 'Өзгеше';
  @override
  String get anSumExpense => 'Шығындар';
  @override
  String get anSumIncome => 'Кірістер';
  @override
  String get anSumBalance => 'Теңгерім';
  @override
  String get anByCategory => 'Санаттар бойынша';
  @override
  String get anByWeek => 'Апталар бойынша';
  @override
  String get anByMonth => 'Айлар бойынша';
  @override
  String get anCashFlow => 'Ақша ағыны';
  @override
  String get anEmpty => 'Бұл кезеңде дерек жоқ';

  @override
  String get calTitle => 'Күнтізбе';
  @override
  String get calViewMonth => 'Ай';
  @override
  String get calViewWeek => 'Апта';
  @override
  String get calDayEmpty => 'Операция жоқ';
  @override
  String get calDayAdd => 'Осы күнге қосу';

  @override
  String get notifTitle => 'Хабарландырулар';
  @override
  String get notifEmpty => 'Барлығы оқылды';
  @override
  String get notifDailyReminderTitle => 'Бүгінгі шығындарды жазыңыз';
  @override
  String get notifDailyReminderBody =>
      '3 секунд алады. Қосу үшін түртіңіз.';
  @override
  String get notifWeeklyRecapTitle => 'Аптаңыз сандармен';
  @override
  String notifWeeklyRecapBody(String amount) =>
      'Осы аптада $amount жұмсадыңыз.';
  @override
  String get notifLimitWarningTitle => 'Бюджет ескертуі';
  @override
  String notifLimitWarningBody(String category, int percent) =>
      '$category санаты лимиттің $percent%-ына жетті.';
  @override
  String get notifInsightReadyTitle => 'Жаңа түсінік';
  @override
  String get notifInsightReadyBody =>
      'Толығырақ білу үшін FinNex-ті ашыңыз.';

  @override
  String get setTitle => 'Баптаулар';
  @override
  String get setProfile => 'Профиль';
  @override
  String get setAppearance => 'Көрініс';
  @override
  String get setTheme => 'Тақырып';
  @override
  String get setThemeSystem => 'Жүйелік';
  @override
  String get setThemeLight => 'Жарық';
  @override
  String get setThemeDark => 'Қараңғы';
  @override
  String get setLanguage => 'Тіл';
  @override
  String get setLanguageEn => 'English';
  @override
  String get setLanguageRu => 'Русский';
  @override
  String get setLanguageKk => 'Қазақша';
  @override
  String get setCurrency => 'Валюта';
  @override
  String get setSecurity => 'Қауіпсіздік';
  @override
  String get setBiometric => 'Биометрия арқылы кіру';
  @override
  String get setPin => 'PIN-код';
  @override
  String get setNotifications => 'Хабарландырулар';
  @override
  String get setNotifDaily => 'Күнделікті еске салу';
  @override
  String get setNotifWeekly => 'Апталық қорытынды';
  @override
  String get setNotifLimit => 'Бюджет ескертулері';
  @override
  String get setNotifInsights => 'Түсініктер';
  @override
  String get setData => 'Деректер';
  @override
  String get setExport => 'Деректерді экспорттау';
  @override
  String get setImport => 'Деректерді импорттау';
  @override
  String get setSync => 'Қазір синхрондау';
  @override
  String get setAbout => 'Қолданба туралы';
  @override
  String setVersion(String version) => 'Нұсқа $version';
  @override
  String get setSignOut => 'Шығу';
  @override
  String get setDeleteAccount => 'Аккаунтты жою';
  @override
  String get setDeleteAccountConfirm =>
      'Аккаунтты жоясыз ба? Барлық дерек өшіріледі.';

  @override
  String get errorNetwork => 'Желі қатесі. Қосылымды тексеріңіз.';
  @override
  String get errorServer => 'Бізде бірдеңе дұрыс емес.';
  @override
  String get errorValidation => 'Белгіленген өрістерді тексеріңіз.';
  @override
  String get errorSyncConflict =>
      'Синхрондау қайшылығы. Соңғы өзгерістер сақталды.';
  @override
  String get errorOffline =>
      'Сіз офлайнсыз. Өзгерістер жергілікті сақталды.';
  @override
  String get errorUnknown => 'Күтпеген қате';
}
