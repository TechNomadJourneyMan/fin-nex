import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_kk.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('kk'),
    Locale('ru')
  ];

  /// Application name. Do not translate.
  ///
  /// In en, this message translates to:
  /// **'Pocket Flow'**
  String get appName;

  /// Generic cancel button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Generic save button.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// Generic delete button.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// Generic edit button.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// Generic search action / placeholder.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearch;

  /// Retry button after an error.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// Generic confirmation.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// Generic affirmative.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get commonYes;

  /// Generic negative.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get commonNo;

  /// Generic done action.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// Generic close action.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// Generic next button.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// Generic back action.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// Generic continue button.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// Generic loading status.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get commonLoading;

  /// Generic 'see all' label.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get commonAll;

  /// Generic 'none' option.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get commonNone;

  /// Marks an optional field.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get commonOptional;

  /// Marks a required field.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get commonRequired;

  /// BottomNav: Home tab. Tight: keep under 10 chars.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// BottomNav: Analytics tab.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get navAnalytics;

  /// BottomNav: Calendar tab.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get navCalendar;

  /// BottomNav: Settings tab.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Optional navigation label.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get navTransactions;

  /// Optional navigation label.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get navBudgets;

  /// Overflow menu entry: goals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get menuGoals;

  /// Overflow menu entry: achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get menuAchievements;

  /// Overflow menu entry: workspaces.
  ///
  /// In en, this message translates to:
  /// **'Workspaces'**
  String get menuWorkspaces;

  /// Overflow menu entry: SMS sandbox developer tool.
  ///
  /// In en, this message translates to:
  /// **'SMS Sandbox'**
  String get menuSmsSandbox;

  /// Overflow menu entry: notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get menuNotifications;

  /// Tooltip for the overflow menu trigger.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get menuMore;

  /// Shown after >1.5s of splash init.
  ///
  /// In en, this message translates to:
  /// **'Loading your data…'**
  String get splashLoadingLong;

  /// Splash init failure title.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t start the app'**
  String get splashLoadingError;

  /// Onboarding skip button.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onbSkip;

  /// Onboarding next button.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onbNext;

  /// Final onboarding CTA.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onbStart;

  /// Onboarding secondary CTA to sign in.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get onbHaveAccount;

  /// Onboarding page 1 headline.
  ///
  /// In en, this message translates to:
  /// **'Track in 3 seconds'**
  String get onbP1Title;

  /// Onboarding page 1 body.
  ///
  /// In en, this message translates to:
  /// **'Log expenses in one tap. No clunky forms.'**
  String get onbP1Body;

  /// Onboarding page 2 headline.
  ///
  /// In en, this message translates to:
  /// **'Categories your way'**
  String get onbP2Title;

  /// Onboarding page 2 body.
  ///
  /// In en, this message translates to:
  /// **'Ready-made KZ categories. Add your own.'**
  String get onbP2Body;

  /// Onboarding page 3 headline.
  ///
  /// In en, this message translates to:
  /// **'One tap, expense logged'**
  String get onbP3Title;

  /// Onboarding page 3 body.
  ///
  /// In en, this message translates to:
  /// **'Widgets for iOS and Android. No need to open the app.'**
  String get onbP3Body;

  /// Onboarding page 4 headline.
  ///
  /// In en, this message translates to:
  /// **'Ready to begin?'**
  String get onbP4Title;

  /// Onboarding page 4 body.
  ///
  /// In en, this message translates to:
  /// **'Pick language and currency — 10 seconds.'**
  String get onbP4Body;

  /// Auth landing screen title.
  ///
  /// In en, this message translates to:
  /// **'Sign in to Pocket Flow'**
  String get authTitle;

  /// Auth landing screen subtitle.
  ///
  /// In en, this message translates to:
  /// **'No password. Just your phone.'**
  String get authSubtitle;

  /// Send OTP CTA.
  ///
  /// In en, this message translates to:
  /// **'Get code'**
  String get authCtaSendCode;

  /// Divider between phone and social login.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get authOr;

  /// Apple sign-in button.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get authContinueApple;

  /// Google sign-in button.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueGoogle;

  /// Email sign-in button.
  ///
  /// In en, this message translates to:
  /// **'Continue with email'**
  String get authContinueEmail;

  /// Email sign-up button.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authSignUp;

  /// OTP screen title.
  ///
  /// In en, this message translates to:
  /// **'Enter code'**
  String get authOtpTitle;

  /// OTP screen subtitle with masked phone.
  ///
  /// In en, this message translates to:
  /// **'We sent an SMS to {phone}.'**
  String authOtpSubtitle(String phone);

  /// Resend countdown.
  ///
  /// In en, this message translates to:
  /// **'Resend in {time}'**
  String authOtpResendIn(String time);

  /// Resend OTP button after countdown.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get authOtpResend;

  /// Help link below OTP boxes.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t get the code?'**
  String get authOtpHelp;

  /// Biometric unlock prompt.
  ///
  /// In en, this message translates to:
  /// **'Use biometrics to sign in'**
  String get authBiometricPrompt;

  /// Reason shown by the OS biometric dialog.
  ///
  /// In en, this message translates to:
  /// **'Confirm it\'s you to open Pocket Flow'**
  String get authBiometricReason;

  /// Network failure during auth.
  ///
  /// In en, this message translates to:
  /// **'Check your connection'**
  String get authErrorNetwork;

  /// Invalid OTP entered.
  ///
  /// In en, this message translates to:
  /// **'Wrong code'**
  String get authErrorInvalidCode;

  /// OTP rate-limit dialog.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in 5 minutes.'**
  String get authErrorRateLimit;

  /// Legal text below CTA. {terms} and {privacy} are clickable links.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to {terms} and {privacy}.'**
  String authLegal(String terms, String privacy);

  /// Dashboard greeting. Tight: keep total under 14 chars on sm.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String dashGreeting(String name);

  /// Dashboard period: day.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dashPeriodDay;

  /// Dashboard period: week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get dashPeriodWeek;

  /// Dashboard period: month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get dashPeriodMonth;

  /// Spend delta up vs previous period.
  ///
  /// In en, this message translates to:
  /// **'+{percent}% vs last week'**
  String dashDeltaUp(int percent);

  /// Spend delta down vs previous period.
  ///
  /// In en, this message translates to:
  /// **'−{percent}% vs last week'**
  String dashDeltaDown(int percent);

  /// Dashboard budget card title.
  ///
  /// In en, this message translates to:
  /// **'Monthly budget'**
  String get dashBudgetTitle;

  /// Days remaining in the current budget period (ICU plural).
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day left} other{{days} days left}}'**
  String dashBudgetDaysLeft(int days);

  /// Shown when monthly budget exceeded.
  ///
  /// In en, this message translates to:
  /// **'Over budget: {amount}'**
  String dashBudgetOver(String amount);

  /// Section header for last transactions.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get dashRecent;

  /// Link to all transactions.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get dashSeeAll;

  /// Dashboard empty state title.
  ///
  /// In en, this message translates to:
  /// **'No expenses yet'**
  String get dashEmptyTitle;

  /// Dashboard empty state CTA.
  ///
  /// In en, this message translates to:
  /// **'Add your first expense'**
  String get dashEmptyCta;

  /// Extended FAB label on dashboard.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get dashFab;

  /// Sticky offline banner under AppBar.
  ///
  /// In en, this message translates to:
  /// **'Offline. Changes will sync.'**
  String get dashOfflineBanner;

  /// Quick-add expense sheet title.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get qaExpenseTitle;

  /// Quick-add income sheet title.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get qaIncomeTitle;

  /// Quick-add transfer sheet title.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get qaTransferTitle;

  /// Inline error when amount empty.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get qaAmountRequired;

  /// Collapsible 'details' label.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get qaDetails;

  /// Placeholder for the note field.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get qaNotePlaceholder;

  /// Default date chip label.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get qaDateToday;

  /// Toast after expense saved.
  ///
  /// In en, this message translates to:
  /// **'Expense {amount} added'**
  String qaSavedExpense(String amount);

  /// Toast after income saved.
  ///
  /// In en, this message translates to:
  /// **'Income {amount} added'**
  String qaSavedIncome(String amount);

  /// Inline error when save falls into outbox.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save. Queued.'**
  String get qaSaveErrorOffline;

  /// Inline warning at >=80% of budget.
  ///
  /// In en, this message translates to:
  /// **'Near limit: {spent} / {budget}'**
  String qaLimitNear(String spent, String budget);

  /// Confirmation dialog title when over budget.
  ///
  /// In en, this message translates to:
  /// **'This exceeds your limit by {amount}'**
  String qaLimitExceedTitle(String amount);

  /// Confirm over-budget save.
  ///
  /// In en, this message translates to:
  /// **'Save anyway'**
  String get qaLimitExceedSave;

  /// Reject over-budget save.
  ///
  /// In en, this message translates to:
  /// **'Change amount'**
  String get qaLimitExceedAdjust;

  /// Suggestion to convert to recurring income.
  ///
  /// In en, this message translates to:
  /// **'Make this recurring?'**
  String get qaIncomeRecurringHint;

  /// Progress vs expected monthly income.
  ///
  /// In en, this message translates to:
  /// **'{current} of {expected}'**
  String qaIncomeProgress(String current, String expected);

  /// Transaction field label.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get txFieldAmount;

  /// Transaction field label.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get txFieldCategory;

  /// Transaction field label.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get txFieldAccount;

  /// Transaction field label.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get txFieldDate;

  /// Transaction field label.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get txFieldTime;

  /// Transaction field label.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get txFieldNote;

  /// Transaction field label.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get txFieldTags;

  /// Transaction field label.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get txFieldReceipt;

  /// Transaction field label.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get txFieldLocation;

  /// Transaction recurring field label.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get txFieldRepeat;

  /// Toggle to exclude tx from budget totals.
  ///
  /// In en, this message translates to:
  /// **'Exclude from budget'**
  String get txFieldExcludeBudget;

  /// Full add-expense screen title (new).
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get txTitleNewExpense;

  /// Full add-expense screen title (edit).
  ///
  /// In en, this message translates to:
  /// **'Edit expense'**
  String get txTitleEditExpense;

  /// Confirm losing edits.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get txUnsavedTitle;

  /// Confirm discard edits.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get txUnsavedDiscard;

  /// Stay in editor.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get txUnsavedKeep;

  /// Hard delete confirmation.
  ///
  /// In en, this message translates to:
  /// **'Delete this transaction? Cannot be undone.'**
  String get txDeleteConfirm;

  /// Toast after delete.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get txDeleted;

  /// Undo action label.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get txUndo;

  /// Tx menu action.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get txEdit;

  /// Tx menu action.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get txDuplicate;

  /// Tx menu action.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get txShare;

  /// Tx menu action.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get txDelete;

  /// Source of tx: home screen widget.
  ///
  /// In en, this message translates to:
  /// **'Widget'**
  String get txSourceWidget;

  /// Source of tx: manual entry.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get txSourceManual;

  /// Source of tx: bulk import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get txSourceImport;

  /// Badge for un-synced tx.
  ///
  /// In en, this message translates to:
  /// **'Queued for sync'**
  String get txSyncQueued;

  /// Empty state when tx id missing.
  ///
  /// In en, this message translates to:
  /// **'Transaction not found'**
  String get txNotFound;

  /// Plural transactions count (ICU).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No transactions} =1{1 transaction} other{{count} transactions}}'**
  String txCount(int count);

  /// Relative day phrase (ICU plural).
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{Today} =1{Yesterday} other{{days} days ago}}'**
  String txDaysAgo(int days);

  /// Bulk-action selection count (ICU plural).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item selected} other{{count} items selected}}'**
  String txItemsSelected(int count);

  /// System category.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get catFood;

  /// System category.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get catGroceries;

  /// System category.
  ///
  /// In en, this message translates to:
  /// **'Café'**
  String get catCafe;

  /// System category.
  ///
  /// In en, this message translates to:
  /// **'Restaurants'**
  String get catRestaurants;

  /// System category.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get catTransport;

  /// System category.
  ///
  /// In en, this message translates to:
  /// **'Taxi'**
  String get catTaxi;

  /// System category.
  ///
  /// In en, this message translates to:
  /// **'Fuel'**
  String get catFuel;

  /// System category.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get catShopping;

  /// System category.
  ///
  /// In en, this message translates to:
  /// **'Clothing'**
  String get catClothing;

  /// System category.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get catElectronics;

  /// System category.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get catEntertainment;

  /// System category.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get catSubscriptions;

  /// System category.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get catBills;

  /// System category.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get catUtilities;

  /// System category.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get catRent;

  /// System category.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get catHealth;

  /// System category.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy'**
  String get catPharmacy;

  /// System category.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get catEducation;

  /// System category.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get catTravel;

  /// System category (household).
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get catHome;

  /// System category.
  ///
  /// In en, this message translates to:
  /// **'Gifts'**
  String get catGifts;

  /// System category.
  ///
  /// In en, this message translates to:
  /// **'Kids'**
  String get catKids;

  /// System category.
  ///
  /// In en, this message translates to:
  /// **'Pets'**
  String get catPets;

  /// System category.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get catSports;

  /// System category.
  ///
  /// In en, this message translates to:
  /// **'Beauty'**
  String get catBeauty;

  /// System category.
  ///
  /// In en, this message translates to:
  /// **'Charity'**
  String get catCharity;

  /// System category.
  ///
  /// In en, this message translates to:
  /// **'Taxes'**
  String get catTaxes;

  /// System category.
  ///
  /// In en, this message translates to:
  /// **'Fees'**
  String get catFees;

  /// System category fallback.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get catOther;

  /// Income category.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get catIncSalary;

  /// Income category.
  ///
  /// In en, this message translates to:
  /// **'Advance'**
  String get catIncAdvance;

  /// Income category.
  ///
  /// In en, this message translates to:
  /// **'Freelance'**
  String get catIncFreelance;

  /// Income category.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get catIncGift;

  /// Income category.
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get catIncRefund;

  /// Income category.
  ///
  /// In en, this message translates to:
  /// **'Cashback'**
  String get catIncCashback;

  /// Income category.
  ///
  /// In en, this message translates to:
  /// **'Dividends'**
  String get catIncDividends;

  /// Income category.
  ///
  /// In en, this message translates to:
  /// **'Interest'**
  String get catIncInterest;

  /// Categories management screen title.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get catScreenTitle;

  /// Categories tab.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get catTabExpense;

  /// Categories tab.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get catTabIncome;

  /// User-created categories section.
  ///
  /// In en, this message translates to:
  /// **'My categories'**
  String get catSectionCustom;

  /// Built-in categories section.
  ///
  /// In en, this message translates to:
  /// **'Built-in'**
  String get catSectionSystem;

  /// Add custom category CTA.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get catAdd;

  /// Custom category name field.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get catFieldName;

  /// Custom category icon picker.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get catFieldIcon;

  /// Custom category color picker.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get catFieldColor;

  /// Optional parent grouping.
  ///
  /// In en, this message translates to:
  /// **'Parent category'**
  String get catFieldParent;

  /// Budgets screen title.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgetsTitle;

  /// Empty budgets state.
  ///
  /// In en, this message translates to:
  /// **'No budgets yet'**
  String get budgetsEmpty;

  /// Create budget CTA.
  ///
  /// In en, this message translates to:
  /// **'Create budget'**
  String get budgetsCreate;

  /// Budget name field.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get budgetFieldName;

  /// Budget amount limit field.
  ///
  /// In en, this message translates to:
  /// **'Limit'**
  String get budgetFieldLimit;

  /// Budget period field.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get budgetFieldPeriod;

  /// Budget scope: category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get budgetFieldCategory;

  /// Budget period option.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get budgetPeriodWeek;

  /// Budget period option.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get budgetPeriodMonth;

  /// Budget period option.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get budgetPeriodYear;

  /// Toggle for limit warning notification.
  ///
  /// In en, this message translates to:
  /// **'Alert me at 80%'**
  String get budgetAlertAt80;

  /// Progress label on budget card.
  ///
  /// In en, this message translates to:
  /// **'{spent} of {limit}'**
  String budgetProgressLabel(String spent, String limit);

  /// Analytics screen title.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get anTitle;

  /// Analytics period selector.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get anPeriodDay;

  /// Analytics period selector.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get anPeriodWeek;

  /// Analytics period selector.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get anPeriodMonth;

  /// Analytics period selector.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get anPeriodYear;

  /// Analytics period selector.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get anPeriodCustom;

  /// Analytics summary block.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get anSumExpense;

  /// Analytics summary block.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get anSumIncome;

  /// Analytics summary block.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get anSumBalance;

  /// Analytics breakdown header.
  ///
  /// In en, this message translates to:
  /// **'By category'**
  String get anByCategory;

  /// Analytics breakdown header.
  ///
  /// In en, this message translates to:
  /// **'By week'**
  String get anByWeek;

  /// Analytics breakdown header.
  ///
  /// In en, this message translates to:
  /// **'By month'**
  String get anByMonth;

  /// Analytics breakdown header.
  ///
  /// In en, this message translates to:
  /// **'Cash flow'**
  String get anCashFlow;

  /// Empty analytics state.
  ///
  /// In en, this message translates to:
  /// **'No data for this period'**
  String get anEmpty;

  /// Calendar screen title.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calTitle;

  /// Calendar view toggle.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get calViewMonth;

  /// Calendar view toggle.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get calViewWeek;

  /// Empty state for selected day.
  ///
  /// In en, this message translates to:
  /// **'No transactions'**
  String get calDayEmpty;

  /// Day detail CTA.
  ///
  /// In en, this message translates to:
  /// **'Add for this day'**
  String get calDayAdd;

  /// Calendar: page to the previous month.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get calPrevMonth;

  /// Calendar: page to the next month.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get calNextMonth;

  /// Heatmap legend: lowest-spend end of the scale.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get calLegendLow;

  /// Heatmap legend: highest-spend end of the scale.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get calLegendHigh;

  /// Screen-reader label for the calendar heatmap legend.
  ///
  /// In en, this message translates to:
  /// **'Spending intensity scale from low to high.'**
  String get calLegendSemantic;

  /// Screen-reader description of the spending heatmap.
  ///
  /// In en, this message translates to:
  /// **'Spending calendar for {month}. Total spent {total}. Tap a highlighted day for details.'**
  String calHeatmapSemantic(String month, String total);

  /// Notifications screen title.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifTitle;

  /// Empty notifications state.
  ///
  /// In en, this message translates to:
  /// **'All caught up'**
  String get notifEmpty;

  /// Daily reminder push title.
  ///
  /// In en, this message translates to:
  /// **'Log today\'s expenses'**
  String get notifDailyReminderTitle;

  /// Daily reminder push body.
  ///
  /// In en, this message translates to:
  /// **'Takes 3 seconds. Tap to add.'**
  String get notifDailyReminderBody;

  /// Weekly recap push title.
  ///
  /// In en, this message translates to:
  /// **'Your week in numbers'**
  String get notifWeeklyRecapTitle;

  /// Weekly recap push body.
  ///
  /// In en, this message translates to:
  /// **'You spent {amount} this week.'**
  String notifWeeklyRecapBody(String amount);

  /// Limit warning push title.
  ///
  /// In en, this message translates to:
  /// **'Budget alert'**
  String get notifLimitWarningTitle;

  /// Limit warning push body.
  ///
  /// In en, this message translates to:
  /// **'{category} is at {percent}% of its limit.'**
  String notifLimitWarningBody(String category, int percent);

  /// Insight ready push title.
  ///
  /// In en, this message translates to:
  /// **'New insight'**
  String get notifInsightReadyTitle;

  /// Insight ready push body.
  ///
  /// In en, this message translates to:
  /// **'Open Pocket Flow to see what changed.'**
  String get notifInsightReadyBody;

  /// Settings screen title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get setTitle;

  /// Settings section.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get setProfile;

  /// Settings section.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get setAppearance;

  /// Theme picker label.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get setTheme;

  /// Theme option.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get setThemeSystem;

  /// Theme option.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get setThemeLight;

  /// Theme option.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get setThemeDark;

  /// Settings section grouping accessibility toggles.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get setAccessibility;

  /// Accessibility toggle for the high-contrast theme.
  ///
  /// In en, this message translates to:
  /// **'High contrast mode'**
  String get setHighContrast;

  /// Subtitle for the high-contrast toggle.
  ///
  /// In en, this message translates to:
  /// **'Pure black-and-white surfaces with a saturated brand color.'**
  String get setHighContrastDesc;

  /// Language picker label.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get setLanguage;

  /// Language option.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get setLanguageEn;

  /// Language option (Russian endonym).
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get setLanguageRu;

  /// Language option (Kazakh endonym).
  ///
  /// In en, this message translates to:
  /// **'Қазақша'**
  String get setLanguageKk;

  /// Currency picker label.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get setCurrency;

  /// Settings section.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get setSecurity;

  /// Biometric toggle.
  ///
  /// In en, this message translates to:
  /// **'Unlock with biometrics'**
  String get setBiometric;

  /// PIN setting.
  ///
  /// In en, this message translates to:
  /// **'App PIN'**
  String get setPin;

  /// Settings section.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get setNotifications;

  /// Notification toggle.
  ///
  /// In en, this message translates to:
  /// **'Daily reminder'**
  String get setNotifDaily;

  /// Notification toggle.
  ///
  /// In en, this message translates to:
  /// **'Weekly recap'**
  String get setNotifWeekly;

  /// Notification toggle.
  ///
  /// In en, this message translates to:
  /// **'Budget alerts'**
  String get setNotifLimit;

  /// Notification toggle.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get setNotifInsights;

  /// Settings section.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get setData;

  /// Export action.
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get setExport;

  /// Import action.
  ///
  /// In en, this message translates to:
  /// **'Import data'**
  String get setImport;

  /// Force sync action.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get setSync;

  /// Settings section.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get setAbout;

  /// App version row.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String setVersion(String version);

  /// Sign-out action.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get setSignOut;

  /// Account deletion action.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get setDeleteAccount;

  /// Account deletion confirm.
  ///
  /// In en, this message translates to:
  /// **'Delete your account? All data will be erased.'**
  String get setDeleteAccountConfirm;

  /// Settings section header for sound + haptic toggles.
  ///
  /// In en, this message translates to:
  /// **'Sound & Haptics'**
  String get settings_section_feedback;

  /// Toggle label: enable vibration on actions.
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback'**
  String get feedback_haptics;

  /// Toggle label: enable sound effects on actions.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get feedback_sound;

  /// Button: play a sample achievement cue.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get feedback_preview;

  /// Subscriptions manager screen title.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get subsTitle;

  /// Subscription detail screen title.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subsDetailTitle;

  /// Empty-state title on the subscriptions manager.
  ///
  /// In en, this message translates to:
  /// **'No subscriptions yet'**
  String get subsEmptyTitle;

  /// Empty-state body on the subscriptions manager.
  ///
  /// In en, this message translates to:
  /// **'We\'ll show recurring charges here as we detect them.'**
  String get subsEmptyBody;

  /// Shown when a detail page has no matching subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription not found.'**
  String get subsNotFound;

  /// Label above the monthly subscriptions total.
  ///
  /// In en, this message translates to:
  /// **'Total on subscriptions in {month}'**
  String subsMonthlyTotalLabel(String month);

  /// Active subscription count (ICU plural).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No active subscriptions} =1{1 active subscription} other{{count} active subscriptions}}'**
  String subsActiveCount(int count);

  /// Next billing date row.
  ///
  /// In en, this message translates to:
  /// **'Next charge {date}'**
  String subsNextBilling(String date);

  /// Billing period label.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get subsPeriodWeekly;

  /// Billing period label.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get subsPeriodMonthly;

  /// Billing period label.
  ///
  /// In en, this message translates to:
  /// **'Quarterly'**
  String get subsPeriodQuarterly;

  /// Billing period label.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get subsPeriodYearly;

  /// Badge on a cancelled subscription card.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get subsCancelledBadge;

  /// Detail section heading.
  ///
  /// In en, this message translates to:
  /// **'Source transactions'**
  String get subsSourceTransactions;

  /// Shown when no source transactions are linked.
  ///
  /// In en, this message translates to:
  /// **'No linked transactions yet.'**
  String get subsNoSourceTransactions;

  /// Action that opens the unsubscribe hint sheet.
  ///
  /// In en, this message translates to:
  /// **'How to unsubscribe'**
  String get subsHowToUnsubscribe;

  /// Unsubscribe hint body.
  ///
  /// In en, this message translates to:
  /// **'To cancel {merchant}, open the merchant\'s account or billing settings and stop the recurring payment.'**
  String subsUnsubscribeHint(String merchant);

  /// Placeholder when no unsubscribe URL is known.
  ///
  /// In en, this message translates to:
  /// **'No cancellation link available yet.'**
  String get subsUnsubscribeNoLink;

  /// Action to mark a subscription cancelled.
  ///
  /// In en, this message translates to:
  /// **'Mark as cancelled'**
  String get subsMarkCancelled;

  /// Disabled state of the cancel action.
  ///
  /// In en, this message translates to:
  /// **'Already cancelled'**
  String get subsAlreadyCancelled;

  /// Confirmation snackbar after cancelling.
  ///
  /// In en, this message translates to:
  /// **'Marked {merchant} as cancelled'**
  String subsMarkedCancelled(String merchant);

  /// Generic network error.
  ///
  /// In en, this message translates to:
  /// **'Network error. Check your connection.'**
  String get errorNetwork;

  /// Generic server error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our end.'**
  String get errorServer;

  /// Generic form validation error.
  ///
  /// In en, this message translates to:
  /// **'Please check the highlighted fields.'**
  String get errorValidation;

  /// Sync merge conflict resolved client-side.
  ///
  /// In en, this message translates to:
  /// **'Sync conflict. We kept your latest changes.'**
  String get errorSyncConflict;

  /// Generic offline notice.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Changes are saved locally.'**
  String get errorOffline;

  /// Fallback error title.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error'**
  String get errorUnknown;

  /// History filter chip: income only.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get filterIncome;

  /// History filter chip: expense only.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get filterExpense;

  /// History filter chip: opens category multi-select.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get filterCategory;

  /// History filter chip: opens date-range picker.
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get filterDateRange;

  /// Empty state when filters exclude all rows.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches'**
  String get filterNothingMatches;

  /// Body of the no-match empty state.
  ///
  /// In en, this message translates to:
  /// **'Try a different search or clear your filters.'**
  String get filterNothingMatchesBody;

  /// Action to reset all active filters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get filterClear;

  /// Quick-action: change a transaction's category.
  ///
  /// In en, this message translates to:
  /// **'Recategorize'**
  String get txRecategorize;

  /// Quick-action: split a transaction into N parts.
  ///
  /// In en, this message translates to:
  /// **'Split'**
  String get txSplit;

  /// Title of the split dialog.
  ///
  /// In en, this message translates to:
  /// **'Split into N parts'**
  String get txSplitTitle;

  /// Label for the split-parts count field.
  ///
  /// In en, this message translates to:
  /// **'Parts'**
  String get txSplitParts;

  /// Command-palette search placeholder.
  ///
  /// In en, this message translates to:
  /// **'Type a command…'**
  String get cmdPaletteHint;

  /// Command: open quick-add expense.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get cmdAddExpense;

  /// Command: open quick-add income.
  ///
  /// In en, this message translates to:
  /// **'Add income'**
  String get cmdAddIncome;

  /// Command: go to History and focus search.
  ///
  /// In en, this message translates to:
  /// **'Search transactions'**
  String get cmdSearchTransactions;

  /// Command: navigate to Dashboard.
  ///
  /// In en, this message translates to:
  /// **'Open Dashboard'**
  String get cmdOpenDashboard;

  /// Command: navigate to Transactions.
  ///
  /// In en, this message translates to:
  /// **'Open Transactions'**
  String get cmdOpenTransactions;

  /// Command: navigate to Analytics.
  ///
  /// In en, this message translates to:
  /// **'Open Analytics'**
  String get cmdOpenAnalytics;

  /// Command: navigate to Settings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get cmdOpenSettings;

  /// Command: flip between light and dark theme.
  ///
  /// In en, this message translates to:
  /// **'Toggle theme (light/dark)'**
  String get cmdToggleTheme;

  /// Command: open the language sub-menu.
  ///
  /// In en, this message translates to:
  /// **'Switch language (en/ru/kk)'**
  String get cmdSwitchLanguage;

  /// Command: navigate to the spending heatmap calendar.
  ///
  /// In en, this message translates to:
  /// **'Open spending calendar'**
  String get cmdOpenCalendar;

  /// Command: navigate to the recurring rules manager.
  ///
  /// In en, this message translates to:
  /// **'Open recurring transactions'**
  String get cmdOpenRecurring;

  /// Title of the CSV import column-mapping dialog.
  ///
  /// In en, this message translates to:
  /// **'Import preview'**
  String get importPreviewTitle;

  /// CSV import column: date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get importColumnDate;

  /// CSV import column: amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get importColumnAmount;

  /// CSV import column: merchant/note.
  ///
  /// In en, this message translates to:
  /// **'Merchant'**
  String get importColumnMerchant;

  /// CSV import column: category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get importColumnCategory;

  /// CSV import confirm button.
  ///
  /// In en, this message translates to:
  /// **'Import {count} rows'**
  String importConfirm(int count);

  /// Snackbar after a successful CSV import.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} transactions'**
  String importDone(int count);

  /// Settings section: calendar integration.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get setCalendar;

  /// Button to connect a calendar.
  ///
  /// In en, this message translates to:
  /// **'Connect calendar'**
  String get calConnect;

  /// Calendar connection status: connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get calConnected;

  /// Calendar connection status: not connected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get calNotConnected;

  /// Calendar section description.
  ///
  /// In en, this message translates to:
  /// **'Add payment and subscription reminders to your calendar.'**
  String get calConnectDesc;

  /// Title of the calendar picker.
  ///
  /// In en, this message translates to:
  /// **'Choose a calendar'**
  String get calChooseCalendar;

  /// Shown when calendar permission is refused.
  ///
  /// In en, this message translates to:
  /// **'Calendar access was denied.'**
  String get calPermissionDenied;

  /// Shows the chosen calendar name.
  ///
  /// In en, this message translates to:
  /// **'Using {name}'**
  String calSelected(String name);

  /// Toggle: add subscription due-date reminders to the calendar.
  ///
  /// In en, this message translates to:
  /// **'Subscription reminders'**
  String get calSubscriptionReminders;

  /// Subscription reminders toggle description.
  ///
  /// In en, this message translates to:
  /// **'Add a calendar event before each subscription renews.'**
  String get calSubscriptionRemindersDesc;

  /// Toggle: add budget end-of-period reminders to the calendar.
  ///
  /// In en, this message translates to:
  /// **'Budget reminders'**
  String get calBudgetReminders;

  /// Budget reminders toggle description.
  ///
  /// In en, this message translates to:
  /// **'Add a calendar event when a budget period is about to end.'**
  String get calBudgetRemindersDesc;

  /// Toggle: local push notifications for upcoming payments.
  ///
  /// In en, this message translates to:
  /// **'Payment push reminders'**
  String get notifPaymentPush;

  /// Payment push reminders toggle description.
  ///
  /// In en, this message translates to:
  /// **'Get a phone notification a day before and on the day a payment is due.'**
  String get notifPaymentPushDesc;

  /// Local notification title, day before a payment.
  ///
  /// In en, this message translates to:
  /// **'Payment tomorrow'**
  String get notifPaymentTomorrowTitle;

  /// Local notification body, day before.
  ///
  /// In en, this message translates to:
  /// **'{title} — {amount} is due tomorrow'**
  String notifPaymentTomorrowBody(String title, String amount);

  /// Local notification title, day of a payment.
  ///
  /// In en, this message translates to:
  /// **'Payment due today'**
  String get notifPaymentTodayTitle;

  /// Local notification body, day of.
  ///
  /// In en, this message translates to:
  /// **'{title} — {amount} is due today'**
  String notifPaymentTodayBody(String title, String amount);

  /// Generic share button label.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareAction;

  /// Share a single transaction via the OS share sheet.
  ///
  /// In en, this message translates to:
  /// **'Share transaction'**
  String get shareTransaction;

  /// Share a day's spending summary.
  ///
  /// In en, this message translates to:
  /// **'Share day summary'**
  String get shareDaySummary;

  /// Export upcoming payment events as an iCalendar file.
  ///
  /// In en, this message translates to:
  /// **'Export upcoming payments (.ics)'**
  String get shareExportPayments;

  /// Button: add this subscription's next charge to the calendar.
  ///
  /// In en, this message translates to:
  /// **'Add to calendar'**
  String get subsAddToCalendar;

  /// Shown after a subscription reminder is added to the calendar.
  ///
  /// In en, this message translates to:
  /// **'Reminder added'**
  String get subsReminderAdded;

  /// Calendar event title for a budget ending soon.
  ///
  /// In en, this message translates to:
  /// **'Budget \'{name}\' ends {date}'**
  String budgetReminderTitle(String name, String date);

  /// Quick action: turn a transaction into a recurring rule.
  ///
  /// In en, this message translates to:
  /// **'Make recurring'**
  String get recurMakeRecurring;

  /// Title of the make-recurring dialog.
  ///
  /// In en, this message translates to:
  /// **'Make recurring'**
  String get recurMakeTitle;

  /// Title of the edit-recurring dialog.
  ///
  /// In en, this message translates to:
  /// **'Edit recurring rule'**
  String get recurEditTitle;

  /// Title of the recurring rules manager page.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get recurPageTitle;

  /// Label above the cadence chooser.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get recurCadenceLabel;

  /// Cadence: daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get recurCadenceDaily;

  /// Cadence: weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get recurCadenceWeekly;

  /// Cadence: biweekly.
  ///
  /// In en, this message translates to:
  /// **'Every 2 weeks'**
  String get recurCadenceBiweekly;

  /// Cadence: monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get recurCadenceMonthly;

  /// Cadence: yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get recurCadenceYearly;

  /// Label for the interval stepper.
  ///
  /// In en, this message translates to:
  /// **'Every (interval)'**
  String get recurEveryLabel;

  /// Label for the optional end date.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get recurEndDateLabel;

  /// Shown when no end date is set.
  ///
  /// In en, this message translates to:
  /// **'No end date'**
  String get recurNoEndDate;

  /// Button to pick an end date.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get recurSetEndDate;

  /// Toggle to create a calendar reminder for the rule.
  ///
  /// In en, this message translates to:
  /// **'Add calendar reminder'**
  String get recurCalendarSync;

  /// Subtitle for the calendar reminder toggle.
  ///
  /// In en, this message translates to:
  /// **'Keeps a reminder on your calendar for the next occurrence.'**
  String get recurCalendarSyncHint;

  /// Tooltip: materialise any due recurring rules now.
  ///
  /// In en, this message translates to:
  /// **'Run now'**
  String get recurRunNow;

  /// Snackbar shown when no recurring rule was due.
  ///
  /// In en, this message translates to:
  /// **'Nothing due'**
  String get recurNoneDue;

  /// Menu action to pause a recurring rule.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get recurPause;

  /// Menu action to resume a paused recurring rule.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get recurResume;

  /// Empty-state title on the recurring page.
  ///
  /// In en, this message translates to:
  /// **'No recurring transactions'**
  String get recurEmptyTitle;

  /// Empty-state body on the recurring page.
  ///
  /// In en, this message translates to:
  /// **'Long-press a transaction and choose \"Make recurring\" to schedule it.'**
  String get recurEmptyBody;

  /// Snackbar after running the engine.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Added 1 transaction} other{Added {count} transactions}}'**
  String recurMaterialised(int count);

  /// Subtitle showing the next occurrence date.
  ///
  /// In en, this message translates to:
  /// **'Next {date}'**
  String recurNextRun(String date);

  /// Summary of an interval > 1 (e.g. Every 2 Monthly).
  ///
  /// In en, this message translates to:
  /// **'Every {interval} {cadence}'**
  String recurEvery(int interval, String cadence);
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'kk', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppL10nEn();
    case 'kk':
      return AppL10nKk();
    case 'ru':
      return AppL10nRu();
  }

  throw FlutterError(
      'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
