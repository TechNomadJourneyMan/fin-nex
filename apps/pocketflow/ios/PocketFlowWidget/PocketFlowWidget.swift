// Pocket Flow home-screen widget (WidgetKit).
//
// Renders a small/medium widget showing the current balance and the next
// upcoming payment. Data is written by the Flutter app via the `home_widget`
// package into the shared app-group UserDefaults (group.kz.pocketflow.app);
// this extension reads the same keys.
//
// This file is ADDITIVE — it is not wired into the Xcode project automatically.
// See README.md in this folder for the one-time Xcode steps to add the widget
// target and the app group. The main app build is unaffected until then.

import WidgetKit
import SwiftUI

private let appGroupId = "group.kz.pocketflow.app"

// Keys must match WidgetBridge.toMap() in the Flutter app.
private enum WidgetKeys {
    static let balance = "balance"
    static let nextPaymentLabel = "nextPaymentLabel"
    static let nextPaymentDate = "nextPaymentDate"
    static let todaySpend = "todaySpend"
}

struct PocketFlowEntry: TimelineEntry {
    let date: Date
    let balance: String
    let nextPaymentLabel: String
    let nextPaymentDate: String
    let todaySpend: String
}

struct Provider: TimelineProvider {
    private func read() -> PocketFlowEntry {
        let defaults = UserDefaults(suiteName: appGroupId)
        return PocketFlowEntry(
            date: Date(),
            balance: defaults?.string(forKey: WidgetKeys.balance) ?? "—",
            nextPaymentLabel: defaults?.string(forKey: WidgetKeys.nextPaymentLabel) ?? "",
            nextPaymentDate: defaults?.string(forKey: WidgetKeys.nextPaymentDate) ?? "",
            todaySpend: defaults?.string(forKey: WidgetKeys.todaySpend) ?? "—"
        )
    }

    func placeholder(in context: Context) -> PocketFlowEntry {
        PocketFlowEntry(
            date: Date(),
            balance: "₸ 482 300",
            nextPaymentLabel: "Netflix · ₸ 4 990",
            nextPaymentDate: "2026-06-10",
            todaySpend: "₸ 3 200"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (PocketFlowEntry) -> Void) {
        completion(read())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PocketFlowEntry>) -> Void) {
        // Refresh roughly hourly; the app also pushes updates on data change.
        let next = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        completion(Timeline(entries: [read()], policy: .after(next)))
    }
}

struct PocketFlowWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Pocket Flow")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(entry.balance)
                .font(.title2.weight(.bold))
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            if !entry.nextPaymentLabel.isEmpty {
                Spacer(minLength: 2)
                Text("Next payment")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(entry.nextPaymentLabel)
                    .font(.footnote.weight(.semibold))
                    .lineLimit(1)
                if !entry.nextPaymentDate.isEmpty {
                    Text(entry.nextPaymentDate)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

@main
struct PocketFlowWidget: Widget {
    let kind: String = "PocketFlowWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                PocketFlowWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                PocketFlowWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Pocket Flow")
        .description("Your balance and next upcoming payment.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
