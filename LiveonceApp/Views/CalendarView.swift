import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @State private var showSettings = false

    private var profile: UserProfile? {
        profiles.first
    }

    var body: some View {
        NavigationStack {
            if let profile {
                let metrics = LifeCalculator.lifeWeeksMetrics(birthDate: profile.birthDate, lifeExpectancyYears: profile.lifeExpectancyYears)
                let progressPercent = Int((metrics.progress * 100).rounded())

                VStack(spacing: 16) {
                    KPIHeaderView(remaining: metrics.remainingWeeks, used: metrics.usedWeeks, progressPercent: progressPercent)

                    Picker("Unit", selection: Binding(
                        get: { profile.preferredUnit },
                        set: { newValue in
                            profile.preferredUnit = newValue
                            profile.updatedAt = Date()
                            WidgetSummaryUpdater.refresh(modelContext: modelContext)
                        })
                    ) {
                        Text("Week").tag("week")
                        Text("Year").tag("year")
                    }
                    .pickerStyle(.segmented)

                    if profile.preferredUnit == "year" {
                        YearGridView(usedYears: metrics.usedWeeks / 52, totalYears: profile.lifeExpectancyYears)
                    } else {
                        WeekGridView(usedWeeks: metrics.usedWeeks, totalWeeks: metrics.totalWeeks)
                    }

                    Spacer()
                }
                .padding()
                .navigationTitle("Death Calendar")
                .toolbar {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView(profile: profile)
                }
            } else {
                ProgressView("Loading...")
            }
        }
    }
}

struct KPIHeaderView: View {
    let remaining: Int
    let used: Int
    let progressPercent: Int

    var body: some View {
        HStack(spacing: 16) {
            KPIItemView(title: "Remaining", value: "\(remaining)")
            KPIItemView(title: "Used", value: "\(used)")
            KPIItemView(title: "Progress", value: "\(progressPercent)%")
        }
        .frame(maxWidth: .infinity)
    }
}

struct KPIItemView: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct WeekGridView: View {
    let usedWeeks: Int
    let totalWeeks: Int

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 12)

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(0..<totalWeeks, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(index < usedWeeks ? Color.primary.opacity(0.8) : Color.primary.opacity(0.15))
                        .frame(height: 12)
                }
            }
        }
    }
}

struct YearGridView: View {
    let usedYears: Int
    let totalYears: Int

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 10)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(0..<totalYears, id: \.self) { index in
                RoundedRectangle(cornerRadius: 4)
                    .fill(index < usedYears ? Color.primary.opacity(0.8) : Color.primary.opacity(0.15))
                    .frame(height: 24)
            }
        }
    }
}
