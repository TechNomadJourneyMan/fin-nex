# Pocket Flow — iOS home-screen widget (WidgetKit)

This folder contains the Swift sources for the Pocket Flow WidgetKit extension.
It is **additive**: the files are not yet wired into `Runner.xcodeproj`, so the
normal app build is unaffected. Wiring it up is a one-time manual Xcode step
(WidgetKit targets cannot be added from the command line / Flutter tooling).

## What the widget shows

A small/medium widget with the current balance and the next upcoming payment.
The data is written by the Flutter app through the `home_widget` package into a
shared **app group** (`group.kz.pocketflow.app`); `Provider` in
`PocketFlowWidget.swift` reads the same keys:

| Key                | Meaning                                  |
|--------------------|------------------------------------------|
| `balance`          | Pre-formatted total balance              |
| `nextPaymentLabel` | "Merchant · amount" of the next payment  |
| `nextPaymentDate`  | ISO date (yyyy-MM-dd) of the next payment|
| `todaySpend`       | Pre-formatted spend so far today         |

These match `WidgetBridge.toMap()` /
`WidgetPayload` in `lib/services/widget_bridge.dart`.

## One-time Xcode setup

1. Open `apps/pocketflow/ios/Runner.xcworkspace` in Xcode.
2. **File ▸ New ▸ Target… ▸ Widget Extension**. Name it `PocketFlowWidget`
   (must match the `kind` string and the `iOSName` passed to
   `HomeWidget.updateWidget`). Uncheck "Include Configuration Intent".
3. Delete the auto-generated `.swift` and `Info.plist` Xcode created and instead
   **add the files already in this folder** (`PocketFlowWidget.swift`,
   `Info.plist`, `PocketFlowWidget.entitlements`) to the new target.
4. Add the **App Groups** capability to BOTH the `Runner` target and the
   `PocketFlowWidget` target, and enable the group `group.kz.pocketflow.app`.
   (`Runner.entitlements` should also gain the group — the widget's
   `.entitlements` here already declares it.)
5. Set the widget target's iOS deployment target to **16.0** to match the app.
6. Build & run on a device or simulator, then long-press the home screen ▸ add
   the **Pocket Flow** widget.

## Notes

- The app pushes updates on balance / transaction / subscription change via
  `WidgetBridge.update()` (see `home_surface_updater.dart`). WidgetKit also
  refreshes on its own ~hourly timeline.
- If the group id is changed, update it in three places: this Swift file, both
  `.entitlements`, and `WidgetBridge.appGroupId`.
