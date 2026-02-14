import SwiftUI
import SwiftData

struct DayDetailView: View {
    let dayKey: String

    @Query private var allStones: [Stone]

    private var stones: [Stone] {
        allStones
            .filter { $0.dayKey == dayKey }
            .sorted { $0.timestamp < $1.timestamp }
    }

    private var whiteCount: Int {
        stones.filter { $0.type == .white }.count
    }

    private var blackCount: Int {
        stones.filter { $0.type == .black }.count
    }

    private var dateString: String {
        if let date = DateHelpers.date(from: dayKey) {
            return DateHelpers.fullDateString(for: date)
        }
        return dayKey
    }

    var body: some View {
        List {
            Section {
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        StoneIcon(type: .white, size: 20)
                        Text("\(whiteCount)")
                    }
                    HStack(spacing: 4) {
                        StoneIcon(type: .black, size: 20)
                        Text("\(blackCount)")
                    }
                    Spacer()
                    if whiteCount + blackCount > 0 {
                        RatioBar(white: whiteCount, black: blackCount)
                            .frame(width: 80, height: 8)
                    }
                }
            }

            if stones.isEmpty {
                EmptyStateView(message: "No stones recorded this day.")
            } else {
                Section("Stones") {
                    ForEach(Array(stones.enumerated()), id: \.element.id) { index, stone in
                        NavigationLink(value: stone.persistentModelID) {
                            HStack(spacing: 0) {
                                // Timeline column
                                ZStack {
                                    // Continuous line spanning the full height
                                    if stones.count > 1 {
                                        VStack(spacing: 0) {
                                            Rectangle()
                                                .fill(index == 0 ? Color.clear : Color.gray.opacity(0.3))
                                                .frame(width: 2)
                                            Rectangle()
                                                .fill(index == stones.count - 1 ? Color.clear : Color.gray.opacity(0.3))
                                                .frame(width: 2)
                                        }
                                        .padding(.vertical, -4)
                                    }

                                    // Stone icon on top of the line
                                    StoneIcon(type: stone.type, size: 32)
                                }
                                .frame(width: 40)

                                // Time next to icon
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
                                .padding(.leading, 12)

                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    }
                }
            }
        }
        .navigationTitle(dateString)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: PersistentIdentifier.self) { id in
            StoneDetailView(stoneID: id)
        }
    }
}
