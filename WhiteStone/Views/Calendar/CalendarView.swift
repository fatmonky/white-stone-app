import SwiftUI
import SwiftData

struct CalendarView: View {
    @Query private var allStones: [Stone]
    @State private var displayedMonth: Date = .now

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdaySymbols = Calendar.current.veryShortWeekdaySymbols

    /// Group stones by dayKey and compute the white ratio for each day.
    private var ratioByDay: [String: Double?] {
        let grouped = Dictionary(grouping: allStones) { $0.dayKey }
        return grouped.mapValues { stones in
            ColorHelpers.ratio(
                white: stones.filter { $0.type == .white }.count,
                total: stones.count
            )
        }
    }

    private var daysInMonth: Int {
        DateHelpers.daysInMonth(for: displayedMonth)
    }

    private var weekdayOffset: Int {
        DateHelpers.weekdayOfFirst(for: displayedMonth)
    }

    var body: some View {
        VStack(spacing: 16) {
            // Month navigation
            HStack {
                Button { displayedMonth = DateHelpers.offsetMonth(displayedMonth, by: -1) } label: {
                    Image(systemName: "chevron.left")
                }
                Spacer()
                Text(DateHelpers.monthYearString(for: displayedMonth))
                    .font(.headline)
                Spacer()
                Button { displayedMonth = DateHelpers.offsetMonth(displayedMonth, by: 1) } label: {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)

            // Weekday headers
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)

            // Day cells
            LazyVGrid(columns: columns, spacing: 8) {
                // Blank cells for offset
                ForEach(0..<weekdayOffset, id: \.self) { _ in
                    Color.clear
                        .aspectRatio(1, contentMode: .fit)
                }

                ForEach(1...daysInMonth, id: \.self) { day in
                    let key = DateHelpers.dayKeyForDay(day, inMonthOf: displayedMonth)
                    let ratio = ratioByDay[key] ?? nil
                    NavigationLink(value: key) {
                        DayCell(day: day, ratio: ratio)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .navigationTitle("Calendar")
        .navigationDestination(for: String.self) { dayKey in
            DayDetailView(dayKey: dayKey)
        }
    }
}
