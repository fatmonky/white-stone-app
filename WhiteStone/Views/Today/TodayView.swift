import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query private var allStones: [Stone]

    @State private var showAddSheet = false
    @State private var addStoneType: StoneType = .white
    @State private var currentDate = Date.now
    @State private var displayedStoneType: StoneType = .white
    @State private var flipAngle: Double = 0

    private var todayStones: [Stone] {
        let key = DateHelpers.dayKey(for: currentDate)
        return allStones
            .filter { $0.dayKey == key }
            .sorted { $0.timestamp < $1.timestamp }
    }

    private var whiteCount: Int {
        todayStones.filter { $0.type == .white }.count
    }

    private var blackCount: Int {
        todayStones.filter { $0.type == .black }.count
    }

    private func addStone(_ type: StoneType) {
        playLongHaptic()
        addStoneType = type
        showAddSheet = true
    }

    private func flipStone() {
        let newType: StoneType = displayedStoneType == .white ? .black : .white
        withAnimation(.easeInOut(duration: 0.4)) {
            flipAngle += 180
        }
        // Swap the displayed type at the midpoint of the animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            displayedStoneType = newType
        }
    }

    private func playLongHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        for i in 1...4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.1) {
                generator.impactOccurred(intensity: max(0.3, 1.0 - Double(i) * 0.15))
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header: date + ratio bar
                VStack(alignment: .leading, spacing: 12) {
                    Text(DateHelpers.fullDateString(for: currentDate))
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
                .padding(.top, 8)

                Spacer(minLength: 40)

                // Counts display
                HStack(spacing: 32) {
                    HStack(spacing: 6) {
                        StoneIcon(type: .white, size: 20)
                        Text("\(whiteCount)")
                            .font(.system(size: 20, weight: .light))
                    }
                    HStack(spacing: 6) {
                        StoneIcon(type: .black, size: 20)
                        Text("\(blackCount)")
                            .font(.system(size: 20, weight: .light))
                    }
                }
                .padding(.bottom, 16)

                // Single flippable stone
                VStack(spacing: 12) {
                    StoneIcon(type: displayedStoneType, size: 160)
                        .rotation3DEffect(
                            .degrees(flipAngle),
                            axis: (x: 0, y: 1, z: 0)
                        )
                        .gesture(
                            DragGesture(minimumDistance: 30)
                                .onEnded { value in
                                    if abs(value.translation.width) > abs(value.translation.height) {
                                        flipStone()
                                    }
                                }
                        )
                        .onTapGesture {
                            addStone(displayedStoneType)
                        }

                    Text("Swipe to flip \u{2022} Tap to log")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }

                Spacer(minLength: 40)

                // Today's stones timeline
                if !todayStones.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Today's Stones")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                            .padding(.bottom, 8)

                        ForEach(Array(todayStones.enumerated()), id: \.element.id) { index, stone in
                            NavigationLink(value: stone.persistentModelID) {
                                HStack(spacing: 0) {
                                    // Timeline column
                                    ZStack {
                                        if todayStones.count > 1 {
                                            VStack(spacing: 0) {
                                                Rectangle()
                                                    .fill(index == 0 ? Color.clear : Color.gray.opacity(0.3))
                                                    .frame(width: 2)
                                                Rectangle()
                                                    .fill(index == todayStones.count - 1 ? Color.clear : Color.gray.opacity(0.3))
                                                    .frame(width: 2)
                                            }
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
                    .padding(.top, 8)
                }
            }
            .frame(minHeight: UIScreen.main.bounds.height * 0.75)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("White Stone")
                    .font(.headline)
            }
        }
        .navigationTitle("Today")
        .navigationDestination(for: PersistentIdentifier.self) { id in
            StoneDetailView(stoneID: id)
        }
        .sheet(isPresented: $showAddSheet) {
            AddStoneSheet(stoneType: addStoneType)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                currentDate = .now
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
            currentDate = .now
        }
    }
}
