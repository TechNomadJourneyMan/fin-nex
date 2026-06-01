import '../database/sync_state.dart';
import '../models/category_row.dart';

/// Canonical list of PocketFlow system categories (E3 taxonomy, 28 entries).
///
/// IDs are stable English keys (`food_groceries`, ...) used across clients and
/// server. Localisation lives in `name_i18n_key`; the `name` column carries
/// the default Russian label as a safe fallback when no i18n bundle is loaded.
class SystemCategoriesSeed {
  const SystemCategoriesSeed._();

  /// Stable seed clock so that re-seeding produces deterministic timestamps.
  static final DateTime seedEpoch = DateTime.utc(2026, 1, 1);

  /// All 28 system categories.
  static List<CategoryRow> all() => <CategoryRow>[
        // Basic expense (10)
        _row(
            'food_groceries', 'expense', 'Продукты', 'shopping_cart', '#22C55E',
            bucket: 'needs', isEssential: true, sortOrder: 1),
        _row('food_delivery', 'expense', 'Доставка еды', 'delivery_dining',
            '#F97316',
            bucket: 'wants', parentId: 'food_groceries', sortOrder: 2),
        _row('food_restaurants', 'expense', 'Кафе и рестораны', 'restaurant',
            '#EF4444',
            bucket: 'wants', sortOrder: 3),
        _row('transport_fuel', 'expense', 'Бензин', 'local_gas_station',
            '#0EA5E9',
            bucket: 'needs', isEssential: true, sortOrder: 4),
        _row('transport_public', 'expense', 'Общественный транспорт',
            'directions_bus', '#3B82F6',
            bucket: 'needs', isEssential: true, sortOrder: 5),
        _row('transport_taxi', 'expense', 'Такси', 'local_taxi', '#FACC15',
            bucket: 'wants', sortOrder: 6),
        _row('transport_car_service', 'expense', 'Авто: сервис, страховка',
            'build_circle', '#6366F1',
            bucket: 'needs', isEssential: true, sortOrder: 7),
        _row('housing_rent', 'expense', 'Аренда жилья', 'home', '#A855F7',
            bucket: 'needs', isEssential: true, sortOrder: 8),
        _row('housing_utilities', 'expense', 'Коммуналка', 'bolt', '#EAB308',
            bucket: 'needs', isEssential: true, sortOrder: 9),
        _row('housing_internet_mobile', 'expense', 'Связь, интернет', 'wifi',
            '#06B6D4',
            bucket: 'needs', isEssential: true, sortOrder: 10),

        // Lifestyle (8)
        _row('shopping_clothing', 'expense', 'Одежда и обувь', 'checkroom',
            '#EC4899',
            bucket: 'wants', sortOrder: 11),
        _row('shopping_electronics', 'expense', 'Электроника', 'devices',
            '#64748B',
            bucket: 'wants', sortOrder: 12),
        _row('shopping_marketplaces', 'expense', 'Маркетплейсы', 'storefront',
            '#F59E0B',
            bucket: 'wants', sortOrder: 13),
        _row('subscriptions_entertainment', 'expense',
            'Подписки: видео, музыка', 'subscriptions', '#DB2777',
            bucket: 'wants', sortOrder: 14),
        _row('subscriptions_productivity', 'expense',
            'Подписки: софт, обучение', 'apps', '#7C3AED',
            bucket: 'needs', sortOrder: 15),
        _row('entertainment_events', 'expense', 'Кино, концерты, события',
            'theater_comedy', '#F43F5E',
            bucket: 'wants', sortOrder: 16),
        _row('travel_local', 'expense', 'Путешествия по РК', 'map', '#14B8A6',
            bucket: 'wants', sortOrder: 17),
        _row('travel_international', 'expense', 'Путешествия за рубеж',
            'flight', '#0284C7',
            bucket: 'wants', sortOrder: 18),

        // Health & obligations (6)
        _row('health_pharmacy', 'expense', 'Аптеки', 'medication', '#10B981',
            bucket: 'needs', isEssential: true, sortOrder: 19),
        _row('health_medical', 'expense', 'Врачи, анализы, страховка',
            'medical_services', '#059669',
            bucket: 'needs', isEssential: true, sortOrder: 20),
        _row('education', 'expense', 'Образование, курсы', 'school', '#2563EB',
            bucket: 'needs', sortOrder: 21),
        _row('kids', 'expense', 'Дети (садик, школа, секции)', 'child_care',
            '#FB7185',
            bucket: 'needs', isEssential: true, sortOrder: 22),
        _row('debt_credit', 'expense', 'Кредиты, рассрочки', 'credit_card',
            '#DC2626',
            bucket: 'needs', isEssential: true, sortOrder: 23),
        _row('taxes_fees', 'expense', 'Налоги, штрафы, гос. услуги', 'gavel',
            '#475569',
            bucket: 'needs', isEssential: true, sortOrder: 24),

        // Transfers & income (4)
        _row('transfer_internal', 'transfer', 'Между своими счетами',
            'swap_horiz', '#94A3B8',
            bucket: 'neutral', sortOrder: 25),
        _row('transfer_p2p', 'transfer', 'Переводы людям', 'send_to_mobile',
            '#8B5CF6',
            bucket: 'neutral', sortOrder: 26),
        _row('income_salary', 'income', 'Зарплата', 'payments', '#16A34A',
            sortOrder: 27),
        _row('income_other', 'income',
            'Прочий доход (фриланс, подарки, кэшбэк)', 'savings', '#15803D',
            sortOrder: 28),
      ];

  static CategoryRow _row(
    String id,
    String typeCode,
    String name,
    String icon,
    String color, {
    String? parentId,
    String? bucket,
    bool isEssential = false,
    required int sortOrder,
  }) {
    return CategoryRow(
      id: id,
      typeCode: typeCode,
      parentId: parentId,
      name: name,
      nameI18nKey: 'category.$id',
      icon: icon,
      color: color,
      isSystem: true,
      sortOrder: sortOrder,
      bucket: bucket,
      isEssential: isEssential,
      clientId: id,
      createdAt: seedEpoch,
      updatedAt: seedEpoch,
      syncState: SyncState.synced,
      version: 1,
      dirty: false,
    );
  }
}
