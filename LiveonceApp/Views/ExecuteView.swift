import SwiftUI
import SwiftData

struct ExecuteView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Bucket.order) private var buckets: [Bucket]
    @Query private var plans: [BudgetPlan]
    @Query private var logs: [TimeLog]

    private let calendar = Calendar.current

    @State private var selectedBucket: Bucket?
    @State private var minutes: Int = 30
    @State private var logDate = Date()

    var body: some View {
        NavigationStack {
            Form {
                Section("Quick Add") {
                    Picker("Bucket", selection: $selectedBucket) {
                        ForEach(buckets) { bucket in
                            Text(bucket.name).tag(Optional(bucket))
                        }
                    }

                    Stepper(value: $minutes, in: 5...240, step: 5) {
                        Text("Minutes: \(minutes)")
                            .monospacedDigit()
                    }

                    DatePicker("Date", selection: $logDate, displayedComponents: .date)

                    Button("Add Log") {
                        addLog()
                    }
                    .disabled(selectedBucket == nil)
                }

                Section("This Week Summary") {
                    ForEach(buckets) { bucket in
                        let planned = planMinutes(for: bucket)
                        let actual = actualMinutes(for: bucket)
                        let ratio = planned == 0 ? (actual == 0 ? 1.0 : 0.0) : min(Double(actual) / Double(planned), 1.2)
                        let percent = Int(min(ratio, 1.0) * 100)

                        HStack {
                            Label(bucket.name, systemImage: bucket.icon)
                            Spacer()
                            Text("\(actual)/\(planned) min")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("\(percent)%")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Execute")
            .onAppear {
                if selectedBucket == nil {
                    selectedBucket = buckets.first
                }
            }
        }
    }

    private func addLog() {
        guard let bucket = selectedBucket else { return }
        let log = TimeLog(date: logDate, minutes: minutes, note: nil, bucket: bucket)
        modelContext.insert(log)
        WidgetSummaryUpdater.refresh(modelContext: modelContext)
    }

    private func planMinutes(for bucket: Bucket) -> Int {
        let startOfWeek = calendar.startOfWeek(for: Date())
        return plans.first { plan in
            plan.bucket?.id == bucket.id && calendar.isDate(plan.periodStart, inSameDayAs: startOfWeek)
        }?.plannedMinutes ?? 0
    }

    private func actualMinutes(for bucket: Bucket) -> Int {
        let startOfWeek = calendar.startOfWeek(for: Date())
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: startOfWeek) ?? startOfWeek
        return logs.filter { log in
            log.bucket?.id == bucket.id && log.date >= startOfWeek && log.date < weekEnd
        }
        .reduce(0) { $0 + $1.minutes }
    }
}
