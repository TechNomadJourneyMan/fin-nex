// Public API for FinNex REST client.
//
// This library exposes a thin, typed Dio-based client for the FinNex backend
// (see `10_api_spec.md`). All DTOs are hand-rolled (no build_runner) and all
// network errors are mapped to [Failure] subclasses from `fnx_domain`.

library fnx_data_api;

// Client
export 'src/client/dio_factory.dart';
export 'src/client/api_config.dart';

// Interceptors
export 'src/interceptors/auth_interceptor.dart';
export 'src/interceptors/idempotency_interceptor.dart';
export 'src/interceptors/problem_details_interceptor.dart';
export 'src/interceptors/logging_interceptor.dart';
export 'src/interceptors/retry_interceptor.dart';

// Exceptions / errors
export 'src/exceptions/api_exception.dart';
export 'src/error_mapper.dart';

// DTOs
export 'src/dto/auth_dto.dart';
export 'src/dto/transaction_dto.dart';
export 'src/dto/account_dto.dart';
export 'src/dto/category_dto.dart';
export 'src/dto/budget_dto.dart';
export 'src/dto/sync_dto.dart';
export 'src/dto/notification_dto.dart';
export 'src/dto/analytics_summary_dto.dart';
export 'src/dto/error_dto.dart';
export 'src/dto/pagination_dto.dart';
export 'src/dto/device_dto.dart';
export 'src/dto/subscription_dto.dart';
export 'src/dto/export_dto.dart';
export 'src/dto/user_dto.dart';

// Services
export 'src/services/auth_service.dart';
export 'src/services/transactions_service.dart';
export 'src/services/accounts_service.dart';
export 'src/services/categories_service.dart';
export 'src/services/budgets_service.dart';
export 'src/services/analytics_service.dart';
export 'src/services/sync_service.dart';
export 'src/services/notifications_service.dart';
export 'src/services/subscriptions_service.dart';
export 'src/services/devices_service.dart';
export 'src/services/export_service.dart';

// Repository implementations
export 'src/repositories/auth_repository_impl.dart';
export 'src/repositories/http_auth_repository.dart';
export 'src/repositories/remote_transactions_repository.dart';
export 'src/repositories/remote_accounts_repository.dart';
export 'src/repositories/remote_categories_repository.dart';
export 'src/repositories/remote_budgets_repository.dart';
