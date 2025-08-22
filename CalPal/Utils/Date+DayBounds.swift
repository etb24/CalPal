import Foundation


extension Date {
    var dayBounds: (start: Date, end: Date) {
        let cal = Calendar.current
        let start = cal.startOfDay(for: self)
        let end = cal.date(byAdding: .day, value: 1, to: start)!
        return (start, end)
    }


    var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: .now)
    }
}
