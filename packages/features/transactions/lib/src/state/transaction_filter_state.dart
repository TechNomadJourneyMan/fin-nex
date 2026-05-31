import 'package:equatable/equatable.dart';
import 'package:fnx_domain/fnx_domain.dart';

/// Lightweight, immutable filter snapshot used by [TransactionsController].
///
/// Mirrors the shape of [TransactionFilter] but exposes value equality so
/// providers can debounce identical updates.
class TransactionFilterState extends Equatable {
  /// Default constructor.
  const TransactionFilterState({
    this.from,
    this.to,
    this.accountIds = const <Ulid>[],
    this.categoryIds = const <Ulid>[],
    this.types = const <TransactionType>[],
    this.searchText,
  });

  /// Inclusive lower bound on `occurredAt` (UTC).
  final DateTime? from;

  /// Exclusive upper bound on `occurredAt` (UTC).
  final DateTime? to;

  /// Restrict to these accounts (empty = all).
  final List<Ulid> accountIds;

  /// Restrict to these categories (empty = all).
  final List<Ulid> categoryIds;

  /// Restrict to these transaction types (empty = all).
  final List<TransactionType> types;

  /// Free-text search on description (case-insensitive, client-side).
  final String? searchText;

  /// True when no filter is applied.
  bool get isEmpty =>
      from == null &&
      to == null &&
      accountIds.isEmpty &&
      categoryIds.isEmpty &&
      types.isEmpty &&
      (searchText == null || searchText!.trim().isEmpty);

  /// Returns a copy with the given fields replaced.
  TransactionFilterState copyWith({
    DateTime? from,
    DateTime? to,
    List<Ulid>? accountIds,
    List<Ulid>? categoryIds,
    List<TransactionType>? types,
    String? searchText,
    bool clearFrom = false,
    bool clearTo = false,
    bool clearSearch = false,
  }) {
    return TransactionFilterState(
      from: clearFrom ? null : (from ?? this.from),
      to: clearTo ? null : (to ?? this.to),
      accountIds: accountIds ?? this.accountIds,
      categoryIds: categoryIds ?? this.categoryIds,
      types: types ?? this.types,
      searchText: clearSearch ? null : (searchText ?? this.searchText),
    );
  }

  /// Projects this snapshot into the repository-facing [TransactionFilter].
  TransactionFilter toRepositoryFilter({int? limit, int? offset}) {
    return TransactionFilter(
      from: from,
      to: to,
      accountIds: accountIds,
      categoryIds: categoryIds,
      types: types.map((TransactionType t) => t.code).toList(growable: false),
      searchText: searchText,
      limit: limit,
      offset: offset,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        from,
        to,
        accountIds,
        categoryIds,
        types,
        searchText,
      ];
}
