import SwiftUI
import SwiftData
import Charts

struct TrendsView: View {
    @Query private var allStones: [Stone]

    private var dailyData: [DayStoneCount] {
        let calendar = Calendar.current
        let today = Date.now
        return (0..<14).reversed().flatMap { offset -> [DayStoneCount] in
            let date = calendar.date(byAdding: .day, value: -offset, to: today)!
            let key = DateHelpers.dayKey(for: date)
            let dayStones = allStones.filter { $0.dayKey == key }
            let white = dayStones.filter { $0.type == .white }.count
            let black = dayStones.filter { $0.type == .black }.count
            let label = DateHelpers.shortDayLabel(for: date)
            return [
                DayStoneCount(dayOffset: offset, label: label, type: .white, count: white),
                DayStoneCount(dayOffset: offset, label: label, type: .black, count: black),
            ]
        }
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
        List {
            Section("Overview") {
                HStack {
                    StatCard(title: "Total White", value: "\(totalWhite)", color: .primary, stoneType: .white)
                    StatCard(title: "Total Black", value: "\(totalBlack)", color: .primary, stoneType: .black)
                    StatCard(title: "Streak", value: "\(currentStreak)d", color: Self.brownAccent, stoneType: nil)
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            Section("Daily Stones (past 14 days)") {
                if allStones.isEmpty {
                    EmptyStateView(message: "Add some stones to see trends.")
                } else {
                    Chart(dailyData) { point in
                        BarMark(
                            x: .value("Day", point.label),
                            y: .value("Count", point.count)
                        )
                        .foregroundStyle(by: .value("Type", point.type == .white ? "White" : "Black"))
                        .cornerRadius(4)
                    }
                    .chartForegroundStyleScale([
                        "White": Color(white: 0.78),
                        "Black": Color(white: 0.2),
                    ])
                    .frame(height: 200)
                }
            }
        }
        .navigationTitle("Trends")
    }
}

private struct DayStoneCount: Identifiable {
    let dayOffset: Int
    let label: String
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
