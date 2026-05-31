/// FinNex pure-Dart domain layer: value objects, entities, repository
/// interfaces, and use cases. No Flutter or platform-channel dependencies.
library fnx_domain;

// Value objects
export 'src/values/category_color.dart';
export 'src/values/currency.dart';
export 'src/values/money.dart';
export 'src/values/ulid.dart';

// Failures
export 'src/failures/failure.dart';

// Entities
export 'src/entities/account.dart';
export 'src/entities/budget.dart';
export 'src/entities/category.dart';
export 'src/entities/enums.dart';
export 'src/entities/insight.dart';
export 'src/entities/limit.dart';
export 'src/entities/notification.dart';
export 'src/entities/streak.dart';
export 'src/entities/subscription.dart';
export 'src/entities/tag.dart';
export 'src/entities/transaction.dart';
export 'src/entities/user.dart';

// Repositories
export 'src/repositories/accounts_repository.dart';
export 'src/repositories/analytics_repository.dart';
export 'src/repositories/auth_repository.dart';
export 'src/repositories/budgets_repository.dart';
export 'src/repositories/categories_repository.dart';
export 'src/repositories/export_repository.dart';
export 'src/repositories/insights_repository.dart';
export 'src/repositories/notifications_repository.dart';
export 'src/repositories/settings_repository.dart';
export 'src/repositories/streak_repository.dart';
export 'src/repositories/sync_repository.dart';
export 'src/repositories/transactions_repository.dart';

// Use cases
export 'src/usecases/add_transaction.dart';
export 'src/usecases/calculate_financial_wellness.dart';
export 'src/usecases/check_budget_alerts.dart';
export 'src/usecases/create_budget.dart';
export 'src/usecases/create_category.dart';
export 'src/usecases/delete_account.dart';
export 'src/usecases/delete_transaction.dart';
export 'src/usecases/dismiss_insight.dart';
export 'src/usecases/edit_transaction.dart';
export 'src/usecases/export_data.dart';
export 'src/usecases/generate_insights.dart';
export 'src/usecases/get_cashflow.dart';
export 'src/usecases/get_category_breakdown.dart';
export 'src/usecases/get_dashboard_summary.dart';
export 'src/usecases/get_streak.dart';
export 'src/usecases/list_transactions.dart';
export 'src/usecases/mark_notification_read.dart';
export 'src/usecases/request_otp.dart';
export 'src/usecases/sign_in_apple.dart';
export 'src/usecases/sign_in_email.dart';
export 'src/usecases/sign_in_google.dart';
export 'src/usecases/sign_out.dart';
export 'src/usecases/sync_pull.dart';
export 'src/usecases/sync_push.dart';
export 'src/usecases/update_settings.dart';
export 'src/usecases/verify_otp.dart';
