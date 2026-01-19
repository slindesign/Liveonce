import Foundation

struct WidgetSummary: Codable {
    let remainingWeeks: Int
    let progressPercent: Int
    let weekAdherencePercent: Int
    let lastUpdated: Date
}

enum AppGroup {
    static let identifier = "group.com.song.liveonce"
    static let summaryKey = "widgetSummary"
}

enum WidgetSummaryStore {
    static func load() -> WidgetSummary? {
        guard let defaults = UserDefaults(suiteName: AppGroup.identifier),
              let data = defaults.data(forKey: AppGroup.summaryKey) else {
            return nil
        }
        return try? JSONDecoder().decode(WidgetSummary.self, from: data)
    }

    static func save(_ summary: WidgetSummary) {
        guard let defaults = UserDefaults(suiteName: AppGroup.identifier),
              let data = try? JSONEncoder().encode(summary) else {
            return
        }
        defaults.set(data, forKey: AppGroup.summaryKey)
    }
}
