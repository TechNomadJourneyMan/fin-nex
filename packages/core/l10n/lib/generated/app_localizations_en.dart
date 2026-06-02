// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Pocket Flow';

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
  String get menuGoals => 'Goals';

  @override
  String get menuAchievements => 'Achievements';

  @override
  String get menuWorkspaces => 'Workspaces';

  @override
  String get menuSmsSandbox => 'SMS Sandbox';

  @override
  String get menuNotifications => 'Notifications';

  @override
  String get menuMore => 'More';

  @override
  String get splashLoadingLong => 'Loading your data…';

  @override
  String get splashLoadingError => 'Couldn\'t start the app';

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
  String get authTitle => 'Sign in to Pocket Flow';

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
  String authOtpSubtitle(String phone) {
    return 'We sent an SMS to $phone.';
  }

  @override
  String authOtpResendIn(String time) {
    return 'Resend in $time';
  }

  @override
  String get authOtpResend => 'Resend code';

  @override
  String get authOtpHelp => 'Didn\'t get the code?';

  @override
  String get authBiometricPrompt => 'Use biometrics to sign in';

  @override
  String get authBiometricReason => 'Confirm it\'s you to open Pocket Flow';

  @override
  String get authErrorNetwork => 'Check your connection';

  @override
  String get authErrorInvalidCode => 'Wrong code';

  @override
  String get authErrorRateLimit => 'Too many attempts. Try again in 5 minutes.';

  @override
  String authLegal(String terms, String privacy) {
    return 'By continuing, you agree to $terms and $privacy.';
  }

  @override
  String dashGreeting(String name) {
    return 'Hi, $name';
  }

  @override
  String get dashPeriodDay => 'Today';

  @override
  String get dashPeriodWeek => 'Week';

  @override
  String get dashPeriodMonth => 'Month';

  @override
  String dashDeltaUp(int percent) {
    return '+$percent% vs last week';
  }

  @override
  String dashDeltaDown(int percent) {
    return '−$percent% vs last week';
  }

  @override
  String get dashBudgetTitle => 'Monthly budget';

  @override
  String dashBudgetDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days left',
      one: '1 day left',
    );
    return '$_temp0';
  }

  @override
  String dashBudgetOver(String amount) {
    return 'Over budget: $amount';
  }

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
  String qaSavedExpense(String amount) {
    return 'Expense $amount added';
  }

  @override
  String qaSavedIncome(String amount) {
    return 'Income $amount added';
  }

  @override
  String get qaSaveErrorOffline => 'Couldn\'t save. Queued.';

  @override
  String qaLimitNear(String spent, String budget) {
    return 'Near limit: $spent / $budget';
  }

  @override
  String qaLimitExceedTitle(String amount) {
    return 'This exceeds your limit by $amount';
  }

  @override
  String get qaLimitExceedSave => 'Save anyway';

  @override
  String get qaLimitExceedAdjust => 'Change amount';

  @override
  String get qaIncomeRecurringHint => 'Make this recurring?';

  @override
  String qaIncomeProgress(String current, String expected) {
    return '$current of $expected';
  }

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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions',
      one: '1 transaction',
      zero: 'No transactions',
    );
    return '$_temp0';
  }

  @override
  String txDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days ago',
      one: 'Yesterday',
      zero: 'Today',
    );
    return '$_temp0';
  }

  @override
  String txItemsSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items selected',
      one: '1 item selected',
    );
    return '$_temp0';
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
  String budgetProgressLabel(String spent, String limit) {
    return '$spent of $limit';
  }

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
  String get calPrevMonth => 'Previous month';

  @override
  String get calNextMonth => 'Next month';

  @override
  String get calLegendLow => 'Low';

  @override
  String get calLegendHigh => 'High';

  @override
  String get calLegendSemantic => 'Spending intensity scale from low to high.';

  @override
  String calHeatmapSemantic(String month, String total) {
    return 'Spending calendar for $month. Total spent $total. Tap a highlighted day for details.';
  }

  @override
  String get notifTitle => 'Notifications';

  @override
  String get notifEmpty => 'All caught up';

  @override
  String get notifDailyReminderTitle => 'Log today\'s expenses';

  @override
  String get notifDailyReminderBody => 'Takes 3 seconds. Tap to add.';

  @override
  String get notifWeeklyRecapTitle => 'Your week in numbers';

  @override
  String notifWeeklyRecapBody(String amount) {
    return 'You spent $amount this week.';
  }

  @override
  String get notifLimitWarningTitle => 'Budget alert';

  @override
  String notifLimitWarningBody(String category, int percent) {
    return '$category is at $percent% of its limit.';
  }

  @override
  String get notifInsightReadyTitle => 'New insight';

  @override
  String get notifInsightReadyBody => 'Open Pocket Flow to see what changed.';

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
  String get setAccessibility => 'Accessibility';

  @override
  String get setHighContrast => 'High contrast mode';

  @override
  String get setHighContrastDesc =>
      'Pure black-and-white surfaces with a saturated brand color.';

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
  String setVersion(String version) {
    return 'Version $version';
  }

  @override
  String get setSignOut => 'Sign out';

  @override
  String get setDeleteAccount => 'Delete account';

  @override
  String get setDeleteAccountConfirm =>
      'Delete your account? All data will be erased.';

  @override
  String get settings_section_feedback => 'Sound & Haptics';

  @override
  String get feedback_haptics => 'Haptic feedback';

  @override
  String get feedback_sound => 'Sound effects';

  @override
  String get feedback_preview => 'Preview';

  @override
  String get subsTitle => 'Subscriptions';

  @override
  String get subsDetailTitle => 'Subscription';

  @override
  String get subsEmptyTitle => 'No subscriptions yet';

  @override
  String get subsEmptyBody =>
      'We\'ll show recurring charges here as we detect them.';

  @override
  String get subsNotFound => 'Subscription not found.';

  @override
  String subsMonthlyTotalLabel(String month) {
    return 'Total on subscriptions in $month';
  }

  @override
  String subsActiveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active subscriptions',
      one: '1 active subscription',
      zero: 'No active subscriptions',
    );
    return '$_temp0';
  }

  @override
  String subsNextBilling(String date) {
    return 'Next charge $date';
  }

  @override
  String get subsPeriodWeekly => 'Weekly';

  @override
  String get subsPeriodMonthly => 'Monthly';

  @override
  String get subsPeriodQuarterly => 'Quarterly';

  @override
  String get subsPeriodYearly => 'Yearly';

  @override
  String get subsCancelledBadge => 'Cancelled';

  @override
  String get subsSourceTransactions => 'Source transactions';

  @override
  String get subsNoSourceTransactions => 'No linked transactions yet.';

  @override
  String get subsHowToUnsubscribe => 'How to unsubscribe';

  @override
  String subsUnsubscribeHint(String merchant) {
    return 'To cancel $merchant, open the merchant\'s account or billing settings and stop the recurring payment.';
  }

  @override
  String get subsUnsubscribeNoLink => 'No cancellation link available yet.';

  @override
  String get subsMarkCancelled => 'Mark as cancelled';

  @override
  String get subsAlreadyCancelled => 'Already cancelled';

  @override
  String subsMarkedCancelled(String merchant) {
    return 'Marked $merchant as cancelled';
  }

  @override
  String get errorNetwork => 'Network error. Check your connection.';

  @override
  String get errorServer => 'Something went wrong on our end.';

  @override
  String get errorValidation => 'Please check the highlighted fields.';

  @override
  String get errorSyncConflict => 'Sync conflict. We kept your latest changes.';

  @override
  String get errorOffline => 'You\'re offline. Changes are saved locally.';

  @override
  String get errorUnknown => 'Unexpected error';

  @override
  String get filterIncome => 'Income';

  @override
  String get filterExpense => 'Expense';

  @override
  String get filterCategory => 'Category';

  @override
  String get filterDateRange => 'Date range';

  @override
  String get filterNothingMatches => 'Nothing matches';

  @override
  String get filterNothingMatchesBody =>
      'Try a different search or clear your filters.';

  @override
  String get filterClear => 'Clear filters';

  @override
  String get txRecategorize => 'Recategorize';

  @override
  String get txSplit => 'Split';

  @override
  String get txSplitTitle => 'Split into N parts';

  @override
  String get txSplitParts => 'Parts';

  @override
  String get cmdPaletteHint => 'Type a command…';

  @override
  String get cmdAddExpense => 'Add expense';

  @override
  String get cmdAddIncome => 'Add income';

  @override
  String get cmdSearchTransactions => 'Search transactions';

  @override
  String get cmdOpenDashboard => 'Open Dashboard';

  @override
  String get cmdOpenTransactions => 'Open Transactions';

  @override
  String get cmdOpenAnalytics => 'Open Analytics';

  @override
  String get cmdOpenSettings => 'Open Settings';

  @override
  String get cmdToggleTheme => 'Toggle theme (light/dark)';

  @override
  String get cmdSwitchLanguage => 'Switch language (en/ru/kk)';

  @override
  String get cmdOpenCalendar => 'Open spending calendar';

  @override
  String get importPreviewTitle => 'Import preview';

  @override
  String get importColumnDate => 'Date';

  @override
  String get importColumnAmount => 'Amount';

  @override
  String get importColumnMerchant => 'Merchant';

  @override
  String get importColumnCategory => 'Category';

  @override
  String importConfirm(int count) {
    return 'Import $count rows';
  }

  @override
  String importDone(int count) {
    return 'Imported $count transactions';
  }

  @override
  String get setCalendar => 'Calendar';

  @override
  String get calConnect => 'Connect calendar';

  @override
  String get calConnected => 'Connected';

  @override
  String get calNotConnected => 'Not connected';

  @override
  String get calConnectDesc =>
      'Add payment and subscription reminders to your calendar.';

  @override
  String get calChooseCalendar => 'Choose a calendar';

  @override
  String get calPermissionDenied => 'Calendar access was denied.';

  @override
  String calSelected(String name) {
    return 'Using $name';
  }

  @override
  String get calSubscriptionReminders => 'Subscription reminders';

  @override
  String get calSubscriptionRemindersDesc =>
      'Add a calendar event before each subscription renews.';

  @override
  String get calBudgetReminders => 'Budget reminders';

  @override
  String get calBudgetRemindersDesc =>
      'Add a calendar event when a budget period is about to end.';

  @override
  String get subsAddToCalendar => 'Add to calendar';

  @override
  String get subsReminderAdded => 'Reminder added';

  @override
  String budgetReminderTitle(String name, String date) {
    return 'Budget \'$name\' ends $date';
  }
}
