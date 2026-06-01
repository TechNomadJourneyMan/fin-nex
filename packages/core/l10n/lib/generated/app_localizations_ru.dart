// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppL10nRu extends AppL10n {
  AppL10nRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Pocket Flow';

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
  String get menuGoals => 'Цели';

  @override
  String get menuAchievements => 'Достижения';

  @override
  String get menuWorkspaces => 'Рабочие пространства';

  @override
  String get menuSmsSandbox => 'Песочница SMS';

  @override
  String get menuNotifications => 'Уведомления';

  @override
  String get menuMore => 'Ещё';

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
  String get onbP2Body => 'Готовые категории для Казахстана. Добавляйте свои.';

  @override
  String get onbP3Title => 'Один тап — расход записан';

  @override
  String get onbP3Body =>
      'Виджет для iOS и Android. Не нужно открывать приложение.';

  @override
  String get onbP4Title => 'Готовы начать?';

  @override
  String get onbP4Body => 'Выберите язык и валюту — займёт 10 секунд.';

  @override
  String get authTitle => 'Войти в Pocket Flow';

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
  String authOtpSubtitle(String phone) {
    return 'Отправили SMS на $phone.';
  }

  @override
  String authOtpResendIn(String time) {
    return 'Отправить заново через $time';
  }

  @override
  String get authOtpResend => 'Отправить заново';

  @override
  String get authOtpHelp => 'Не получили код?';

  @override
  String get authBiometricPrompt => 'Войти по биометрии';

  @override
  String get authBiometricReason => 'Подтвердите вход в Pocket Flow';

  @override
  String get authErrorNetwork => 'Проверьте интернет';

  @override
  String get authErrorInvalidCode => 'Неверный код';

  @override
  String get authErrorRateLimit =>
      'Слишком много попыток. Попробуйте через 5 минут.';

  @override
  String authLegal(String terms, String privacy) {
    return 'Продолжая, вы принимаете $terms и $privacy.';
  }

  @override
  String dashGreeting(String name) {
    return 'Привет, $name';
  }

  @override
  String get dashPeriodDay => 'Сегодня';

  @override
  String get dashPeriodWeek => 'Неделя';

  @override
  String get dashPeriodMonth => 'Месяц';

  @override
  String dashDeltaUp(int percent) {
    return '+$percent% к прошлой неделе';
  }

  @override
  String dashDeltaDown(int percent) {
    return '−$percent% к прошлой неделе';
  }

  @override
  String get dashBudgetTitle => 'Бюджет на месяц';

  @override
  String dashBudgetDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'осталось $days дня',
      many: 'осталось $days дней',
      few: 'осталось $days дня',
      one: 'остался $days день',
    );
    return '$_temp0';
  }

  @override
  String dashBudgetOver(String amount) {
    return 'Сверх бюджета: $amount';
  }

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
  String qaSavedExpense(String amount) {
    return 'Расход $amount добавлен';
  }

  @override
  String qaSavedIncome(String amount) {
    return 'Доход $amount добавлен';
  }

  @override
  String get qaSaveErrorOffline => 'Не сохранилось. Запись в очереди.';

  @override
  String qaLimitNear(String spent, String budget) {
    return 'Скоро лимит: $spent / $budget';
  }

  @override
  String qaLimitExceedTitle(String amount) {
    return 'Превысите лимит на $amount';
  }

  @override
  String get qaLimitExceedSave => 'Всё равно записать';

  @override
  String get qaLimitExceedAdjust => 'Изменить сумму';

  @override
  String get qaIncomeRecurringHint => 'Сделать регулярным?';

  @override
  String qaIncomeProgress(String current, String expected) {
    return '$current из $expected';
  }

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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count операции',
      many: '$count операций',
      few: '$count операции',
      one: '$count операция',
      zero: 'Нет операций',
    );
    return '$_temp0';
  }

  @override
  String txDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days дня назад',
      many: '$days дней назад',
      few: '$days дня назад',
      one: '$days день назад',
      zero: 'Сегодня',
    );
    return '$_temp0';
  }

  @override
  String txItemsSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Выбрано $count элемента',
      many: 'Выбрано $count элементов',
      few: 'Выбрано $count элемента',
      one: 'Выбран $count элемент',
    );
    return '$_temp0';
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
  String budgetProgressLabel(String spent, String limit) {
    return '$spent из $limit';
  }

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
  String notifWeeklyRecapBody(String amount) {
    return 'За эту неделю вы потратили $amount.';
  }

  @override
  String get notifLimitWarningTitle => 'Бюджетный алерт';

  @override
  String notifLimitWarningBody(String category, int percent) {
    return 'Категория $category достигла $percent% лимита.';
  }

  @override
  String get notifInsightReadyTitle => 'Новый инсайт';

  @override
  String get notifInsightReadyBody =>
      'Откройте Pocket Flow, чтобы узнать подробности.';

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
  String setVersion(String version) {
    return 'Версия $version';
  }

  @override
  String get setSignOut => 'Выйти';

  @override
  String get setDeleteAccount => 'Удалить аккаунт';

  @override
  String get setDeleteAccountConfirm =>
      'Удалить аккаунт? Все данные будут стёрты.';

  @override
  String get settings_section_feedback => 'Звук и вибрация';

  @override
  String get feedback_haptics => 'Тактильный отклик';

  @override
  String get feedback_sound => 'Звуковые эффекты';

  @override
  String get feedback_preview => 'Прослушать';

  @override
  String get subsTitle => 'Подписки';

  @override
  String get subsDetailTitle => 'Подписка';

  @override
  String get subsEmptyTitle => 'Подписок пока нет';

  @override
  String get subsEmptyBody =>
      'Здесь появятся регулярные списания, как только мы их обнаружим.';

  @override
  String get subsNotFound => 'Подписка не найдена.';

  @override
  String subsMonthlyTotalLabel(String month) {
    return 'Всего на подписки в $month';
  }

  @override
  String subsActiveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count активных подписок',
      many: '$count активных подписок',
      few: '$count активные подписки',
      one: '$count активная подписка',
      zero: 'Нет активных подписок',
    );
    return '$_temp0';
  }

  @override
  String subsNextBilling(String date) {
    return 'Следующее списание $date';
  }

  @override
  String get subsPeriodWeekly => 'Еженедельно';

  @override
  String get subsPeriodMonthly => 'Ежемесячно';

  @override
  String get subsPeriodQuarterly => 'Ежеквартально';

  @override
  String get subsPeriodYearly => 'Ежегодно';

  @override
  String get subsCancelledBadge => 'Отменена';

  @override
  String get subsSourceTransactions => 'Исходные транзакции';

  @override
  String get subsNoSourceTransactions => 'Связанных транзакций пока нет.';

  @override
  String get subsHowToUnsubscribe => 'Как отписаться';

  @override
  String subsUnsubscribeHint(String merchant) {
    return 'Чтобы отменить $merchant, откройте настройки аккаунта или оплаты у сервиса и отключите регулярный платёж.';
  }

  @override
  String get subsUnsubscribeNoLink => 'Ссылка для отмены пока недоступна.';

  @override
  String get subsMarkCancelled => 'Отметить как отменённую';

  @override
  String get subsAlreadyCancelled => 'Уже отменена';

  @override
  String subsMarkedCancelled(String merchant) {
    return '$merchant отмечена как отменённая';
  }

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
  String get errorOffline => 'Вы офлайн. Изменения сохранены локально.';

  @override
  String get errorUnknown => 'Непредвиденная ошибка';
}
