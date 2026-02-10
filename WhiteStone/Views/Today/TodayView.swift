import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allStones: [Stone]

    @State private var showAddSheet = false
    @State private var addStoneType: StoneType = .white

    private var todayStones: [Stone] {
        let key = DateHelpers.todayKey
        return allStones.filter { $0.dayKey == key }
    }

    private var whiteCount: Int {
        todayStones.filter { $0.type == .white }.count
    }

    private var blackCount: Int {
        todayStones.filter { $0.type == .black }.count
    }

    private func addStone(_ type: StoneType) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        addStoneType = type
        showAddSheet = true
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header: date + ratio bar
            VStack(alignment: .leading, spacing: 12) {
                Text(DateHelpers.fullDateString(for: .now))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if whiteCount + blackCount > 0 {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("This is your day ratio so far")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        RatioBar(white: whiteCount, black: blackCount)
                            .frame(height: 12)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)

            Spacer()
            Spacer()

            // Stone tally — tappable, stacked vertically, large
            VStack(spacing: 24) {
                Button { addStone(.white) } label: {
                    VStack(spacing: 8) {
                        StoneIcon(type: .white, size: 160)
                        Text("\(whiteCount)")
                            .font(.system(size: 32, weight: .light))
                            .foregroundStyle(.primary)
                    }
                }
                .buttonStyle(.plain)

                Button { addStone(.black) } label: {
                    VStack(spacing: 8) {
                        StoneIcon(type: .black, size: 160)
                        Text("\(blackCount)")
                            .font(.system(size: 32, weight: .light))
                            .foregroundStyle(.primary)
                    }
                }
                .buttonStyle(.plain)
            }

            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("White Stone")
                    .font(.headline)
            }
        }
        .navigationTitle("Today")
        .sheet(isPresented: $showAddSheet) {
            AddStoneSheet(stoneType: addStoneType)
        }
    }
}
