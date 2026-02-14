import SwiftUI
import SwiftData
import Charts

struct TrendsView: View {
    @Query private var allStones: [Stone]
    @State private var selectedDayKey: String?
    @State private var stonesListOpacity: Double = 0

    private var dailyData: [DayStoneCount] {
        let calendar = Calendar.current
        let today = Date.now
        return (0..<14).reversed().flatMap { offset -> [DayStoneCount] in
            let date = calendar.date(byAdding: .day, value: -offset, to: today)!
            let key = DateHelpers.dayKey(for: date)
            let dayStones = allStones.filter { $0.dayKey == key }
            let white = dayStones.filter { $0.type == .white }.count
            let black = dayStones.filter { $0.type == .black }.count
            let label = DateHelpers.dayAbbreviation(for: date) + "\n" + DateHelpers.dayNumber(for: date)
            // Black first (bottom of stack), white second (top of stack)
            return [
                DayStoneCount(dayOffset: offset, label: label, dayKey: key, type: .black, count: black),
                DayStoneCount(dayOffset: offset, label: label, dayKey: key, type: .white, count: white),
            ]
        }
    }

    /// Unique day labels in chart order, for tap detection.
    private var dayLabels: [String] {
        var seen = Set<String>()
        return dailyData.compactMap { item in
            guard !seen.contains(item.label) else { return nil }
            seen.insert(item.label)
            return item.label
        }
    }

    private var selectedStonesForDay: [Stone] {
        guard let key = selectedDayKey else { return [] }
        return allStones
            .filter { $0.dayKey == key }
            .sorted { $0.timestamp < $1.timestamp }
    }

    private var currentStreak: Int {
        var streak = 0
        var date = Date.now
        let calendar = Calendar.current
        while true {
            let key = DateHelpers.dayKey(for: date)
            let dayStones = allStones.filter { $0.dayKey == key }
            if dayStones.isEmpty { break }
            let white = dayStones.filter { $0.type == .white }.count
            if white * 2 >= dayStones.count {
                streak += 1
            } else {
                break
            }
            guard let prev = calendar.date(byAdding: .day, value: -1, to: date) else { break }
            date = prev
        }
        return streak
    }

    private var totalWhite: Int {
        allStones.filter { $0.type == .white }.count
    }

    private var totalBlack: Int {
        allStones.filter { $0.type == .black }.count
    }

    private static let brownAccent = Color(red: 0.53, green: 0.38, blue: 0.22)

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Overview section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Overview")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)

                    HStack {
                        StatCard(title: "Total White", value: "\(totalWhite)", color: .primary, stoneType: .white)
                        StatCard(title: "Total Black", value: "\(totalBlack)", color: .primary, stoneType: .black)
                        StatCard(title: "Streak", value: "\(currentStreak)d", color: Self.brownAccent, stoneType: nil)
                    }
                    .padding(.horizontal)
                }

                // Chart section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Daily Stones (past 14 days)")
                        .font(.headline)
                        .foregroundStyle(.secondary)
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
                                        guard let tappedLabel: String = proxy.value(atX: location.x) else { return }
                                        // Find matching dayKey
                                        if let match = dailyData.first(where: { $0.label == tappedLabel }) {
                                            if selectedDayKey == match.dayKey {
                                                selectedDayKey = nil
                                                stonesListOpacity = 0
                                            } else {
                                                stonesListOpacity = 0
                                                selectedDayKey = match.dayKey
                                                // Stay fully transparent until layout settles, then snap visible
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                                    withAnimation(.easeIn(duration: 0.15)) {
                                                        stonesListOpacity = 1
                                                    }
                                                }
                                            }
                                        }
                                    }
                            }
                        }
                        .frame(height: 200)
                        .padding(.horizontal)
                    }
                }

                // Expandable day detail
                if let key = selectedDayKey, !selectedStonesForDay.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            if let date = DateHelpers.date(from: key) {
                                Text(DateHelpers.fullDateString(for: date))
                                    .font(.subheadline.weight(.semibold))
                            }
                            Spacer()
                            Button {
                                selectedDayKey = nil
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.horizontal)

                        // Stones list for selected day
                        VStack(spacing: 0) {
                            ForEach(Array(selectedStonesForDay.enumerated()), id: \.element.id) { index, stone in
                                NavigationLink(value: stone.persistentModelID) {
                                    HStack(spacing: 0) {
                                        ZStack {
                                            if selectedStonesForDay.count > 1 {
                                                VStack(spacing: 0) {
                                                    Rectangle()
                                                        .fill(index == 0 ? Color.clear : Color.gray.opacity(0.3))
                                                        .frame(width: 2)
                                                    Rectangle()
                                                        .fill(index == selectedStonesForDay.count - 1 ? Color.clear : Color.gray.opacity(0.3))
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
                    .opacity(stonesListOpacity)
                    .transition(.move(edge: .top))
                }
            }
            .padding(.vertical)
        }
        .animation(.easeInOut(duration: 0.3), value: selectedDayKey)
        .navigationTitle("Trends")
        .navigationDestination(for: PersistentIdentifier.self) { id in
            StoneDetailView(stoneID: id)
        }
    }
}

private struct DayStoneCount: Identifiable {
    let dayOffset: Int
    let label: String
    let dayKey: String
    let type: StoneType
    let count: Int
    var id: String { "\(dayOffset)-\(type)" }
}

private struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    let stoneType: StoneType?

    var body: some View {
        VStack(spacing: 4) {
            if let stoneType {
                StoneIcon(type: stoneType, size: 28)
            }
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(color)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}
