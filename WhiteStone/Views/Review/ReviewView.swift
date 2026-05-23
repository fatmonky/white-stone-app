import SwiftUI
import SwiftData
import Charts

struct ReviewView: View {
    @Environment(\.modelContext) private var modelContext
    var showTourOverlay: Bool = false
    var onFinishTour: () -> Void = {}
    var onSkipTour: () -> Void = {}

    @State private var displayedMonth: Date = .now
    @State private var selectedDay: Date = Calendar.current.startOfDay(for: .now)
    @State private var monthStones: [Stone] = []
    @State private var monthReflections: [Reflection] = []
    @State private var selectedStones: [Stone] = []
    @State private var selectedReflection: Reflection?
    @State private var allStones: [Stone] = []
    @State private var currentStreak: Int = 0

    @State private var selectedSection: ReviewSection = .bars
    @State private var selectedDayKey: String?
    @State private var stonesListOpacity: Double = 0
    @State private var chartStones: [Stone] = []
    @State private var selectedStonesForChartDay: [Stone] = []
    @State private var chartEndDate: Date = Calendar.current.startOfDay(for: .now)

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdaySymbols = ["M", "T", "W", "T", "F", "S", "S"]

    private static let brownAccent = Color(red: 0.53, green: 0.38, blue: 0.22)

    private var ratioByDay: [Date: Double?] {
        let grouped = Dictionary(grouping: monthStones) { Calendar.current.startOfDay(for: $0.timestamp) }
        return grouped.mapValues { stones in
            ColorHelpers.ratio(
                white: stones.filter { $0.type == .white }.count,
                total: stones.count
            )
        }
    }

    private var reflectionDays: Set<Date> {
        Set(monthReflections.map { Calendar.current.startOfDay(for: $0.date) })
    }

    private var daysInMonth: Int {
        DateHelpers.daysInMonth(for: displayedMonth)
    }

    private var weekdayOffset: Int {
        DateHelpers.weekdayOfFirst(for: displayedMonth)
    }

    private var selectedWhiteCount: Int {
        selectedStones.filter { $0.type == .white }.count
    }

    private var selectedBlackCount: Int {
        selectedStones.filter { $0.type == .black }.count
    }

    private var monthWhiteCount: Int {
        monthStones.filter { $0.type == .white }.count
    }

    private var monthBlackCount: Int {
        monthStones.count - monthWhiteCount
    }

    private var totalDaysTracked: Int {
        Set(allStones.map { DateHelpers.dayKey(for: $0.timestamp) }).count
    }

    private var chartCountsByDayKey: [String: (white: Int, black: Int)] {
        chartStones.reduce(into: [String: (white: Int, black: Int)]()) { partial, stone in
            let key = DateHelpers.dayKey(for: stone.timestamp)
            var value = partial[key] ?? (0, 0)
            if stone.type == .white {
                value.white += 1
            } else {
                value.black += 1
            }
            partial[key] = value
        }
    }

    private var isShowingCurrentWindow: Bool {
        Calendar.current.isDateInToday(chartEndDate)
    }

    private var chartHeaderText: String {
        if isShowingCurrentWindow {
            return "Daily Stones (past 14 days)"
        }
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -13, to: chartEndDate)!
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "Daily Stones (\(formatter.string(from: startDate)) to \(formatter.string(from: chartEndDate)))"
    }

    private var dailyData: [DayStoneCount] {
        let calendar = Calendar.current
        return (0..<14).reversed().flatMap { offset -> [DayStoneCount] in
            let date = calendar.date(byAdding: .day, value: -offset, to: chartEndDate)!
            let key = DateHelpers.dayKey(for: date)
            let dayCounts = chartCountsByDayKey[key] ?? (0, 0)
            let label = DateHelpers.dayAbbreviation(for: date) + "\n" + DateHelpers.dayNumber(for: date)
            return [
                DayStoneCount(dayOffset: offset, label: label, dayKey: key, type: .black, count: dayCounts.black),
                DayStoneCount(dayOffset: offset, label: label, dayKey: key, type: .white, count: dayCounts.white),
            ]
        }
    }

    private var allTimeData: [MonthStoneCount] {
        let grouped = Dictionary(grouping: allStones) { stone in
            DateHelpers.firstOfMonth(for: stone.timestamp)
        }

        return grouped.keys.sorted().flatMap { monthStart -> [MonthStoneCount] in
            let stones = grouped[monthStart] ?? []
            let white = stones.filter { $0.type == .white }.count
            let black = stones.count - white
            let label = Self.monthLabel(for: monthStart)
            let key = DateHelpers.dayKey(for: monthStart)
            return [
                MonthStoneCount(monthKey: key, label: label, type: .black, count: black),
                MonthStoneCount(monthKey: key, label: label, type: .white, count: white),
            ]
        }
    }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 22) {
                    statStrip
                    secondarySection
                    Divider()
                        .frame(maxWidth: 260)
                        .padding(.top, 18)
                        .padding(.bottom, 30)
                    calendarSection
                }
                .padding(.vertical)
            }
            .allowsHitTesting(!showTourOverlay)

            if showTourOverlay {
                tourOverlay
            }
        }
        .navigationTitle("Review")
        .navigationDestination(for: PersistentIdentifier.self) { id in
            StoneDetailView(stoneID: id)
        }
        .onAppear {
            reloadAllData()
        }
        .onChange(of: displayedMonth) { _, _ in
            syncSelectionForMonth()
            reloadMonthStones()
            reloadMonthReflections()
            reloadSelectedDayStones()
            reloadSelectedDayReflection()
        }
        .onChange(of: selectedDay) { _, _ in
            reloadSelectedDayStones()
            reloadSelectedDayReflection()
        }
        .onChange(of: selectedDayKey) { _, _ in
            reloadSelectedChartDayStones()
        }
        .onChange(of: chartEndDate) { _, _ in
            reloadChartStones()
        }
        .padding(.bottom, 8)
    }

    private var statStrip: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Total days tracked: \(totalDaysTracked)")
            Text("This month: \(monthWhiteCount) white · \(monthBlackCount) black")
            Text("Streak: \(currentStreak)d")
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }

    private var calendarSection: some View {
        VStack(spacing: 16) {
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

            VStack(spacing: 8) {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                        Text(symbol)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(Array(-weekdayOffset..<0), id: \.self) { _ in
                        Color.clear
                            .aspectRatio(1, contentMode: .fit)
                    }

                    ForEach(1...daysInMonth, id: \.self) { day in
                        let date = dateForDay(day, in: displayedMonth)
                        let dayStart = Calendar.current.startOfDay(for: date)
                        let ratio = ratioByDay[dayStart] ?? nil
                        Button {
                            selectedDay = dayStart
                        } label: {
                            DayCell(
                                day: day,
                                ratio: ratio,
                                hasReflection: reflectionDays.contains(dayStart)
                            )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(
                                            Self.brownAccent,
                                            lineWidth: Calendar.current.isDate(selectedDay, inSameDayAs: dayStart) ? 2 : 0
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 30)
                    .onEnded { value in
                        if abs(value.translation.width) > abs(value.translation.height) {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                displayedMonth = DateHelpers.offsetMonth(
                                    displayedMonth,
                                    by: value.translation.width < 0 ? 1 : -1
                                )
                            }
                        }
                    }
            )

            selectedDayStonesSection
        }
    }

    private var selectedDayStonesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
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

            if selectedStones.isEmpty {
                if selectedReflection == nil {
                    Text("No stones recorded this day.")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                }
            } else {
                Text("Stones")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                StoneTimelineList(stones: selectedStones)
            }

            if let selectedReflection {
                selectedReflectionSection(selectedReflection)
            }
        }
        .padding(.top, 8)
    }

    private func selectedReflectionSection(_ reflection: Reflection) -> some View {
        NavigationLink {
            ReflectionDetailView(reflectionID: reflection.persistentModelID)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                Text("Reflection")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(questionText(for: reflection.questionIndex))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.primary)
                Text(reflection.responseText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.secondarySystemBackground))
            )
            .padding(.horizontal)
        }
        .buttonStyle(.plain)
        .padding(.top, selectedStones.isEmpty ? 0 : 8)
    }

    private var secondarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Review section", selection: $selectedSection) {
                ForEach(ReviewSection.allCases) { section in
                    Text(section.title).tag(section)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            switch selectedSection {
            case .bars:
                fourteenDayBarsSection
            case .allTime:
                allTimeSection
            case .patterns:
                PatternsView(stones: allStones)
            }
        }
    }

    private var fourteenDayBarsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(chartHeaderText)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
                if !isShowingCurrentWindow {
                    Button("Today") {
                        chartEndDate = Calendar.current.startOfDay(for: .now)
                    }
                    .font(.subheadline)
                    .foregroundStyle(Self.brownAccent)
                }
            }
            .padding(.horizontal)

            if allStones.isEmpty {
                EmptyStateView(message: "Add some stones to see trends.")
                    .padding(.horizontal)
            } else {
                Chart(dailyData) { point in
                    BarMark(
                        x: .value("Day", point.label),
                        y: .value("Count", point.count)
                    )
                    .foregroundStyle(by: .value("Type", point.type == .white ? "White" : "Black"))
                    .cornerRadius(4)
                    .opacity(selectedDayKey == nil || selectedDayKey == point.dayKey ? 1.0 : 0.4)
                }
                .chartForegroundStyleScale([
                    "White": Color(white: 0.78),
                    "Black": Color(white: 0.2),
                ])
                .chartOverlay { proxy in
                    GeometryReader { geo in
                        Rectangle()
                            .fill(Color.clear)
                            .contentShape(Rectangle())
                            .onTapGesture { location in
                                guard let plotFrameAnchor = proxy.plotFrame else { return }
                                let plotFrame = geo[plotFrameAnchor]
                                let xInPlot = location.x - plotFrame.origin.x
                                guard xInPlot >= 0, xInPlot <= plotFrame.width else { return }
                                guard let tappedLabel: String = proxy.value(atX: xInPlot) else { return }
                                if let match = dailyData.first(where: { $0.label == tappedLabel }) {
                                    selectChartDay(match.dayKey)
                                }
                            }
                    }
                }
                .frame(height: 200)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 30)
                        .onEnded { value in
                            if abs(value.translation.width) > abs(value.translation.height) {
                                let calendar = Calendar.current
                                if value.translation.width > 0 {
                                    chartEndDate = calendar.date(byAdding: .day, value: -14, to: chartEndDate)!
                                } else {
                                    let today = calendar.startOfDay(for: .now)
                                    let newEnd = calendar.date(byAdding: .day, value: 14, to: chartEndDate)!
                                    chartEndDate = min(newEnd, today)
                                }
                                selectedDayKey = nil
                                stonesListOpacity = 0
                            }
                        }
                )
                .padding(.horizontal)
            }

            if selectedDayKey != nil, !selectedStonesForChartDay.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        if let key = selectedDayKey, let date = DateHelpers.date(from: key) {
                            Text(DateHelpers.fullDateString(for: date))
                                .font(.subheadline.weight(.semibold))
                        }
                        Spacer()
                        Button {
                            stonesListOpacity = 0
                            selectedDayKey = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal)

                    StoneTimelineList(stones: selectedStonesForChartDay)
                }
                .opacity(stonesListOpacity)
            }
        }
    }

    private var allTimeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("All-time")
                .font(.headline)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            if allStones.isEmpty {
                EmptyStateView(message: "Add some stones to see all-time patterns.")
                    .padding(.horizontal)
            } else {
                Chart(allTimeData) { point in
                    BarMark(
                        x: .value("Month", point.label),
                        y: .value("Count", point.count)
                    )
                    .foregroundStyle(by: .value("Type", point.type == .white ? "White" : "Black"))
                    .cornerRadius(4)
                }
                .chartForegroundStyleScale([
                    "White": Color(white: 0.78),
                    "Black": Color(white: 0.2),
                ])
                .frame(height: 220)
                .padding(.horizontal)
            }
        }
    }

    private var tourOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 14) {
                Spacer(minLength: 180)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Review")
                        .font(.headline)

                    Text("Review combines the calendar and trends into one place. Start with the month grid, then use the sections below it for recent bars, all-time totals, and quiet pattern notes.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Button("Continue to Reflections") {
                        onFinishTour()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Self.brownAccent)

                    Button("Skip Tour") {
                        onSkipTour()
                    }
                    .buttonStyle(.bordered)
                }
                .padding(16)
                .frame(maxWidth: 320)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.98))
                )
                .shadow(color: .black.opacity(0.08), radius: 18, y: 8)

                Spacer()
            }
        }
    }

    private func reloadAllData() {
        syncSelectionForMonth()
        reloadMonthStones()
        reloadMonthReflections()
        reloadSelectedDayStones()
        reloadSelectedDayReflection()
        reloadChartStones()
        reloadAllStonesAndStreak()
        reloadSelectedChartDayStones()
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

    private func reloadMonthReflections() {
        let interval = DateHelpers.monthInterval(for: displayedMonth)
        let predicate = #Predicate<Reflection> { reflection in
            reflection.date >= interval.start && reflection.date < interval.end
        }
        let descriptor = FetchDescriptor<Reflection>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        monthReflections = (try? modelContext.fetch(descriptor)) ?? []
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

    private func reloadSelectedDayReflection() {
        let interval = DateHelpers.dayInterval(for: selectedDay)
        let predicate = #Predicate<Reflection> { reflection in
            reflection.date >= interval.start && reflection.date < interval.end
        }
        let descriptor = FetchDescriptor<Reflection>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        selectedReflection = try? modelContext.fetch(descriptor).first
    }

    private func reloadChartStones() {
        let endInterval = DateHelpers.dayInterval(for: chartEndDate)
        guard let start = Calendar.current.date(byAdding: .day, value: -13, to: endInterval.start) else {
            chartStones = []
            return
        }
        let predicate = #Predicate<Stone> { stone in
            stone.timestamp >= start && stone.timestamp < endInterval.end
        }
        let descriptor = FetchDescriptor<Stone>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp, order: .forward)]
        )
        chartStones = (try? modelContext.fetch(descriptor)) ?? []
    }

    private func reloadSelectedChartDayStones() {
        guard let key = selectedDayKey, let dayDate = DateHelpers.date(from: key) else {
            selectedStonesForChartDay = []
            return
        }
        let interval = DateHelpers.dayInterval(for: dayDate)
        let predicate = #Predicate<Stone> { stone in
            stone.timestamp >= interval.start && stone.timestamp < interval.end
        }
        let descriptor = FetchDescriptor<Stone>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp, order: .forward)]
        )
        selectedStonesForChartDay = (try? modelContext.fetch(descriptor)) ?? []
    }

    private func reloadAllStonesAndStreak() {
        let descriptor = FetchDescriptor<Stone>(sortBy: [SortDescriptor(\.timestamp, order: .forward)])
        let stones = (try? modelContext.fetch(descriptor)) ?? []
        allStones = stones

        let dayCounts = stones.reduce(into: [String: (white: Int, total: Int)]()) { partial, stone in
            let key = DateHelpers.dayKey(for: stone.timestamp)
            var value = partial[key] ?? (0, 0)
            if stone.type == .white {
                value.white += 1
            }
            value.total += 1
            partial[key] = value
        }

        var streak = 0
        var date = Date.now
        let calendar = Calendar.current
        while true {
            let key = DateHelpers.dayKey(for: date)
            guard let count = dayCounts[key], count.total > 0 else { break }
            if count.white * 2 >= count.total {
                streak += 1
            } else {
                break
            }
            guard let previous = calendar.date(byAdding: .day, value: -1, to: date) else { break }
            date = previous
        }
        currentStreak = streak
    }

    private func syncSelectionForMonth() {
        if Calendar.current.isDate(selectedDay, equalTo: displayedMonth, toGranularity: .month) {
            return
        }
        selectedDay = DateHelpers.firstOfMonth(for: displayedMonth)
    }

    private func dateForDay(_ day: Int, in month: Date) -> Date {
        var comps = Calendar.current.dateComponents([.year, .month], from: month)
        comps.day = day
        return Calendar.current.date(from: comps)!
    }

    private func selectChartDay(_ dayKey: String) {
        if selectedDayKey == dayKey {
            stonesListOpacity = 0
            selectedDayKey = nil
        } else {
            stonesListOpacity = 0
            selectedDayKey = dayKey
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeIn(duration: 0.15)) {
                    stonesListOpacity = 1
                }
            }
        }
    }

    private func questionText(for index: Int) -> String {
        guard ReflectionQuestions.questions.indices.contains(index) else { return "" }
        return ReflectionQuestions.questions[index]
    }

    private static func monthLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yy"
        return formatter.string(from: date)
    }
}

private enum ReviewSection: String, CaseIterable, Identifiable {
    case bars
    case allTime
    case patterns

    var id: String { rawValue }

    var title: String {
        switch self {
        case .bars: return "14-day bars"
        case .allTime: return "All-time"
        case .patterns: return "Patterns"
        }
    }
}

private struct DayStoneCount: Identifiable {
    let dayOffset: Int
    let label: String
    let dayKey: String
    let type: StoneType
    let count: Int
    var id: String { "\(dayKey)-\(type)" }
}

private struct MonthStoneCount: Identifiable {
    let monthKey: String
    let label: String
    let type: StoneType
    let count: Int
    var id: String { "\(monthKey)-\(type)" }
}

private struct StoneTimelineList: View {
    let stones: [Stone]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(stones.enumerated()), id: \.element.id) { index, stone in
                NavigationLink(value: stone.persistentModelID) {
                    HStack(spacing: 0) {
                        ZStack {
                            if stones.count > 1 {
                                VStack(spacing: 0) {
                                    Rectangle()
                                        .fill(index == 0 ? Color.clear : Color.gray.opacity(0.3))
                                        .frame(width: 2)
                                    Rectangle()
                                        .fill(index == stones.count - 1 ? Color.clear : Color.gray.opacity(0.3))
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
                            ReviewStoneTagPills(stone: stone)
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

private struct ReviewStoneTagPills: View {
    let stone: Stone

    var body: some View {
        HStack(spacing: 6) {
            if !stone.rootDisplayNames.isEmpty {
                tag(
                    label: stone.rootDisplayNames.count == 1 ? "root" : "roots",
                    value: stone.rootDisplayNames.joined(separator: ", ")
                )
            }
            if let intensity = stone.intensity {
                tag(label: "intensity", value: intensity.displayName)
            }
        }
        .padding(.vertical, stone.rootDisplayNames.isEmpty && stone.intensity == nil ? 0 : 2)
    }

    private func tag(label: String, value: String) -> some View {
        Text("\(label): \(value)")
            .font(.caption2.weight(.medium))
            .foregroundStyle(Color(red: 0.53, green: 0.38, blue: 0.22))
            .lineLimit(1)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(Color(red: 0.53, green: 0.38, blue: 0.22).opacity(0.11))
            )
    }
}
