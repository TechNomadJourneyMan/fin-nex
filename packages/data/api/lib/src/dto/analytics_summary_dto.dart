/// Aggregate totals returned by `/analytics/summary`.
class AnalyticsTotalsDto {
  /// Default constructor.
  const AnalyticsTotalsDto({
    required this.incomeMinor,
    required this.expenseMinor,
    required this.netMinor,
    this.savingsRate,
  });

  /// Income in minor units.
  final int incomeMinor;

  /// Expense in minor units.
  final int expenseMinor;

  /// Net (income - expense) in minor units.
  final int netMinor;

  /// Savings rate (`net / income`), nullable when income is zero.
  final double? savingsRate;

  /// Parse from JSON.
  factory AnalyticsTotalsDto.fromJson(Map<String, dynamic> json) =>
      AnalyticsTotalsDto(
        incomeMinor: (json['income_minor'] as num?)?.toInt() ?? 0,
        expenseMinor: (json['expense_minor'] as num?)?.toInt() ?? 0,
        netMinor: (json['net_minor'] as num?)?.toInt() ?? 0,
        savingsRate: (json['savings_rate'] as num?)?.toDouble(),
      );

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'income_minor': incomeMinor,
        'expense_minor': expenseMinor,
        'net_minor': netMinor,
        if (savingsRate != null) 'savings_rate': savingsRate,
      };
}

/// Single time-series bucket.
class AnalyticsBucketDto {
  /// Default constructor.
  const AnalyticsBucketDto({
    required this.label,
    required this.incomeMinor,
    required this.expenseMinor,
  });

  /// Label, usually an ISO date.
  final String label;

  /// Income for this bucket.
  final int incomeMinor;

  /// Expense for this bucket.
  final int expenseMinor;

  /// Parse from JSON.
  factory AnalyticsBucketDto.fromJson(Map<String, dynamic> json) =>
      AnalyticsBucketDto(
        label: json['label'] as String,
        incomeMinor: (json['income_minor'] as num?)?.toInt() ?? 0,
        expenseMinor: (json['expense_minor'] as num?)?.toInt() ?? 0,
      );

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'label': label,
        'income_minor': incomeMinor,
        'expense_minor': expenseMinor,
      };
}

/// Full `/analytics/summary` response.
class AnalyticsSummaryDto {
  /// Default constructor.
  const AnalyticsSummaryDto({
    required this.from,
    required this.to,
    required this.currency,
    required this.totals,
    this.buckets = const <AnalyticsBucketDto>[],
  });

  /// Range start (YYYY-MM-DD).
  final String from;

  /// Range end (YYYY-MM-DD).
  final String to;

  /// ISO 4217.
  final String currency;

  /// Totals.
  final AnalyticsTotalsDto totals;

  /// Time series.
  final List<AnalyticsBucketDto> buckets;

  /// Parse from JSON.
  factory AnalyticsSummaryDto.fromJson(Map<String, dynamic> json) =>
      AnalyticsSummaryDto(
        from: (json['from'] ?? '') as String,
        to: (json['to'] ?? '') as String,
        currency: (json['currency'] ?? 'KZT') as String,
        totals: AnalyticsTotalsDto.fromJson(
          (json['totals'] as Map<String, dynamic>?) ??
              const <String, dynamic>{},
        ),
        buckets: ((json['buckets'] as List<dynamic>?) ?? const <dynamic>[])
            .map((dynamic e) =>
                AnalyticsBucketDto.fromJson(e as Map<String, dynamic>))
            .toList(growable: false),
      );

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'from': from,
        'to': to,
        'currency': currency,
        'totals': totals.toJson(),
        'buckets': buckets
            .map((AnalyticsBucketDto e) => e.toJson())
            .toList(growable: false),
      };
}

/// One row in the `/analytics/by-category` response.
class AnalyticsByCategoryItemDto {
  /// Default constructor.
  const AnalyticsByCategoryItemDto({
    required this.categoryId,
    required this.name,
    required this.amountMinor,
    required this.share,
    this.transactionCount = 0,
    this.changeVsPrevPeriod,
  });

  /// Category id.
  final String categoryId;

  /// Display name.
  final String name;

  /// Amount in minor units.
  final int amountMinor;

  /// Share of total (0..1).
  final double share;

  /// Count of transactions.
  final int transactionCount;

  /// Change vs previous period as a fraction (e.g. 0.18 = +18%).
  final double? changeVsPrevPeriod;

  /// Parse from JSON.
  factory AnalyticsByCategoryItemDto.fromJson(Map<String, dynamic> json) =>
      AnalyticsByCategoryItemDto(
        categoryId: json['category_id'] as String,
        name: json['name'] as String,
        amountMinor: (json['amount_minor'] as num).toInt(),
        share: (json['share'] as num).toDouble(),
        transactionCount: (json['transaction_count'] as num?)?.toInt() ?? 0,
        changeVsPrevPeriod: (json['change_vs_prev_period'] as num?)?.toDouble(),
      );

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'category_id': categoryId,
        'name': name,
        'amount_minor': amountMinor,
        'share': share,
        'transaction_count': transactionCount,
        if (changeVsPrevPeriod != null)
          'change_vs_prev_period': changeVsPrevPeriod,
      };
}

/// `/analytics/by-category` response.
class AnalyticsByCategoryDto {
  /// Default constructor.
  const AnalyticsByCategoryDto({
    required this.currency,
    required this.totalMinor,
    required this.categories,
    this.otherMinor = 0,
  });

  /// Currency.
  final String currency;

  /// Total amount.
  final int totalMinor;

  /// Per-category breakdown.
  final List<AnalyticsByCategoryItemDto> categories;

  /// Amount aggregated into "Other".
  final int otherMinor;

  /// Parse from JSON.
  factory AnalyticsByCategoryDto.fromJson(Map<String, dynamic> json) =>
      AnalyticsByCategoryDto(
        currency: (json['currency'] ?? 'KZT') as String,
        totalMinor: (json['total_minor'] as num?)?.toInt() ?? 0,
        categories: ((json['categories'] as List<dynamic>?) ??
                const <dynamic>[])
            .map((dynamic e) =>
                AnalyticsByCategoryItemDto.fromJson(e as Map<String, dynamic>))
            .toList(growable: false),
        otherMinor: (json['other_minor'] as num?)?.toInt() ?? 0,
      );

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'currency': currency,
        'total_minor': totalMinor,
        'categories': categories
            .map((AnalyticsByCategoryItemDto e) => e.toJson())
            .toList(growable: false),
        'other_minor': otherMinor,
      };
}

/// `/analytics/cashflow` response (simplified time series).
class CashflowDto {
  /// Default constructor.
  const CashflowDto({
    required this.currency,
    required this.buckets,
    this.cumulativeNetMinor = 0,
  });

  /// Currency.
  final String currency;

  /// Income/expense buckets.
  final List<AnalyticsBucketDto> buckets;

  /// Cumulative net over the range.
  final int cumulativeNetMinor;

  /// Parse from JSON.
  factory CashflowDto.fromJson(Map<String, dynamic> json) => CashflowDto(
        currency: (json['currency'] ?? 'KZT') as String,
        buckets: ((json['buckets'] as List<dynamic>?) ?? const <dynamic>[])
            .map((dynamic e) =>
                AnalyticsBucketDto.fromJson(e as Map<String, dynamic>))
            .toList(growable: false),
        cumulativeNetMinor:
            (json['cumulative_net_minor'] as num?)?.toInt() ?? 0,
      );

  /// Serialize to JSON.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'currency': currency,
        'buckets': buckets
            .map((AnalyticsBucketDto e) => e.toJson())
            .toList(growable: false),
        'cumulative_net_minor': cumulativeNetMinor,
      };
}
