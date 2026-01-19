import Foundation

extension Calendar {
    func startOfWeek(for date: Date) -> Date {
        let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: components) ?? date
    }
}

extension Date {
    func startOfDay(using calendar: Calendar = .current) -> Date {
        calendar.startOfDay(for: self)
    }
}
