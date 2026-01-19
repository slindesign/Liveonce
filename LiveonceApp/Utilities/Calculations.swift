import Foundation

struct LifeWeeksMetrics {
    let totalWeeks: Int
    let usedWeeks: Int
    let remainingWeeks: Int
    let progress: Double
}

enum LifeCalculator {
    static func lifeWeeksMetrics(birthDate: Date, lifeExpectancyYears: Int, today: Date = Date(), calendar: Calendar = .current) -> LifeWeeksMetrics {
        let totalWeeks = max(lifeExpectancyYears * 52, 1)
        let days = calendar.dateComponents([.day], from: birthDate.startOfDay(using: calendar), to: today.startOfDay(using: calendar)).day ?? 0
        let usedWeeks = max(days / 7, 0)
        let remainingWeeks = max(totalWeeks - usedWeeks, 0)
        let progress = min(Double(usedWeeks) / Double(totalWeeks), 1.0)
        return LifeWeeksMetrics(totalWeeks: totalWeeks, usedWeeks: usedWeeks, remainingWeeks: remainingWeeks, progress: progress)
    }
}

enum BudgetCalculator {
    static func adherenceScore(plans: [BudgetPlan], logs: [TimeLog], periodStart: Date, calendar: Calendar = .current) -> Int {
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: periodStart) ?? periodStart
        let logsByBucket = Dictionary(grouping: logs.filter { log in
            log.date >= periodStart && log.date < weekEnd
        }, by: { $0.bucket?.id })

        var totalPlanned = 0
        var weightedSum: Double = 0
        var plannedBuckets = 0

        for plan in plans {
            guard let bucketId = plan.bucket?.id else { continue }
            let planned = plan.plannedMinutes
            let actual = logsByBucket[bucketId]?.reduce(0, { $0 + $1.minutes }) ?? 0
            let ratio: Double
            if planned == 0 {
                ratio = actual == 0 ? 1.0 : 0.0
            } else {
                ratio = min(Double(actual) / Double(planned), 1.2)
            }
            if planned > 0 {
                totalPlanned += planned
                weightedSum += ratio * Double(planned)
            } else {
                plannedBuckets += 1
                weightedSum += ratio
            }
        }

        let average: Double
        if totalPlanned > 0 {
            average = weightedSum / Double(totalPlanned)
        } else if plannedBuckets > 0 {
            average = weightedSum / Double(plannedBuckets)
        } else {
            average = 0
        }

        return Int(min(average, 1.0) * 100)
    }

    static func totalScore(adherence: Int, priority: Int, rhythm: Int) -> Int {
        let adherenceScore = Double(adherence)
        let priorityScore = Double(priority) / 5.0 * 100.0
        let rhythmScore = Double(rhythm) / 5.0 * 100.0
        let total = adherenceScore * 0.6 + priorityScore * 0.25 + rhythmScore * 0.15
        return Int(total.rounded())
    }
}
