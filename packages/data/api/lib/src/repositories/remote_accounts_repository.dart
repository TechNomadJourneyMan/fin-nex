import '../dto/account_dto.dart';
import '../services/accounts_service.dart';

/// Thin facade over [AccountsService].
///
/// TODO(F-ACC-01): swap to a domain-defined `AccountsRepository` once it
/// lands in `fnx_domain`.
class RemoteAccountsRepository {
  /// Default constructor.
  RemoteAccountsRepository(this._service);

  final AccountsService _service;

  /// List.
  Future<List<AccountDto>> list({bool includeArchived = false}) =>
      _service.list(includeArchived: includeArchived);

  /// Get one.
  Future<AccountDto> get(String id) => _service.get(id);

  /// Create.
  Future<AccountDto> create(CreateAccountRequest request) =>
      _service.create(request);

  /// Update.
  Future<AccountDto> update(
    String id,
    UpdateAccountRequest request, {
    String? ifMatch,
  }) =>
      _service.update(id, request, ifMatch: ifMatch);

  /// Delete.
  Future<void> delete(String id, {bool force = false, String? ifMatch}) =>
      _service.delete(id, force: force, ifMatch: ifMatch);
}
