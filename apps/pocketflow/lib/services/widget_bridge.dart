// Home-screen widget bridge.
//
// Pushes a small snapshot — balance, next payment, today's spend — into the
// native widget storage (shared UserDefaults app-group on iOS, SharedPreferences
// on Android) via the `home_widget` package, then asks the OS to redraw the
// widget. Everything is guarded with [kIsWeb] so the web build is a no-op.
//
// The payload is modelled as a pure value type ([WidgetPayload]) so its
// serialization can be unit-tested without any platform calls.

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

/// Immutable snapshot rendered by the home-screen widget.
@immutable
class WidgetPayload {
  /// Creates a widget payload.
  const WidgetPayload({
    required this.balance,
    required this.nextPaymentLabel,
    required this.nextPaymentDate,
    required this.todaySpend,
  });

  /// Pre-formatted total balance (e.g. "₸ 482 300").
  final String balance;

  /// Next upcoming payment label (e.g. "Netflix") or empty when none.
  final String nextPaymentLabel;

  /// Next payment date as an ISO-8601 date (yyyy-MM-dd) or empty when none.
  final String nextPaymentDate;

  /// Pre-formatted spend so far today (e.g. "₸ 3 200").
  final String todaySpend;

  /// Flat string map written to the native widget store. Keys must match the
  /// native widget code (iOS WidgetKit / Android Glance).
  Map<String, String> toMap() => <String, String>{
        'balance': balance,
        'nextPaymentLabel': nextPaymentLabel,
        'nextPaymentDate': nextPaymentDate,
        'todaySpend': todaySpend,
      };

  @override
  bool operator ==(Object other) =>
      other is WidgetPayload &&
      other.balance == balance &&
      other.nextPaymentLabel == nextPaymentLabel &&
      other.nextPaymentDate == nextPaymentDate &&
      other.todaySpend == todaySpend;

  @override
  int get hashCode =>
      Object.hash(balance, nextPaymentLabel, nextPaymentDate, todaySpend);
}

/// Writes [WidgetPayload]s to the native widget store and triggers a redraw.
class WidgetBridge {
  /// Creates a bridge.
  ///
  /// [appGroupId] must match the iOS app group configured on both the app and
  /// the WidgetKit extension target.
  const WidgetBridge({
    this.appGroupId = 'group.kz.pocketflow.app',
    this.iosWidgetName = 'PocketFlowWidget',
    this.androidWidgetName = 'PocketFlowWidgetProvider',
  });

  /// iOS app group id shared between the app and the widget extension.
  final String appGroupId;

  /// iOS WidgetKit widget kind / name.
  final String iosWidgetName;

  /// Android AppWidgetProvider class name.
  final String androidWidgetName;

  /// Pushes [payload] to the native store and requests a widget update.
  ///
  /// No-op on Web. Failures are swallowed (a missing widget target must never
  /// crash the app) but logged in debug.
  Future<void> update(WidgetPayload payload) async {
    if (kIsWeb) return;
    try {
      await HomeWidget.setAppGroupId(appGroupId);
      for (final entry in payload.toMap().entries) {
        await HomeWidget.saveWidgetData<String>(entry.key, entry.value);
      }
      await HomeWidget.updateWidget(
        iOSName: iosWidgetName,
        androidName: androidWidgetName,
      );
    } catch (e) {
      debugPrint('[WidgetBridge] update failed: $e');
    }
  }
}
