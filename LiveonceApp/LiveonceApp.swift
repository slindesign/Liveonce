import SwiftUI
import SwiftData

@main
struct LiveonceApp: App {
    private let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: UserProfile.self, Purpose.self, Bucket.self, BudgetPlan.self, TimeLog.self, ScoreEntry.self)
        } catch {
            fatalError("Failed to create model container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
