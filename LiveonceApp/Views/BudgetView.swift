import SwiftUI
import SwiftData

struct BudgetView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Bucket.order) private var buckets: [Bucket]
    @Query private var plans: [BudgetPlan]

    private let calendar = Calendar.current

    var body: some View {
        NavigationStack {
            List {
                Section("This Week Plan") {
                    ForEach(buckets) { bucket in
                        HStack {
                            Label(bucket.name, systemImage: bucket.icon)
                            Spacer()
                            Stepper(value: planBinding(for: bucket), in: 0...600, step: 15) {
                                Text("\(planMinutes(for: bucket)) min")
                                    .monospacedDigit()
                            }
                            .labelsHidden()
                        }
                    }
                }
            }
            .navigationTitle("Budget")
            .onChange(of: plans.count) { _, _ in
                WidgetSummaryUpdater.refresh(modelContext: modelContext)
            }
        }
    }

    private func planMinutes(for bucket: Bucket) -> Int {
        planForBucket(bucket)?.plannedMinutes ?? 0
    }

    private func planBinding(for bucket: Bucket) -> Binding<Int> {
        Binding(
            get: { planMinutes(for: bucket) },
            set: { newValue in
                let startOfWeek = calendar.startOfWeek(for: Date())
                if let plan = planForBucket(bucket) {
                    plan.plannedMinutes = newValue
                } else {
                    let plan = BudgetPlan(periodType: "week", periodStart: startOfWeek, plannedMinutes: newValue, bucket: bucket)
                    modelContext.insert(plan)
                }
                WidgetSummaryUpdater.refresh(modelContext: modelContext)
            }
        )
    }

    private func planForBucket(_ bucket: Bucket) -> BudgetPlan? {
        let startOfWeek = calendar.startOfWeek(for: Date())
        return plans.first { plan in
            plan.bucket?.id == bucket.id && calendar.isDate(plan.periodStart, inSameDayAs: startOfWeek)
        }
    }
}
