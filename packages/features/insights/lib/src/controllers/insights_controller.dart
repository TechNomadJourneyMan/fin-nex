import 'dart:async';

import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fnx_domain/domain.dart';

import '../engine/insight_engine.dart';
import '../engine/rule_context.dart';

/// In-memory data source the controller pulls from. Real apps wire this up to
/// Drift queries; tests pass synthetic data.
abstract interface class InsightsDataSource {
  /// Recent transactions (typically last 180 days).
  Future<List<Transaction>> transactions();

  /// Active budgets.
  Future<List<Budget>> budgets();

  /// Known categories (used for naming).
  Future<List<Category>> categories();

  /// Current streak, if any.
  Future<Streak?> streak();
}

/// Immutable view-state for the insights feed page.
@immutable
class InsightsState {
  /// Default constructor.
  const InsightsState({
    required this.items,
    this.isLoading = false,
    this.lastGeneratedAt,
  });

  /// Empty initial state.
  const InsightsState.initial()
      : items = const <Insight>[],
        isLoading = true,
        lastGeneratedAt = null;

  /// Currently visible (not dismissed) insights.
  final List<Insight> items;

  /// Whether a regeneration is in flight.
  final bool isLoading;

  /// Last successful generation timestamp.
  final DateTime? lastGeneratedAt;

  /// Convenience copy.
  InsightsState copyWith({
    List<Insight>? items,
    bool? isLoading,
    DateTime? lastGeneratedAt,
  }) =>
      InsightsState(
        items: items ?? this.items,
        isLoading: isLoading ?? this.isLoading,
        lastGeneratedAt: lastGeneratedAt ?? this.lastGeneratedAt,
      );
}

/// Controller for the insights feed. Periodically regenerates the feed on
/// Web via [Timer.periodic]; real background execution is platform-specific
/// and lives behind a future TODO.
class InsightsController extends StateNotifier<InsightsState> {
  /// Default constructor.
  InsightsController({
    required InsightEngine engine,
    required InsightsDataSource dataSource,
    required Ulid userId,
    Duration interval = const Duration(minutes: 30),
    DateTime Function() clock = _defaultClock,
  })  : _engine = engine,
        _dataSource = dataSource,
        _userId = userId,
        _interval = interval,
        _clock = clock,
        super(const InsightsState.initial()) {
    // Initial run, then schedule periodic regeneration.
    unawaited(regenerate());
    _timer = Timer.periodic(_interval, (_) => unawaited(regenerate()));
  }

  final InsightEngine _engine;
  final InsightsDataSource _dataSource;
  final Ulid _userId;
  final Duration _interval;
  final DateTime Function() _clock;
  final Map<String, DateTime> _dismissals = <String, DateTime>{};

  Timer? _timer;

  static DateTime _defaultClock() => DateTime.now().toUtc();

  /// Forces an immediate regeneration.
  Future<void> regenerate() async {
    final transactions = await _dataSource.transactions();
    final budgets = await _dataSource.budgets();
    final categories = await _dataSource.categories();
    final streak = await _dataSource.streak();
    final ctx = RuleContext(
      userId: _userId,
      transactions: transactions,
      budgets: budgets,
      categories: categories,
      streak: streak,
      currentDate: _clock(),
      dismissals: Map<String, DateTime>.from(_dismissals),
    );
    final items = _engine.run(ctx);
    state = state.copyWith(
      items: items,
      isLoading: false,
      lastGeneratedAt: ctx.currentDate,
    );
  }

  /// Hides [insight] for 30 days (suppression is rule-key scoped).
  Future<void> dismiss(Insight insight) async {
    _dismissals[insight.kind] = _clock();
    state = state.copyWith(
      items: state.items.where((i) => i.id != insight.id).toList(
            growable: false,
          ),
    );
  }

  /// Marks an insight as acted-upon. Locally this is equivalent to dismissal,
  /// but tests can override.
  Future<void> markActed(Insight insight) async {
    await dismiss(insight);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
