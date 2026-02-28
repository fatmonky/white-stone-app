import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    @State private var addStoneType: StoneType? = nil
    @State private var currentDate = Date.now
    @State private var todayStones: [Stone] = []
    @State private var displayedStoneType: StoneType = .white
    @State private var flipAngle: Double = 0
    @State private var verticalFlipAngle: Double = 0
    @State private var holdScale: CGFloat = 1.0
    @State private var arrowPulse: Bool = false

    private func reloadTodayStones() {
        let interval = DateHelpers.dayInterval(for: currentDate)
        let predicate = #Predicate<Stone> { stone in
            stone.timestamp >= interval.start && stone.timestamp < interval.end
        }
        let descriptor = FetchDescriptor<Stone>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp, order: .forward)]
        )
        todayStones = (try? modelContext.fetch(descriptor)) ?? []
    }

    private var whiteCount: Int {
        todayStones.filter { $0.type == .white }.count
    }

    private var blackCount: Int {
        todayStones.filter { $0.type == .black }.count
    }

    private func addStone(_ type: StoneType) {
        addStoneType = type
    }

    private func flipStone(direction: CGFloat) {
        let newType: StoneType = displayedStoneType == .white ? .black : .white
        playFlipHaptic()
        withAnimation(.easeInOut(duration: 0.4)) {
            flipAngle += direction >= 0 ? 180 : -180
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
                    HStack(spacing: 24) {
                        Image(systemName: "chevron.left")
                            .font(.title)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                            .opacity(arrowPulse ? 0.8 : 0.3)

                        StoneIcon(type: displayedStoneType, size: 240)
                            .scaleEffect(holdScale)
                            .rotation3DEffect(
                                .degrees(flipAngle),
                                axis: (x: 0, y: 1, z: 0)
                            )
                            .rotation3DEffect(
                                .degrees(verticalFlipAngle),
                                axis: (x: 1, y: 0, z: 0)
                            )
                            .gesture(
                                DragGesture(minimumDistance: 30)
                                    .onEnded { value in
                                        if abs(value.translation.width) > abs(value.translation.height) {
                                            flipStone(direction: value.translation.width)
                                        } else if abs(value.translation.height) > abs(value.translation.width) {
                                            playFlipHaptic()
                                            withAnimation(.easeInOut(duration: 0.6)) {
                                                verticalFlipAngle += value.translation.height >= 0 ? 360 : -360
                                            }
                                        }
                                    }
                            )
                            .onLongPressGesture(minimumDuration: 0.8) {
                                let generator = UIImpactFeedbackGenerator(style: .heavy)
                                generator.impactOccurred()
                                addStone(displayedStoneType)
                                withAnimation(.easeOut(duration: 0.15)) {
                                    holdScale = 1.0
                                }
                            } onPressingChanged: { pressing in
                                if pressing {
                                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                                    generator.impactOccurred()
                                    withAnimation(.easeInOut(duration: 0.6)) {
                                        holdScale = 1.1
                                    }
                                } else {
                                    withAnimation(.easeOut(duration: 0.15)) {
                                        holdScale = 1.0
                                    }
                                }
                            }

                        Image(systemName: "chevron.right")
                            .font(.title)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                            .opacity(arrowPulse ? 0.8 : 0.3)
                    }
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                            arrowPulse = true
                        }
                    }

                    Text("Swipe left/right to flip stone \u{2022} Hold to log")
                        .font(.caption)
                        .foregroundStyle(.secondary)
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
        .sheet(item: $addStoneType, onDismiss: reloadTodayStones) { type in
            AddStoneSheet(stoneType: type)
        }
        .onAppear(perform: reloadTodayStones)
        .onChange(of: currentDate) { _, _ in
            reloadTodayStones()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                currentDate = .now
                reloadTodayStones()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
            currentDate = .now
            reloadTodayStones()
        }
    }
}
