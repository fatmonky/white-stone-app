import SwiftUI
import SwiftData

struct StoneDetailView: View {
    let stoneID: PersistentIdentifier

    @Query private var allStones: [Stone]

    private var stone: Stone? {
        allStones.first { $0.persistentModelID == stoneID }
    }

    var body: some View {
        if let stone {
            List {
                Section {
                    HStack {
                        StoneIcon(type: stone.type, size: 40)
                        Text(stone.type == .white ? "White Stone" : "Black Stone")
                            .font(.title2)
                    }
                }

                Section("Time") {
                    Text(DateHelpers.fullDateString(for: stone.timestamp))
                    Text(DateHelpers.timeString(for: stone.timestamp))
                }

                if !stone.note.isEmpty {
                    Section("Note") {
                        Text(stone.note)
                    }
                }
            }
            .navigationTitle("Stone Detail")
            .navigationBarTitleDisplayMode(.inline)
        } else {
            ContentUnavailableView("Stone not found", systemImage: "questionmark.circle")
        }
    }
}
