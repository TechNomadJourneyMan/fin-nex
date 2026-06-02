// Wires the two "home surfaces" — the OS home-screen widget and the local
// payment-push notifications — to the app's live data.
//
// Both surfaces derive from the same inputs (the dashboard snapshot for
// balance / today-spend, the detected subscriptions for upcoming payments), so
// they're refreshed together by [HomeSurfaceUpdater.refresh]. The app installs
// a listener that calls [refresh] whenever the dashboard or subscriptions
// change. Everything is a no-op on web (the widget bridge and the native
// notifications service both no-op there).

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pf_core_widgets/pf_core_widgets.dart';
import 'package:pf_feat_dashboard/dashboard.dart' as dashboard;
import 'package:pf_feat_notifications/pf_feat_notifications.dart' as notif;
import 'package:pf_feat_settings/settings.dart' as settings;
import 'package:pf_feat_subscriptions/subscriptions.dart' as subs;

import 'share_service.dart';
import 'widget_bridge.dart';

/// Singleton [WidgetBridge] for the running app.
final widgetBridgeProvider = Provider<WidgetBridge>((ref) {
  return const WidgetBridge();
});

/// Singleton [ShareService] for the running app.
final shareServiceProvider = Provider<ShareService>((ref) {
  return const ShareService();
});

/// Composes the home-surface updater from the active providers.
final homeSurfaceUpdaterProvider = Provider<HomeSurfaceUpdater>((ref) {
  return HomeSurfaceUpdater(ref);
});

/// Pushes balance / next-payment / today-spend to the widget and rebuilds the
/// local payment-reminder notifications.
class HomeSurfaceUpdater {
  /// Creates an updater bound to [_ref].
  HomeSurfaceUpdater(this._ref);

  final Ref _ref;

  /// Recomputes both surfaces from current state.
  ///
  /// Best-effort: never throws (a widget/notification failure must not break
  /// the app). [now] is injectable for tests.
  Future<void> refresh({DateTime? now}) async {
    final clock = now ?? DateTime.now();
    final locale = _ref.read(settings.localeProvider)?.toLanguageTag() ?? 'en';

    // Detected subscriptions → reminder inputs (active only, future-dated).
    final subsAsync = _ref.read(subs.detectedSubscriptionsStreamProvider);
    final subscriptions = subsAsync.asData?.value ?? const [];
    final inputs = <notif.PaymentReminderInput>[];
    for (final s in subscriptions) {
      if (!s.isActive) continue;
      inputs.add(
        notif.PaymentReminderInput(
          sourceId: 'subscription:${s.id.value}',
          title: s.merchantName,
          amountLabel: formatPfAmount(
            s.amount.minor.toInt(),
            locale: locale,
            fractionDigits: 0,
            currencySymbol: s.amount.currency.symbol,
          ),
          dueDate: s.nextBillingDate.toLocal(),
        ),
      );
    }

    // Rebuild local notifications.
    try {
      final sync = _ref.read(notif.paymentReminderSyncProvider);
      await sync.sync(
        inputs,
        now: clock,
        copy: _ref.read(notif.paymentReminderCopyProvider),
      );
    } catch (e) {
      debugPrint('[HomeSurfaceUpdater] notification sync failed: $e');
    }

    // Push the home-screen widget payload.
    try {
      final snapshot = _ref.read(dashboard.dashboardControllerProvider).asData;
      String balance = '';
      String todaySpend = '';
      if (snapshot != null) {
        final s = snapshot.value;
        balance = formatPfAmount(
          s.totalBalance.minor.toInt(),
          locale: locale,
          fractionDigits: 0,
          currencySymbol: s.totalBalance.currency.symbol,
        );
        // The dashboard's period expense is the closest cheap proxy; when the
        // active period is "today" it is exactly today's spend.
        todaySpend = formatPfAmount(
          s.periodExpense.minor.toInt(),
          locale: locale,
          fractionDigits: 0,
          currencySymbol: s.periodExpense.currency.symbol,
        );
      }

      // Earliest upcoming payment for the widget's "next payment" line.
      String nextLabel = '';
      String nextDate = '';
      if (inputs.isNotEmpty) {
        final sorted = [...inputs]
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
        final next = sorted.firstWhere(
          (i) =>
              !i.dueDate.isBefore(DateTime(clock.year, clock.month, clock.day)),
          orElse: () => sorted.first,
        );
        nextLabel = '${next.title} · ${next.amountLabel}';
        nextDate =
            '${next.dueDate.year.toString().padLeft(4, '0')}-${next.dueDate.month.toString().padLeft(2, '0')}-${next.dueDate.day.toString().padLeft(2, '0')}';
      }

      await _ref.read(widgetBridgeProvider).update(
            WidgetPayload(
              balance: balance,
              nextPaymentLabel: nextLabel,
              nextPaymentDate: nextDate,
              todaySpend: todaySpend,
            ),
          );
    } catch (e) {
      debugPrint('[HomeSurfaceUpdater] widget update failed: $e');
    }
  }
}
