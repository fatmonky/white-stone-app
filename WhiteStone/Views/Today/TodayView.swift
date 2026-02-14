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
    @State private var isPulsing = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseTimer: Timer?

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
        addStoneType = type
        showAddSheet = true
    }

    private func flipStone() {
        let newType: StoneType = displayedStoneType == .white ? .black : .white
        playFlipHaptic()
        withAnimation(.easeInOut(duration: 0.4)) {
            flipAngle += 180
        }
        // Swap the displayed type at the midpoint of the animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            displayedStoneType = newType
        }
    }

    private func playFlipHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            generator.impactOccurred()
        }
    }

    private func startPulsing() {
        isPulsing = true
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()

        // 8 Hz pulsing animation
        withAnimation(.easeInOut(duration: 0.0625).repeatForever(autoreverses: true)) {
            pulseScale = 1.06
        }

        // 8 Hz haptic timer (~125ms interval)
        pulseTimer = Timer.scheduledTimer(withTimeInterval: 0.125, repeats: true) { _ in
            generator.impactOccurred(intensity: 0.5)
        }
    }

    private func stopPulsing() {
        isPulsing = false
        pulseTimer?.invalidate()
        pulseTimer = nil
        withAnimation(.easeOut(duration: 0.15)) {
            pulseScale = 1.0
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
                            Text("Your ratio today of good thoughts to bad thoughts")
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
                    StoneIcon(type: displayedStoneType, size: 240)
                        .scaleEffect(pulseScale)
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
                        .onLongPressGesture(minimumDuration: 0.8) {
                            // Long press completed — stop pulsing and open modal
                            stopPulsing()
                            addStone(displayedStoneType)
                        } onPressingChanged: { pressing in
                            if pressing {
                                startPulsing()
                            } else if isPulsing {
                                // Cancelled before completion
                                stopPulsing()
                            }
                        }

                    Text("Swipe to flip \u{2022} Hold to log")
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
