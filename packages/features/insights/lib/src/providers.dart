import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_domain/domain.dart';

import 'controllers/insights_controller.dart';
import 'engine/insight_engine.dart';

/// Active user id; expected to be overridden by the app shell.
final insightsUserIdProvider = Provider<Ulid>((ref) {
  throw UnimplementedError(
    'insightsUserIdProvider must be overridden at the app level.',
  );
});

/// Pure-Dart insight engine.
final insightEngineProvider = Provider<InsightEngine>(
  (ref) => const InsightEngine(),
);

/// Data source for insight inputs. Defaults to an in-memory empty source so the
/// feature stays self-contained; the app layer overrides this with a Drift-
/// backed implementation.
final insightsDataSourceProvider = Provider<InsightsDataSource>(
  (ref) => _EmptyInsightsDataSource(),
);

/// Insights feed state.
final insightsControllerProvider =
    StateNotifierProvider<InsightsController, InsightsState>((ref) {
  return InsightsController(
    engine: ref.watch(insightEngineProvider),
    dataSource: ref.watch(insightsDataSourceProvider),
    userId: ref.watch(insightsUserIdProvider),
  );
});

class _EmptyInsightsDataSource implements InsightsDataSource {
  // TODO(F-INSIGHTS): replace with Drift-backed data source.
  @override
  Future<List<Transaction>> transactions() async => const <Transaction>[];

  @override
  Future<List<Budget>> budgets() async => const <Budget>[];

  @override
  Future<List<Category>> categories() async => const <Category>[];

  @override
  Future<Streak?> streak() async => null;
}
