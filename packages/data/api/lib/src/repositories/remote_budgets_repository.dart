import '../dto/budget_dto.dart';
import '../services/budgets_service.dart';

/// Thin facade over [BudgetsService].
///
/// TODO(F-BUD-01): swap to a domain-defined `BudgetsRepository` once it
/// lands in `pf_domain`.
class RemoteBudgetsRepository {
  /// Default constructor.
  RemoteBudgetsRepository(this._service);

  final BudgetsService _service;

  /// List.
  Future<List<BudgetDto>> list({String? period, String? status}) =>
      _service.list(period: period, status: status);

  /// Create.
  Future<BudgetDto> create(CreateBudgetRequest request) =>
      _service.create(request);

  /// Progress.
  Future<BudgetProgressDto> progress(String id) => _service.progress(id);

  /// Delete.
  Future<void> delete(String id, {String? ifMatch}) =>
      _service.delete(id, ifMatch: ifMatch);
}
