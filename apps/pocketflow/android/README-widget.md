# Pocket Flow — Android home-screen widget (AppWidget)

This scaffold adds a classic `AppWidgetProvider` (RemoteViews) widget that
mirrors the iOS WidgetKit widget: it shows the current balance and the next
upcoming payment, read from the data the Flutter app writes via the
`home_widget` package.

> **Cannot be built in this environment** — the Android SDK is not installed
> here. The code/config below is checked in and ready; build & verify it on a
> machine with the Android SDK.

## Files

| File | Purpose |
|------|---------|
| `app/src/main/kotlin/kz/pocketflow/app/PocketFlowWidgetProvider.kt` | AppWidget provider; reads `HomeWidgetPlugin.getData`. |
| `app/src/main/res/layout/pocketflow_widget.xml` | Widget layout. |
| `app/src/main/res/drawable/pocketflow_widget_background.xml` | Rounded background. |
| `app/src/main/res/xml/pocketflow_widget_info.xml` | AppWidget metadata. |
| `app/src/main/AndroidManifest.xml` | `<receiver>` registration. |

Keys read by the provider (`balance`, `nextPaymentLabel`, `nextPaymentDate`)
match `WidgetBridge.toMap()` in `lib/services/widget_bridge.dart`.

## Verify (with Android SDK)

```bash
cd apps/pocketflow
flutter pub get
flutter build apk --debug      # resolves the home_widget Gradle plugin
flutter install
# Long-press the home screen ▸ Widgets ▸ Pocket Flow ▸ drag onto the screen.
```

The app pushes updates via `WidgetBridge.update()` (see
`home_surface_updater.dart`); the widget also refreshes ~hourly per
`updatePeriodMillis`.

## Optional: Glance

For a Jetpack-Compose Glance implementation instead of RemoteViews, swap the
provider for a `GlanceAppWidget` + `GlanceAppWidgetReceiver` and add the
`androidx.glance:glance-appwidget` dependency. The data contract (the three
keys above) is unchanged.
