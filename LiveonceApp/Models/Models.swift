import Foundation
import SwiftData

@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID
    var birthDate: Date
    var lifeExpectancyYears: Int
    var preferredUnit: String
    var createdAt: Date
    var updatedAt: Date

    init(birthDate: Date, lifeExpectancyYears: Int, preferredUnit: String) {
        self.id = UUID()
        self.birthDate = birthDate
        self.lifeExpectancyYears = lifeExpectancyYears
        self.preferredUnit = preferredUnit
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

@Model
final class Purpose {
    @Attribute(.unique) var id: UUID
    var name: String
    var order: Int
    @Relationship(deleteRule: .cascade) var buckets: [Bucket]

    init(name: String, order: Int, buckets: [Bucket] = []) {
        self.id = UUID()
        self.name = name
        self.order = order
        self.buckets = buckets
    }
}

@Model
final class Bucket {
    @Attribute(.unique) var id: UUID
    var name: String
    var order: Int
    var icon: String
    var colorHex: String
    var purpose: Purpose?

    init(name: String, order: Int, icon: String, colorHex: String, purpose: Purpose? = nil) {
        self.id = UUID()
        self.name = name
        self.order = order
        self.icon = icon
        self.colorHex = colorHex
        self.purpose = purpose
    }
}

@Model
final class BudgetPlan {
    @Attribute(.unique) var id: UUID
    var periodType: String
    var periodStart: Date
    var plannedMinutes: Int
    var bucket: Bucket?

    init(periodType: String, periodStart: Date, plannedMinutes: Int, bucket: Bucket?) {
        self.id = UUID()
        self.periodType = periodType
        self.periodStart = periodStart
        self.plannedMinutes = plannedMinutes
        self.bucket = bucket
    }
}

@Model
final class TimeLog {
    @Attribute(.unique) var id: UUID
    var date: Date
    var minutes: Int
    var note: String?
    var bucket: Bucket?

    init(date: Date, minutes: Int, note: String?, bucket: Bucket?) {
        self.id = UUID()
        self.date = date
        self.minutes = minutes
        self.note = note
        self.bucket = bucket
    }
}

@Model
final class ScoreEntry {
    @Attribute(.unique) var id: UUID
    var periodType: String
    var periodStart: Date
    var budgetAdherenceScore: Int
    var priorityRating: Int
    var rhythmRating: Int
    var totalScore: Int
    var note: String?

    init(periodType: String, periodStart: Date, budgetAdherenceScore: Int, priorityRating: Int, rhythmRating: Int, totalScore: Int, note: String?) {
        self.id = UUID()
        self.periodType = periodType
        self.periodStart = periodStart
        self.budgetAdherenceScore = budgetAdherenceScore
        self.priorityRating = priorityRating
        self.rhythmRating = rhythmRating
        self.totalScore = totalScore
        self.note = note
    }
}
