// Riverpod providers for recurring transaction rules.
//
// The repository defaults to an in-memory implementation (consistent with the
// app's current in-memory pattern; persistence is F-DATA-WIRE). Calendar-sync
// wiring providers mirror the subscriptions feature and are overridden at app
// composition with the connected calendar id / toggle / locale.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_calendar/pf_calendar.dart';
import 'package:pf_domain/pf_domain.dart';

import '../providers.dart';
import 'in_memory_recurring_rules_repository.dart';
import 'recurring_calendar_sync.dart';

/// The [RecurringRulesRepository] used by this feature.
///
/// Defaults to an in-memory repo so the app and tests work without
/// persistence; the app may override it at bootstrap.
final recurringRulesRepositoryProvider =
    Provider<RecurringRulesRepository>((Ref ref) {
  final InMemoryRecurringRulesRepository repo =
      InMemoryRecurringRulesRepository();
  ref.onDispose(repo.dispose);
  return repo;
});

/// Streams the current user's recurring rules (live).
final recurringRulesProvider = StreamProvider<List<RecurringRule>>((Ref ref) {
  final RecurringRulesRepository repo =
      ref.watch(recurringRulesRepositoryProvider);
  final Ulid userId = ref.watch(currentUserIdProvider);
  return repo.watchAll(userId);
});

/// The [RecurringEngine] used to materialise due rules.
final recurringEngineProvider = Provider<RecurringEngine>((Ref ref) {
  return RecurringEngine(
    rules: ref.watch(recurringRulesRepositoryProvider),
    transactions: ref.watch(transactionsRepositoryProvider),
  );
});

// --- Calendar sync wiring (overridden at app composition) -----------------

/// The connected calendar id, or null. Overridden in app composition with the
/// persisted `pf_calendar_id` (shared with subscriptions / budgets).
final recurringRemindersCalendarIdProvider =
    Provider<String?>((Ref ref) => null);

/// Whether recurring-rule reminders are enabled globally. Overridden in app
/// composition from the settings reminder toggle.
final recurringRemindersEnabledProvider = Provider<bool>((Ref ref) => false);

/// BCP-47 locale tag used to format reminder titles. Overridden in app
/// composition with the active app locale.
final recurringRemindersLocaleProvider = Provider<String>((Ref ref) => 'en');

/// Composes a [RecurringCalendarSync] from the active providers.
final recurringCalendarSyncProvider =
    Provider<RecurringCalendarSync>((Ref ref) {
  return RecurringCalendarSync(
    reminderService: ref.watch(reminderServiceProvider),
    repository: ref.watch(recurringRulesRepositoryProvider),
    calendarId: ref.watch(recurringRemindersCalendarIdProvider),
    enabled: ref.watch(recurringRemindersEnabledProvider),
    locale: ref.watch(recurringRemindersLocaleProvider),
  );
});

/// Runs the recurring engine once for the current user, then refreshes the
/// calendar reminder for any rule that advanced. Safe to call on app start and
/// on manual "sync now" — the engine is idempotent.
Future<RecurringRunResult> runRecurringEngine(WidgetRef ref) async {
  final Ulid userId = ref.read(currentUserIdProvider);
  final RecurringEngine engine = ref.read(recurringEngineProvider);
  final RecurringRunResult result = await engine.run(userId);

  if (result.advancedRuleIds.isNotEmpty) {
    final RecurringRulesRepository repo =
        ref.read(recurringRulesRepositoryProvider);
    final RecurringCalendarSync sync = ref.read(recurringCalendarSyncProvider);
    for (final Ulid id in result.advancedRuleIds) {
      final RecurringRule? rule = await repo.getById(id);
      if (rule != null) {
        await sync.sync(rule, wantsSync: rule.calendarEventId != null);
      }
    }
  }
  return result;
}
