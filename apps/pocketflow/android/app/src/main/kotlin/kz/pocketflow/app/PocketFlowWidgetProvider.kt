package kz.pocketflow.app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * Pocket Flow home-screen widget (AppWidget / RemoteViews).
 *
 * Reads the snapshot the Flutter app wrote via the `home_widget` package
 * (`HomeWidgetPlugin.getData`) and renders balance + next payment. The keys
 * match `WidgetBridge.toMap()` in lib/services/widget_bridge.dart.
 *
 * This file is ADDITIVE. The manifest receiver + layout are checked in, but the
 * project cannot be built in this environment (no Android SDK). See
 * README-widget.md for the verification steps on a machine with the SDK.
 */
class PocketFlowWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val prefs = HomeWidgetPlugin.getData(context)
        val balance = prefs.getString("balance", "—") ?: "—"
        val nextLabel = prefs.getString("nextPaymentLabel", "") ?: ""
        val nextDate = prefs.getString("nextPaymentDate", "") ?: ""

        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.pocketflow_widget).apply {
                setTextViewText(R.id.pf_widget_balance, balance)
                if (nextLabel.isEmpty()) {
                    setViewVisibility(R.id.pf_widget_next_group, android.view.View.GONE)
                } else {
                    setViewVisibility(R.id.pf_widget_next_group, android.view.View.VISIBLE)
                    setTextViewText(R.id.pf_widget_next_label, nextLabel)
                    setTextViewText(R.id.pf_widget_next_date, nextDate)
                }
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
