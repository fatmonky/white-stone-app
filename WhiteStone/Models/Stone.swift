import Foundation
import SwiftData

enum StoneType: String, Codable, CaseIterable, Identifiable {
    var id: String { rawValue }

    case white
    case black
}

@Model
final class Stone {
    var type: StoneType
    var timestamp: Date
    var note: String
    var dayKey: String // "yyyy-MM-dd" for efficient filtering

    init(type: StoneType, note: String = "", timestamp: Date = .now) {
        self.type = type
        self.timestamp = timestamp
        self.note = note
        self.dayKey = DateHelpers.dayKey(for: timestamp)
    }
}
