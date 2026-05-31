/// REST representation of a budget.
class BudgetDto {
  /// Default constructor.
  const BudgetDto({
    required this.id,
    required this.name,
    required this.period,
    required this.startsOn,
    required this.amountMinor,
    required this.currency,
    this.categoryIds = const <String>[],
    this.accountIds = const <String>[],
    this.rollover = false,
    this.alertThresholds = const <int>[80, 100],
    this.status = 'active',
    this.createdAt,
    this.updatedAt,
    this.revision = 0,
  });

  /// ULID.
  final String id;

  /// Display name.
  final String name;

  /// `weekly | monthly | custom`.
  final String period;

  /// ISO date (YYYY-MM-DD).
  final String startsOn;

  /// Cap in minor units.
  final int amountMinor;

  /// ISO 4217.
  final String currency;

  /// Categories the budget covers.
  final List<String> categoryIds;

  /// Accounts the budget covers.
  final List<String> accountIds;

  /// Whether unused budget rolls over.
  final bool rollover;

  /// Alert thresholds, percent of cap.
  final List<int> alertThresholds;

  /// `active | archived`.
  final String status;

  /// Server creation timestamp.
  final DateTime? createdAt;

  /// Server last-update timestamp.
  final DateTime? updatedAt;

  /// Optimistic-concurrency counter.
  final int revision;

  /// Parse from JSON.
  factory BudgetDto.fromJson(Map<String, dynamic> json) => BudgetDto(
        id: json['id'] as String,
        name: json['name'] as String,
        period: json['period'] as String,
        startsOn: (json['starts_on'] ?? '') as String,
        amountMinor: (json['amount_minor'] as num).toInt(),
        currency: json['currency'] as String,
        categoryIds:
            ((json['category_ids'] as List<dynamic>?) ?? const <dynamic>[])
                .map((dynamic e) => e as String)
                .toList(growable: false),
        accountIds:
            ((json['account_ids'] as List<dynamic>?) ?? const <dynamic>[])
                .map((dynamic e) => e as String)
                .toList(growable: false),
        rollover: (json['rollover'] as bool?) ?? false,
        alertThresholds:
            ((json['alert_thresholds'] as List<dynamic>?) ?? const <dynamic>[])
                .map((dynamic e) => (e as num).toInt())
                .toList(growable: false),
        status: (json['status'] as String?) ?? 'active',
        createdAt: json['created_at'] is String
            ? DateTime.parse(json['created_at'] as String)
            : null,
        updatedAt: json['updated_at'] is String
            ? DateTime.parse(json['updated_at'] as String)
            : null,
        revision: (json['revision'] as num?)?.toInt() ?? 0,
      );

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'period': period,
        'starts_on': startsOn,
        'amount_minor': amountMinor,
        'currency': currency,
        'category_ids': categoryIds,
        'account_ids': accountIds,
        'rollover': rollover,
        'alert_thresholds': alertThresholds,
        'status': status,
        if (createdAt != null)
          'created_at': createdAt!.toUtc().toIso8601String(),
        if (updatedAt != null)
          'updated_at': updatedAt!.toUtc().toIso8601String(),
        'revision': revision,
      };
}

/// Create-budget payload.
class CreateBudgetRequest {
  /// Default constructor.
  const CreateBudgetRequest({
    required this.name,
    required this.period,
    required this.startsOn,
    required this.amountMinor,
    required this.currency,
    this.categoryIds = const <String>[],
    this.accountIds = const <String>[],
    this.rollover = false,
    this.alertThresholds = const <int>[80, 100],
  });

  /// Name.
  final String name;

  /// Period.
  final String period;

  /// Start date (YYYY-MM-DD).
  final String startsOn;

  /// Cap minor units.
  final int amountMinor;

  /// Currency.
  final String currency;

  /// Category ids.
  final List<String> categoryIds;

  /// Account ids.
  final List<String> accountIds;

  /// Rollover.
  final bool rollover;

  /// Alert thresholds.
  final List<int> alertThresholds;

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'period': period,
        'starts_on': startsOn,
        'amount_minor': amountMinor,
        'currency': currency,
        'category_ids': categoryIds,
        'account_ids': accountIds,
        'rollover': rollover,
        'alert_thresholds': alertThresholds,
      };
}

/// Progress payload from `/budgets/{id}/progress`.
class BudgetProgressDto {
  /// Default constructor.
  const BudgetProgressDto({
    required this.budgetId,
    required this.periodStart,
    required this.periodEnd,
    required this.amountMinor,
    required this.spentMinor,
    required this.remainingMinor,
    required this.percent,
    required this.status,
    this.projectedOverrunMinor,
    this.daysLeft,
    this.dailyAvgMinor,
  });

  /// Budget id.
  final String budgetId;

  /// Period start date.
  final String periodStart;

  /// Period end date.
  final String periodEnd;

  /// Cap.
  final int amountMinor;

  /// Spent.
  final int spentMinor;

  /// Remaining.
  final int remainingMinor;

  /// Percent of cap consumed.
  final double percent;

  /// `ok | warning | exceeded`.
  final String status;

  /// Projected overrun.
  final int? projectedOverrunMinor;

  /// Days remaining in period.
  final int? daysLeft;

  /// Daily average spend.
  final int? dailyAvgMinor;

  /// Parse from JSON.
  factory BudgetProgressDto.fromJson(Map<String, dynamic> json) =>
      BudgetProgressDto(
        budgetId: json['budget_id'] as String,
        periodStart: json['period_start'] as String,
        periodEnd: json['period_end'] as String,
        amountMinor: (json['amount_minor'] as num).toInt(),
        spentMinor: (json['spent_minor'] as num).toInt(),
        remainingMinor: (json['remaining_minor'] as num).toInt(),
        percent: (json['percent'] as num).toDouble(),
        status: json['status'] as String,
        projectedOverrunMinor:
            (json['projected_overrun_minor'] as num?)?.toInt(),
        daysLeft: (json['days_left'] as num?)?.toInt(),
        dailyAvgMinor: (json['daily_avg_minor'] as num?)?.toInt(),
      );

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'budget_id': budgetId,
        'period_start': periodStart,
        'period_end': periodEnd,
        'amount_minor': amountMinor,
        'spent_minor': spentMinor,
        'remaining_minor': remainingMinor,
        'percent': percent,
        'status': status,
        if (projectedOverrunMinor != null)
          'projected_overrun_minor': projectedOverrunMinor,
        if (daysLeft != null) 'days_left': daysLeft,
        if (dailyAvgMinor != null) 'daily_avg_minor': dailyAvgMinor,
      };
}
