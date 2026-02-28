import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var displayedMonth: Date = .now
    @State private var selectedDay: Date = Calendar.current.startOfDay(for: .now)
    @State private var monthStones: [Stone] = []
    @State private var selectedStones: [Stone] = []

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdaySymbols = ["M", "T", "W", "T", "F", "S", "S"]

    /// Group stones by day and compute the white ratio for each day.
    private var ratioByDay: [Date: Double?] {
        let grouped = Dictionary(grouping: monthStones) { Calendar.current.startOfDay(for: $0.timestamp) }
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

    private func reloadMonthStones() {
        let interval = DateHelpers.monthInterval(for: displayedMonth)
        let predicate = #Predicate<Stone> { stone in
            stone.timestamp >= interval.start && stone.timestamp < interval.end
        }
        let descriptor = FetchDescriptor<Stone>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp, order: .forward)]
        )
        monthStones = (try? modelContext.fetch(descriptor)) ?? []
    }

    private func reloadSelectedDayStones() {
        let interval = DateHelpers.dayInterval(for: selectedDay)
        let predicate = #Predicate<Stone> { stone in
            stone.timestamp >= interval.start && stone.timestamp < interval.end
        }
        let descriptor = FetchDescriptor<Stone>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp, order: .forward)]
        )
        selectedStones = (try? modelContext.fetch(descriptor)) ?? []
    }

    private func syncSelectionForMonth() {
        if Calendar.current.isDate(selectedDay, equalTo: displayedMonth, toGranularity: .month) {
            return
        }
        selectedDay = DateHelpers.firstOfMonth(for: displayedMonth)
    }

    private var selectedWhiteCount: Int {
        selectedStones.filter { $0.type == .white }.count
    }

    private var selectedBlackCount: Int {
        selectedStones.filter { $0.type == .black }.count
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Month navigation
                HStack {
                    Button {
                        displayedMonth = DateHelpers.offsetMonth(displayedMonth, by: -1)
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    Spacer()
                    Text(DateHelpers.monthYearString(for: displayedMonth))
                        .font(.headline)
                    Spacer()
                    Button {
                        displayedMonth = DateHelpers.offsetMonth(displayedMonth, by: 1)
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                }
                .padding(.horizontal)

                // Weekday headers
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
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
                        var comps = Calendar.current.dateComponents([.year, .month], from: displayedMonth)
                        comps.day = day
                        let date = Calendar.current.date(from: comps)!
                        let dayStart = Calendar.current.startOfDay(for: date)
                        let ratio = ratioByDay[dayStart] ?? nil
                        Button {
                            selectedDay = dayStart
                        } label: {
                            DayCell(day: day, ratio: ratio)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(
                                            Color(red: 0.53, green: 0.38, blue: 0.22),
                                            lineWidth: Calendar.current.isDate(selectedDay, inSameDayAs: dayStart) ? 2 : 0
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)

                // Inline stones list for selected day
                VStack(alignment: .leading, spacing: 8) {
                    // Day header with counts and ratio bar
                    if !selectedStones.isEmpty {
                        HStack(spacing: 16) {
                            HStack(spacing: 4) {
                                StoneIcon(type: .white, size: 16)
                                Text("\(selectedWhiteCount)")
                                    .font(.subheadline)
                            }
                            HStack(spacing: 4) {
                                StoneIcon(type: .black, size: 16)
                                Text("\(selectedBlackCount)")
                                    .font(.subheadline)
                            }
                            Spacer()
                            RatioBar(white: selectedWhiteCount, black: selectedBlackCount)
                                .frame(width: 80, height: 8)
                        }
                        .padding(.horizontal)
                    }

                    Text("Stones")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)

                    if selectedStones.isEmpty {
                        Text("No stones recorded this day.")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                    } else {
                        VStack(spacing: 0) {
                            ForEach(Array(selectedStones.enumerated()), id: \.element.id) { index, stone in
                                NavigationLink(value: stone.persistentModelID) {
                                    HStack(spacing: 0) {
                                        // Timeline column
                                        ZStack {
                                            if selectedStones.count > 1 {
                                                VStack(spacing: 0) {
                                                    Rectangle()
                                                        .fill(index == 0 ? Color.clear : Color.gray.opacity(0.3))
                                                        .frame(width: 2)
                                                    Rectangle()
                                                        .fill(index == selectedStones.count - 1 ? Color.clear : Color.gray.opacity(0.3))
                                                        .frame(width: 2)
                                                }
                                                .padding(.vertical, -6)
                                            }
                                            StoneIcon(type: stone.type, size: 28)
                                        }
                                        .frame(width: 36)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(DateHelpers.timeString(for: stone.timestamp))
                                                .font(.subheadline.weight(.medium))
                                            if !stone.note.isEmpty {
                                                Text(stone.note)
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                                    .lineLimit(2)
                                            }
                                        }
                                        .padding(.leading, 10)

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundStyle(.tertiary)
                                    }
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal)
                                .padding(.vertical, 6)
                            }
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
        .navigationTitle("Calendar")
        .navigationDestination(for: PersistentIdentifier.self) { id in
            StoneDetailView(stoneID: id)
        }
        .onAppear {
            syncSelectionForMonth()
            reloadMonthStones()
            reloadSelectedDayStones()
        }
        .onChange(of: displayedMonth) { _, _ in
            syncSelectionForMonth()
            reloadMonthStones()
            reloadSelectedDayStones()
        }
        .onChange(of: selectedDay) { _, _ in
            reloadSelectedDayStones()
        }
    }
}
