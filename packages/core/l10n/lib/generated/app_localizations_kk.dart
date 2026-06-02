// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kazakh (`kk`).
class AppL10nKk extends AppL10n {
  AppL10nKk([String locale = 'kk']) : super(locale);

  @override
  String get appName => 'Pocket Flow';

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
  String get menuGoals => 'Мақсаттар';

  @override
  String get menuAchievements => 'Жетістіктер';

  @override
  String get menuWorkspaces => 'Жұмыс кеңістіктері';

  @override
  String get menuSmsSandbox => 'SMS құмсалғыш';

  @override
  String get menuNotifications => 'Хабарландырулар';

  @override
  String get menuMore => 'Тағы';

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
  String get onbP1Body => 'Бір рет түртіп шығынды жазыңыз. Күрделі формасыз.';

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
  String get onbP4Body => 'Тіл мен валютаны таңдаңыз — 10 секундты алады.';

  @override
  String get authTitle => 'Pocket Flow-ке кіру';

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
  String authOtpSubtitle(String phone) {
    return 'SMS жіберілді: $phone.';
  }

  @override
  String authOtpResendIn(String time) {
    return '$time кейін қайта жіберу';
  }

  @override
  String get authOtpResend => 'Қайта жіберу';

  @override
  String get authOtpHelp => 'Кодты алмадыңыз ба?';

  @override
  String get authBiometricPrompt => 'Биометрия арқылы кіру';

  @override
  String get authBiometricReason => 'Pocket Flow-ке кіруді растаңыз';

  @override
  String get authErrorNetwork => 'Интернетті тексеріңіз';

  @override
  String get authErrorInvalidCode => 'Қате код';

  @override
  String get authErrorRateLimit => 'Тым көп әрекет. 5 минуттан кейін көріңіз.';

  @override
  String authLegal(String terms, String privacy) {
    return 'Жалғастыра отырып, сіз $terms және $privacy қабылдайсыз.';
  }

  @override
  String dashGreeting(String name) {
    return 'Сәлем, $name';
  }

  @override
  String get dashPeriodDay => 'Бүгін';

  @override
  String get dashPeriodWeek => 'Апта';

  @override
  String get dashPeriodMonth => 'Ай';

  @override
  String dashDeltaUp(int percent) {
    return 'Өткен аптадан $percent% көп';
  }

  @override
  String dashDeltaDown(int percent) {
    return 'Өткен аптадан $percent% аз';
  }

  @override
  String get dashBudgetTitle => 'Айлық бюджет';

  @override
  String dashBudgetDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days күн қалды',
    );
    return '$_temp0';
  }

  @override
  String dashBudgetOver(String amount) {
    return 'Бюджеттен тыс: $amount';
  }

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
  String qaSavedExpense(String amount) {
    return 'Шығын $amount қосылды';
  }

  @override
  String qaSavedIncome(String amount) {
    return 'Кіріс $amount қосылды';
  }

  @override
  String get qaSaveErrorOffline => 'Сақталмады. Кезекте.';

  @override
  String qaLimitNear(String spent, String budget) {
    return 'Лимит жақын: $spent / $budget';
  }

  @override
  String qaLimitExceedTitle(String amount) {
    return 'Лимиттен $amount асып кетесіз';
  }

  @override
  String get qaLimitExceedSave => 'Сонда да жазу';

  @override
  String get qaLimitExceedAdjust => 'Соманы өзгерту';

  @override
  String get qaIncomeRecurringHint => 'Тұрақты етесіз бе?';

  @override
  String qaIncomeProgress(String current, String expected) {
    return '$expected ішінен $current';
  }

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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count операция',
      zero: 'Операция жоқ',
    );
    return '$_temp0';
  }

  @override
  String txDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days күн бұрын',
      one: 'Кеше',
      zero: 'Бүгін',
    );
    return '$_temp0';
  }

  @override
  String txItemsSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count элемент таңдалды',
    );
    return '$_temp0';
  }

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
  String budgetProgressLabel(String spent, String limit) {
    return '$limit ішінен $spent';
  }

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
  String get notifDailyReminderBody => '3 секунд алады. Қосу үшін түртіңіз.';

  @override
  String get notifWeeklyRecapTitle => 'Аптаңыз сандармен';

  @override
  String notifWeeklyRecapBody(String amount) {
    return 'Осы аптада $amount жұмсадыңыз.';
  }

  @override
  String get notifLimitWarningTitle => 'Бюджет ескертуі';

  @override
  String notifLimitWarningBody(String category, int percent) {
    return '$category санаты лимиттің $percent%-ына жетті.';
  }

  @override
  String get notifInsightReadyTitle => 'Жаңа түсінік';

  @override
  String get notifInsightReadyBody =>
      'Толығырақ білу үшін Pocket Flow-ты ашыңыз.';

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
  String get setAccessibility => 'Қолжетімділік';

  @override
  String get setHighContrast => 'Жоғары контраст режимі';

  @override
  String get setHighContrastDesc =>
      'Қаныққан бренд түсі бар таза қара-ақ беттер.';

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
  String setVersion(String version) {
    return 'Нұсқа $version';
  }

  @override
  String get setSignOut => 'Шығу';

  @override
  String get setDeleteAccount => 'Аккаунтты жою';

  @override
  String get setDeleteAccountConfirm =>
      'Аккаунтты жоясыз ба? Барлық дерек өшіріледі.';

  @override
  String get settings_section_feedback => 'Дыбыс және дірілдеу';

  @override
  String get feedback_haptics => 'Тактильді қайтарым';

  @override
  String get feedback_sound => 'Дыбыс әсерлері';

  @override
  String get feedback_preview => 'Тыңдау';

  @override
  String get subsTitle => 'Жазылымдар';

  @override
  String get subsDetailTitle => 'Жазылым';

  @override
  String get subsEmptyTitle => 'Әзірге жазылымдар жоқ';

  @override
  String get subsEmptyBody =>
      'Тұрақты төлемдерді анықтасақ, осында көрсетеміз.';

  @override
  String get subsNotFound => 'Жазылым табылмады.';

  @override
  String subsMonthlyTotalLabel(String month) {
    return '$month айындағы жазылымдарға барлығы';
  }

  @override
  String subsActiveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count белсенді жазылым',
      one: '$count белсенді жазылым',
      zero: 'Белсенді жазылымдар жоқ',
    );
    return '$_temp0';
  }

  @override
  String subsNextBilling(String date) {
    return 'Келесі төлем $date';
  }

  @override
  String get subsPeriodWeekly => 'Апта сайын';

  @override
  String get subsPeriodMonthly => 'Ай сайын';

  @override
  String get subsPeriodQuarterly => 'Тоқсан сайын';

  @override
  String get subsPeriodYearly => 'Жыл сайын';

  @override
  String get subsCancelledBadge => 'Бас тартылды';

  @override
  String get subsSourceTransactions => 'Бастапқы транзакциялар';

  @override
  String get subsNoSourceTransactions => 'Әзірге байланысты транзакциялар жоқ.';

  @override
  String get subsHowToUnsubscribe => 'Қалай бас тарту керек';

  @override
  String subsUnsubscribeHint(String merchant) {
    return '$merchant жазылымынан бас тарту үшін сервистің аккаунт немесе төлем баптауларын ашып, тұрақты төлемді тоқтатыңыз.';
  }

  @override
  String get subsUnsubscribeNoLink => 'Бас тарту сілтемесі әзірге қолжетімсіз.';

  @override
  String get subsMarkCancelled => 'Бас тартылды деп белгілеу';

  @override
  String get subsAlreadyCancelled => 'Бұрын бас тартылған';

  @override
  String subsMarkedCancelled(String merchant) {
    return '$merchant бас тартылды деп белгіленді';
  }

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
  String get errorOffline => 'Сіз офлайнсыз. Өзгерістер жергілікті сақталды.';

  @override
  String get errorUnknown => 'Күтпеген қате';

  @override
  String get filterIncome => 'Кіріс';

  @override
  String get filterExpense => 'Шығыс';

  @override
  String get filterCategory => 'Санат';

  @override
  String get filterDateRange => 'Кезең';

  @override
  String get filterNothingMatches => 'Сәйкестік жоқ';

  @override
  String get filterNothingMatchesBody =>
      'Сұрауды өзгертіңіз немесе сүзгілерді тазалаңыз.';

  @override
  String get filterClear => 'Сүзгілерді тазарту';

  @override
  String get txRecategorize => 'Санатын өзгерту';

  @override
  String get txSplit => 'Бөлу';

  @override
  String get txSplitTitle => 'N бөлікке бөлу';

  @override
  String get txSplitParts => 'Бөліктер';

  @override
  String get cmdPaletteHint => 'Команда теріңіз…';

  @override
  String get cmdAddExpense => 'Шығыс қосу';

  @override
  String get cmdAddIncome => 'Кіріс қосу';

  @override
  String get cmdSearchTransactions => 'Операцияларды іздеу';

  @override
  String get cmdOpenDashboard => 'Басты бетті ашу';

  @override
  String get cmdOpenTransactions => 'Операцияларды ашу';

  @override
  String get cmdOpenAnalytics => 'Аналитиканы ашу';

  @override
  String get cmdOpenSettings => 'Параметрлерді ашу';

  @override
  String get cmdToggleTheme => 'Тақырыпты ауыстыру (ашық/қараңғы)';

  @override
  String get cmdSwitchLanguage => 'Тілді ауыстыру (en/ru/kk)';

  @override
  String get importPreviewTitle => 'Импорт алдын ала қарау';

  @override
  String get importColumnDate => 'Күні';

  @override
  String get importColumnAmount => 'Сома';

  @override
  String get importColumnMerchant => 'Сатушы';

  @override
  String get importColumnCategory => 'Санат';

  @override
  String importConfirm(int count) {
    return '$count жолды импорттау';
  }

  @override
  String importDone(int count) {
    return 'Импортталған операциялар: $count';
  }

  @override
  String get setCalendar => 'Күнтізбе';

  @override
  String get calConnect => 'Күнтізбені қосу';

  @override
  String get calConnected => 'Қосылды';

  @override
  String get calNotConnected => 'Қосылмаған';

  @override
  String get calConnectDesc =>
      'Төлемдер мен жазылымдар туралы еске салғыштарды күнтізбеге қосыңыз.';

  @override
  String get calChooseCalendar => 'Күнтізбені таңдаңыз';

  @override
  String get calPermissionDenied => 'Күнтізбеге қол жеткізу қабылданбады.';

  @override
  String calSelected(String name) {
    return '$name қолданылуда';
  }

  @override
  String get calSubscriptionReminders => 'Жазылым еске салғыштары';

  @override
  String get calSubscriptionRemindersDesc =>
      'Әр жазылым жаңартылар алдында күнтізбеге оқиға қосу.';

  @override
  String get calBudgetReminders => 'Бюджет еске салғыштары';

  @override
  String get calBudgetRemindersDesc =>
      'Бюджет кезеңі аяқталар алдында күнтізбеге оқиға қосу.';

  @override
  String get subsAddToCalendar => 'Күнтізбеге қосу';

  @override
  String get subsReminderAdded => 'Еске салғыш қосылды';

  @override
  String budgetReminderTitle(String name, String date) {
    return '«$name» бюджеті $date аяқталады';
  }
}
