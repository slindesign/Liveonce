import SwiftUI
import SwiftData

struct CalendarView: View {
    @Query private var profiles: [UserProfile]
    @State private var showSettings = false

    private let gridSpacing: CGFloat = 4

    private var profile: UserProfile? {
        profiles.first
    }

    var body: some View {
        NavigationStack {
            if let profile {
                let metrics = LifeUnitMetrics(profile: profile)

                VStack(spacing: 12) {
                    Text("你还剩 \(metrics.remaining) \(metrics.unitLabel)")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    GeometryReader { proxy in
                        LifeGridView(
                            total: metrics.total,
                            used: metrics.used,
                            availableSize: proxy.size,
                            spacing: gridSpacing
                        )
                    }
                }
                .padding([.top, .horizontal])
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

private struct LifeUnitMetrics {
    let total: Int
    let used: Int
    let remaining: Int
    let unitLabel: String

    init(profile: UserProfile, calendar: Calendar = .current, today: Date = Date()) {
        let unit = profile.preferredUnit
        let start = profile.birthDate.startOfDay(using: calendar)
        let end = today.startOfDay(using: calendar)
        let totalUnits: Int
        let usedUnits: Int

        switch unit {
        case "month":
            totalUnits = profile.lifeExpectancyYears * 12
            usedUnits = calendar.dateComponents([.month], from: start, to: end).month ?? 0
        case "quarter":
            totalUnits = profile.lifeExpectancyYears * 4
            let months = calendar.dateComponents([.month], from: start, to: end).month ?? 0
            usedUnits = months / 3
        case "year":
            totalUnits = max(profile.lifeExpectancyYears, 1)
            usedUnits = calendar.dateComponents([.year], from: start, to: end).year ?? 0
        default:
            totalUnits = max(profile.lifeExpectancyYears * 52, 1)
            let metrics = LifeCalculator.lifeWeeksMetrics(birthDate: profile.birthDate, lifeExpectancyYears: profile.lifeExpectancyYears, today: today, calendar: calendar)
            usedUnits = metrics.usedWeeks
        }

        total = max(totalUnits, 1)
        used = max(min(usedUnits, total), 0)
        remaining = max(total - used, 0)
        unitLabel = LifeUnitMetrics.displayLabel(for: unit)
    }

    static func displayLabel(for unit: String) -> String {
        switch unit {
        case "month":
            return "月"
        case "quarter":
            return "季"
        case "year":
            return "年"
        default:
            return "周"
        }
    }
}

struct LifeGridView: View {
    let total: Int
    let used: Int
    let availableSize: CGSize
    let spacing: CGFloat

    private var layout: (columns: Int, cellSize: CGFloat) {
        let safeTotal = max(total, 1)
        let width = max(availableSize.width, 0)
        let height = max(availableSize.height, 0)
        let minCell: CGFloat = 4
        let maxCols = max(1, min(60, Int((width + spacing) / (minCell + spacing))))
        var bestColumns = 1
        var bestCell: CGFloat = 0

        for columns in 1...maxCols {
            let rows = Int(ceil(Double(safeTotal) / Double(columns)))
            let cell = bestCellSize(width: width, height: height, columns: columns, rows: rows, spacing: spacing)
            guard cell > 0 else { continue }
            if cell > bestCell {
                bestCell = cell
                bestColumns = columns
            }
        }

        return (columns: bestColumns, cellSize: max(bestCell, 1))
    }

    var body: some View {
        let layout = layout
        let columns = Array(repeating: GridItem(.fixed(layout.cellSize), spacing: spacing), count: layout.columns)

        LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(0..<total, id: \.self) { index in
                RoundedRectangle(cornerRadius: max(layout.cellSize * 0.2, 2))
                    .fill(index < used ? Color.primary.opacity(0.85) : Color.primary.opacity(0.15))
                    .frame(width: layout.cellSize, height: layout.cellSize)
            }
        }
        .frame(width: availableSize.width, height: availableSize.height, alignment: .topLeading)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func bestCellSize(
        width: CGFloat,
        height: CGFloat,
        columns: Int,
        rows: Int,
        spacing: CGFloat
    ) -> CGFloat {
        let cellWidth = (width - spacing * CGFloat(columns - 1)) / CGFloat(columns)
        let cellHeight = (height - spacing * CGFloat(rows - 1)) / CGFloat(rows)
        guard cellWidth > 0, cellHeight > 0 else { return 0 }
        return min(cellWidth, cellHeight)
    }
}
