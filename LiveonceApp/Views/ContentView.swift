import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var didSeed = false

    var body: some View {
        TabView {
            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }

            BudgetView()
                .tabItem {
                    Label("Budget", systemImage: "list.bullet.rectangle")
                }

            ExecuteView()
                .tabItem {
                    Label("Execute", systemImage: "timer")
                }

            ScoreView()
                .tabItem {
                    Label("Score", systemImage: "chart.bar")
                }
        }
        .task {
            guard !didSeed else { return }
            didSeed = true
            do {
                try SeedData.ensureSeedData(modelContext: modelContext)
                WidgetSummaryUpdater.refresh(modelContext: modelContext)
            } catch {
                print("Failed to seed data: \(error)")
            }
        }
    }
}
