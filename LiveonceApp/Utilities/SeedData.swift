import Foundation
import SwiftData

@MainActor
enum SeedData {
    static func ensureSeedData(modelContext: ModelContext) throws {
        let profileFetch = FetchDescriptor<UserProfile>()
        let profiles = try modelContext.fetch(profileFetch)
        if profiles.isEmpty {
            let profile = UserProfile(birthDate: dateFromComponents(year: 1990, month: 1, day: 1), lifeExpectancyYears: 80, preferredUnit: "week")
            modelContext.insert(profile)
        }

        let purposeFetch = FetchDescriptor<Purpose>()
        let purposes = try modelContext.fetch(purposeFetch)
        if purposes.isEmpty {
            let freedom = Purpose(name: "自由度", order: 0)
            let creation = Purpose(name: "创造与作品", order: 1)
            let family = Purpose(name: "家庭与健康", order: 2)

            let buckets = [
                Bucket(name: "作品/创造", order: 0, icon: "pencil", colorHex: "#5B8FF9", purpose: creation),
                Bucket(name: "健康", order: 1, icon: "heart", colorHex: "#E76F51", purpose: family),
                Bucket(name: "家庭", order: 2, icon: "house", colorHex: "#2A9D8F", purpose: family),
                Bucket(name: "财富系统", order: 3, icon: "banknote", colorHex: "#F4A261", purpose: freedom),
                Bucket(name: "探索", order: 4, icon: "airplane", colorHex: "#8E9AAF", purpose: freedom)
            ]

            freedom.buckets = buckets.filter { $0.purpose === freedom }
            creation.buckets = buckets.filter { $0.purpose === creation }
            family.buckets = buckets.filter { $0.purpose === family }

            modelContext.insert(freedom)
            modelContext.insert(creation)
            modelContext.insert(family)
            buckets.forEach { modelContext.insert($0) }
        }
    }

    private static func dateFromComponents(year: Int, month: Int, day: Int) -> Date {
        let calendar = Calendar.current
        let components = DateComponents(year: year, month: month, day: day)
        return calendar.date(from: components) ?? Date()
    }
}
