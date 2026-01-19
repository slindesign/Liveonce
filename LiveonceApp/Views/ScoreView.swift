import SwiftUI
import SwiftData

struct ScoreView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ScoreEntry.periodStart, order: .reverse) private var entries: [ScoreEntry]
    @Query private var plans: [BudgetPlan]
    @Query private var logs: [TimeLog]

    @State private var priorityRating: Int = 3
    @State private var rhythmRating: Int = 3
    @State private var note: String = ""

    private let calendar = Calendar.current

    var body: some View {
        NavigationStack {
            Form {
                Section("Today Score") {
                    let adherence = adherenceScore()
                    Text("Budget Adherence: \(adherence)%")

                    RatingPicker(title: "Priority", rating: $priorityRating)
                    RatingPicker(title: "Rhythm", rating: $rhythmRating)

                    TextField("Note", text: $note)

                    Button("Save Score") {
                        saveScore(adherence: adherence)
                    }
                }

                Section("History") {
                    ForEach(entries.prefix(30)) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.periodStart, style: .date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("Total: \(entry.totalScore)")
                                .fontWeight(.semibold)
                            Text("Adherence \(entry.budgetAdherenceScore)% · Priority \(entry.priorityRating)/5 · Rhythm \(entry.rhythmRating)/5")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Score")
        }
    }

    private func adherenceScore() -> Int {
        let startOfWeek = calendar.startOfWeek(for: Date())
        return BudgetCalculator.adherenceScore(plans: plans, logs: logs, periodStart: startOfWeek)
    }

    private func saveScore(adherence: Int) {
        let startOfDay = calendar.startOfDay(for: Date())
        let total = BudgetCalculator.totalScore(adherence: adherence, priority: priorityRating, rhythm: rhythmRating)
        let entry = ScoreEntry(periodType: "day", periodStart: startOfDay, budgetAdherenceScore: adherence, priorityRating: priorityRating, rhythmRating: rhythmRating, totalScore: total, note: note.isEmpty ? nil : note)
        modelContext.insert(entry)
        WidgetSummaryUpdater.refresh(modelContext: modelContext)
    }
}

struct RatingPicker: View {
    let title: String
    @Binding var rating: Int

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Picker(title, selection: $rating) {
                ForEach(1...5, id: \.self) { value in
                    Text("\(value)").tag(value)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 200)
        }
    }
}
