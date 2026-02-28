import Foundation

enum DateHelpers {
    private static let dayKeyFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = .autoupdatingCurrent
        return f
    }()

    static func dayKey(for date: Date) -> String {
        dayKeyFormatter.string(from: date)
    }

    static var todayKey: String {
        dayKey(for: .now)
    }

    static func date(from dayKey: String) -> Date? {
        dayKeyFormatter.date(from: dayKey)
    }

    private static var calendar: Calendar { Calendar.current }

    static func dayInterval(for date: Date) -> DateInterval {
        calendar.dateInterval(of: .day, for: date)!
    }

    static func monthInterval(for date: Date) -> DateInterval {
        calendar.dateInterval(of: .month, for: date)!
    }

    /// First day of the given month (year, month extracted from `date`).
    static func firstOfMonth(for date: Date) -> Date {
        let comps = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: comps)!
    }

    /// Number of days in the month containing `date`.
    static func daysInMonth(for date: Date) -> Int {
        calendar.range(of: .day, in: .month, for: date)!.count
    }

    /// Weekday index (0 = Monday) of the first day of the month containing `date`.
    static func weekdayOfFirst(for date: Date) -> Int {
        let first = firstOfMonth(for: date)
        let weekday = calendar.component(.weekday, from: first) // 1=Sun, 2=Mon, ...
        return (weekday + 5) % 7 // Mon=0, Tue=1, ..., Sun=6
    }

    /// Move `date` forward or backward by `value` months.
    static func offsetMonth(_ date: Date, by value: Int) -> Date {
        calendar.date(byAdding: .month, value: value, to: date)!
    }

    /// Display string like "February 2026".
    static func monthYearString(for date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: date)
    }

    /// Short time string like "2:34 PM".
    static func timeString(for date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .none
        f.timeStyle = .short
        return f.string(from: date)
    }

    /// Full date string like "Monday, February 10, 2026".
    static func fullDateString(for date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .full
        f.timeStyle = .none
        return f.string(from: date)
    }

    /// Build a dayKey string for a specific day number within the month of `date`.
    static func dayKeyForDay(_ day: Int, inMonthOf date: Date) -> String {
        var comps = calendar.dateComponents([.year, .month], from: date)
        comps.day = day
        return dayKey(for: calendar.date(from: comps)!)
    }

    /// Short day label like "Mon 10" for chart x-axis.
    static func shortDayLabel(for date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "E d"
        return f.string(from: date)
    }

    /// Abbreviated day-of-week for chart axis (M, T, W, Th, F, Sa, Su).
    static func dayAbbreviation(for date: Date) -> String {
        let weekday = calendar.component(.weekday, from: date)
        switch weekday {
        case 1: return "Su"
        case 2: return "M"
        case 3: return "T"
        case 4: return "W"
        case 5: return "Th"
        case 6: return "F"
        case 7: return "Sa"
        default: return ""
        }
    }

    /// Day number as string (e.g. "11").
    static func dayNumber(for date: Date) -> String {
        "\(calendar.component(.day, from: date))"
    }

    /// Start of the week containing `date` (Sunday).
    static func startOfWeek(for date: Date) -> Date {
        let comps = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: comps)!
    }

    /// All dayKeys for the past `weeks` weeks ending at the current week.
    static func dayKeysForPastWeeks(_ weeks: Int) -> [[String]] {
        var result: [[String]] = []
        let today = Date.now
        for weekOffset in stride(from: -(weeks - 1), through: 0, by: 1) {
            let weekStart = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: startOfWeek(for: today))!
            var week: [String] = []
            for dayOffset in 0..<7 {
                let day = calendar.date(byAdding: .day, value: dayOffset, to: weekStart)!
                week.append(dayKey(for: day))
            }
            result.append(week)
        }
        return result
    }
}
