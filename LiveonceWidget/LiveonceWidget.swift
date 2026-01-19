import WidgetKit
import SwiftUI

struct LifeRemainingEntry: TimelineEntry {
    let date: Date
    let summary: WidgetSummary
}

struct LifeRemainingProvider: TimelineProvider {
    func placeholder(in context: Context) -> LifeRemainingEntry {
        LifeRemainingEntry(date: Date(), summary: WidgetSummary(remainingWeeks: 1234, progressPercent: 45, weekAdherencePercent: 60, lastUpdated: Date()))
    }

    func getSnapshot(in context: Context, completion: @escaping (LifeRemainingEntry) -> Void) {
        let summary = WidgetSummaryStore.load() ?? WidgetSummary(remainingWeeks: 1234, progressPercent: 45, weekAdherencePercent: 60, lastUpdated: Date())
        completion(LifeRemainingEntry(date: Date(), summary: summary))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LifeRemainingEntry>) -> Void) {
        let summary = WidgetSummaryStore.load() ?? WidgetSummary(remainingWeeks: 0, progressPercent: 0, weekAdherencePercent: 0, lastUpdated: Date())
        let entry = LifeRemainingEntry(date: Date(), summary: summary)
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 4, to: Date()) ?? Date().addingTimeInterval(4 * 3600)
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

struct LifeRemainingWidgetView: View {
    let entry: LifeRemainingEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Life Remaining")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("Remaining: \(entry.summary.remainingWeeks)w")
                .font(.headline)
            Text("Progress: \(entry.summary.progressPercent)%")
                .font(.subheadline)
            Text("Week adherence: \(entry.summary.weekAdherencePercent)%")
                .font(.subheadline)
        }
        .padding()
    }
}

@main
struct LifeRemainingWidget: Widget {
    let kind = "LifeRemainingWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LifeRemainingProvider()) { entry in
            LifeRemainingWidgetView(entry: entry)
        }
        .configurationDisplayName("Life Remaining")
        .description("Remaining weeks and weekly adherence.")
        .supportedFamilies([.systemSmall])
    }
}
