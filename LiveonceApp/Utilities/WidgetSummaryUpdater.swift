import Foundation
import SwiftData
import WidgetKit

@MainActor
enum WidgetSummaryUpdater {
    static func refresh(modelContext: ModelContext) {
        let calendar = Calendar.current
        guard let profile = try? modelContext.fetch(FetchDescriptor<UserProfile>()).first else {
            return
        }
        let metrics = LifeCalculator.lifeWeeksMetrics(birthDate: profile.birthDate, lifeExpectancyYears: profile.lifeExpectancyYears)
        let startOfWeek = calendar.startOfWeek(for: Date())
        let planFetch = FetchDescriptor<BudgetPlan>()
        let logFetch = FetchDescriptor<TimeLog>()
        let plans = (try? modelContext.fetch(planFetch)) ?? []
        let logs = (try? modelContext.fetch(logFetch)) ?? []
        let adherence = BudgetCalculator.adherenceScore(plans: plans, logs: logs, periodStart: startOfWeek)

        let summary = WidgetSummary(
            remainingWeeks: metrics.remainingWeeks,
            progressPercent: Int((metrics.progress * 100).rounded()),
            weekAdherencePercent: adherence,
            lastUpdated: Date()
        )
        WidgetSummaryStore.save(summary)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
