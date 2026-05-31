/// SQL schema definition for FinNex local SQLite database, v1 baseline.
///
/// The schema is a SQLite-compatible subset of the canonical Postgres schema
/// described in `09_database_schema.md`. Differences:
///
/// * `CHAR(26)` / `TEXT(26)` are stored as `TEXT` with no length enforcement.
/// * `TIMESTAMPTZ` is stored as ISO8601 `TEXT` (UTC).
/// * `BIGINT` is stored as `INTEGER` (SQLite handles 64-bit integers).
/// * Array columns (`TEXT[]`, `INT[]`) are stored as JSON `TEXT`.
/// * Partial unique indexes with predicates are replaced by composite uniques
///   plus query-side filters.
class FnxSchema {
  const FnxSchema._();

  /// Current schema version. Bump on every breaking migration.
  static const int version = 1;

  /// Ordered list of DDL statements executed inside `onCreate`.
  static const List<String> createStatements = <String>[
    _accounts,
    _accountsIdxUser,
    _accountsIdxDirty,
    _accountsUqClient,
    _categories,
    _categoriesIdxUserType,
    _categoriesIdxParent,
    _categoriesUqClient,
    _categoriesIdxDirty,
    _transactions,
    _txIdxUserOccurred,
    _txIdxAccountOccurred,
    _txIdxUserCategoryOccurred,
    _txIdxUserTypeOccurred,
    _txIdxUserDirty,
    _txIdxRecurring,
    _txIdxTransferGroup,
    _txUqClient,
    _tags,
    _tagsUqUserName,
    _tagsIdxUsage,
    _tagsUqClient,
    _txTags,
    _txTagsIdxTag,
    _budgets,
    _budgetsIdxUserActive,
    _budgetsUqClient,
    _notifications,
    _notifIdxUserUnread,
    _notifIdxScheduled,
    _insights,
    _insightsIdxUserActive,
    _userSettings,
    _streaks,
    _syncQueue,
    _syncQueueIdxPending,
  ];

  // ---------------------------------------------------------------------------
  // Tables
  // ---------------------------------------------------------------------------

  static const String _accounts = '''
CREATE TABLE accounts (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  type_code TEXT NOT NULL,
  name TEXT NOT NULL,
  currency TEXT NOT NULL,
  balance_minor INTEGER NOT NULL DEFAULT 0,
  initial_balance_minor INTEGER NOT NULL DEFAULT 0,
  credit_limit_minor INTEGER,
  bank_code TEXT,
  last_four TEXT,
  color TEXT NOT NULL DEFAULT '#1F8FFF',
  icon TEXT,
  is_archived INTEGER NOT NULL DEFAULT 0,
  include_in_total INTEGER NOT NULL DEFAULT 1,
  sort_order INTEGER NOT NULL DEFAULT 0,
  client_id TEXT NOT NULL,
  server_id TEXT,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  deleted_at TEXT,
  sync_state TEXT NOT NULL DEFAULT 'pending',
  version INTEGER NOT NULL DEFAULT 1,
  server_version INTEGER,
  last_synced_at TEXT,
  dirty INTEGER NOT NULL DEFAULT 1,
  device_id TEXT
);
''';

  static const String _accountsIdxUser =
      'CREATE INDEX idx_accounts_user_alive ON accounts(user_id, sort_order);';
  static const String _accountsIdxDirty =
      'CREATE INDEX idx_accounts_user_dirty ON accounts(user_id, dirty);';
  static const String _accountsUqClient =
      'CREATE UNIQUE INDEX uq_accounts_client_id ON accounts(client_id);';

  static const String _categories = '''
CREATE TABLE categories (
  id TEXT PRIMARY KEY,
  user_id TEXT,
  type_code TEXT NOT NULL,
  parent_id TEXT,
  name TEXT NOT NULL,
  name_i18n_key TEXT,
  icon TEXT NOT NULL,
  color TEXT NOT NULL DEFAULT '#888888',
  is_system INTEGER NOT NULL DEFAULT 0,
  is_archived INTEGER NOT NULL DEFAULT 0,
  sort_order INTEGER NOT NULL DEFAULT 0,
  monthly_limit_minor INTEGER,
  bucket TEXT,
  is_essential INTEGER NOT NULL DEFAULT 0,
  client_id TEXT NOT NULL,
  server_id TEXT,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  deleted_at TEXT,
  sync_state TEXT NOT NULL DEFAULT 'pending',
  version INTEGER NOT NULL DEFAULT 1,
  server_version INTEGER,
  last_synced_at TEXT,
  dirty INTEGER NOT NULL DEFAULT 1,
  device_id TEXT
);
''';

  static const String _categoriesIdxUserType =
      'CREATE INDEX idx_categories_user_type ON categories(user_id, type_code);';
  static const String _categoriesIdxParent =
      'CREATE INDEX idx_categories_parent ON categories(parent_id);';
  static const String _categoriesUqClient =
      'CREATE UNIQUE INDEX uq_categories_client_id ON categories(client_id);';
  static const String _categoriesIdxDirty =
      'CREATE INDEX idx_categories_dirty ON categories(user_id, dirty);';

  static const String _transactions = '''
CREATE TABLE transactions (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  account_id TEXT NOT NULL,
  type_code TEXT NOT NULL,
  category_id TEXT,
  amount_minor INTEGER NOT NULL,
  currency TEXT NOT NULL,
  fx_rate REAL,
  amount_primary_minor INTEGER,
  occurred_at TEXT NOT NULL,
  note TEXT,
  transfer_account_id TEXT,
  transfer_group_id TEXT,
  recurring_rule_id TEXT,
  source TEXT NOT NULL DEFAULT 'manual',
  external_ref TEXT,
  has_attachment INTEGER NOT NULL DEFAULT 0,
  lat REAL,
  lng REAL,
  client_id TEXT NOT NULL,
  server_id TEXT,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  deleted_at TEXT,
  sync_state TEXT NOT NULL DEFAULT 'pending',
  version INTEGER NOT NULL DEFAULT 1,
  server_version INTEGER,
  last_synced_at TEXT,
  dirty INTEGER NOT NULL DEFAULT 1,
  device_id TEXT,
  CHECK (amount_minor >= 0)
);
''';

  static const String _txIdxUserOccurred =
      'CREATE INDEX idx_tx_user_occurred ON transactions(user_id, occurred_at DESC);';
  static const String _txIdxAccountOccurred =
      'CREATE INDEX idx_tx_account_occurred ON transactions(account_id, occurred_at DESC);';
  static const String _txIdxUserCategoryOccurred =
      'CREATE INDEX idx_tx_user_category_occurred ON transactions(user_id, category_id, occurred_at DESC);';
  static const String _txIdxUserTypeOccurred =
      'CREATE INDEX idx_tx_user_type_occurred ON transactions(user_id, type_code, occurred_at DESC);';
  static const String _txIdxUserDirty =
      'CREATE INDEX idx_tx_user_dirty ON transactions(user_id, dirty);';
  static const String _txIdxRecurring =
      'CREATE INDEX idx_tx_recurring ON transactions(recurring_rule_id);';
  static const String _txIdxTransferGroup =
      'CREATE INDEX idx_tx_transfer_group ON transactions(transfer_group_id);';
  static const String _txUqClient =
      'CREATE UNIQUE INDEX uq_tx_client_id ON transactions(client_id);';

  static const String _tags = '''
CREATE TABLE tags (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  name TEXT NOT NULL,
  color TEXT NOT NULL DEFAULT '#888888',
  usage_count INTEGER NOT NULL DEFAULT 0,
  client_id TEXT NOT NULL,
  server_id TEXT,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  deleted_at TEXT,
  sync_state TEXT NOT NULL DEFAULT 'pending',
  version INTEGER NOT NULL DEFAULT 1,
  server_version INTEGER,
  last_synced_at TEXT,
  dirty INTEGER NOT NULL DEFAULT 1,
  device_id TEXT
);
''';

  static const String _tagsUqUserName =
      "CREATE UNIQUE INDEX uq_tags_user_name ON tags(user_id, name);";
  static const String _tagsIdxUsage =
      'CREATE INDEX idx_tags_user_usage ON tags(user_id, usage_count DESC);';
  static const String _tagsUqClient =
      'CREATE UNIQUE INDEX uq_tags_client_id ON tags(client_id);';

  static const String _txTags = '''
CREATE TABLE transaction_tags (
  transaction_id TEXT NOT NULL,
  tag_id TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  PRIMARY KEY (transaction_id, tag_id)
);
''';
  static const String _txTagsIdxTag =
      'CREATE INDEX idx_tx_tags_tag ON transaction_tags(tag_id);';

  static const String _budgets = '''
CREATE TABLE budgets (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  name TEXT NOT NULL,
  period_code TEXT NOT NULL,
  amount_minor INTEGER NOT NULL,
  currency TEXT NOT NULL,
  scope TEXT NOT NULL DEFAULT 'category',
  category_ids TEXT,
  account_ids TEXT,
  starts_on TEXT NOT NULL,
  ends_on TEXT,
  rollover_unspent INTEGER NOT NULL DEFAULT 0,
  alert_at_percent INTEGER NOT NULL DEFAULT 80,
  is_active INTEGER NOT NULL DEFAULT 1,
  client_id TEXT NOT NULL,
  server_id TEXT,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  deleted_at TEXT,
  sync_state TEXT NOT NULL DEFAULT 'pending',
  version INTEGER NOT NULL DEFAULT 1,
  server_version INTEGER,
  last_synced_at TEXT,
  dirty INTEGER NOT NULL DEFAULT 1,
  device_id TEXT
);
''';

  static const String _budgetsIdxUserActive =
      'CREATE INDEX idx_budgets_user_active ON budgets(user_id, is_active);';
  static const String _budgetsUqClient =
      'CREATE UNIQUE INDEX uq_budgets_client_id ON budgets(client_id);';

  static const String _notifications = '''
CREATE TABLE notifications (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  kind TEXT NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  payload TEXT,
  priority INTEGER NOT NULL DEFAULT 5,
  scheduled_at TEXT,
  sent_at TEXT,
  read_at TEXT,
  dismissed_at TEXT,
  channel TEXT NOT NULL DEFAULT 'push',
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);
''';

  static const String _notifIdxUserUnread =
      'CREATE INDEX idx_notif_user_unread ON notifications(user_id, created_at DESC);';
  static const String _notifIdxScheduled =
      'CREATE INDEX idx_notif_scheduled ON notifications(scheduled_at);';

  static const String _insights = '''
CREATE TABLE insights (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  kind TEXT NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  severity TEXT NOT NULL DEFAULT 'info',
  payload TEXT,
  generated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  expires_at TEXT,
  dismissed_at TEXT,
  acted_at TEXT,
  score REAL
);
''';

  static const String _insightsIdxUserActive =
      'CREATE INDEX idx_insights_user_active ON insights(user_id, generated_at DESC);';

  static const String _userSettings = '''
CREATE TABLE user_settings (
  user_id TEXT PRIMARY KEY,
  theme TEXT NOT NULL DEFAULT 'system',
  week_starts_on INTEGER NOT NULL DEFAULT 1,
  number_format TEXT NOT NULL DEFAULT 'ru-KZ',
  decimal_separator TEXT NOT NULL DEFAULT ',',
  thousand_separator TEXT NOT NULL DEFAULT ' ',
  hide_balances_until_auth INTEGER NOT NULL DEFAULT 0,
  biometric_lock INTEGER NOT NULL DEFAULT 0,
  default_account_id TEXT,
  default_expense_category_id TEXT,
  default_income_category_id TEXT,
  quick_add_amounts TEXT,
  budget_carryover_default INTEGER NOT NULL DEFAULT 0,
  daily_reminder_time TEXT,
  show_account_total_on_home INTEGER NOT NULL DEFAULT 1,
  language TEXT NOT NULL DEFAULT 'ru',
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  version INTEGER NOT NULL DEFAULT 1
);
''';

  static const String _streaks = '''
CREATE TABLE streaks (
  user_id TEXT PRIMARY KEY,
  current_streak_days INTEGER NOT NULL DEFAULT 0,
  longest_streak_days INTEGER NOT NULL DEFAULT 0,
  last_active_date TEXT,
  total_active_days INTEGER NOT NULL DEFAULT 0,
  frozen_until TEXT,
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  version INTEGER NOT NULL DEFAULT 1
);
''';

  static const String _syncQueue = '''
CREATE TABLE sync_queue (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  entity_table TEXT NOT NULL,
  entity_id TEXT NOT NULL,
  op TEXT NOT NULL,
  payload TEXT NOT NULL,
  enqueued_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  attempts INTEGER NOT NULL DEFAULT 0,
  last_attempt_at TEXT,
  last_error TEXT,
  status TEXT NOT NULL DEFAULT 'pending'
);
''';

  static const String _syncQueueIdxPending =
      'CREATE INDEX idx_sync_queue_pending ON sync_queue(status, enqueued_at);';
}
