import SwiftUI

enum ColorHelpers {
    /// Maps a white-stone ratio (0.0 = all black, 1.0 = all white) to a colour.
    /// Interpolates from black (0.0) through gray (0.5) to off-white (1.0).
    /// Returns nil for days with no stones.
    static func color(forRatio ratio: Double?) -> Color {
        guard let ratio else { return .gray.opacity(0.15) }
        let brightness = 0.15 + 0.75 * ratio // 0.15 (dark) to 0.90 (light)
        return Color(white: brightness)
    }

    /// Dedicated button/accent colour for white stones.
    static var whiteStoneColor: Color {
        Color(white: 0.82)
    }

    /// Dedicated button/accent colour for black stones.
    static var blackStoneColor: Color {
        Color(white: 0.2)
    }

    /// Ratio of white stones to total stones. Returns nil if total is 0.
    static func ratio(white: Int, total: Int) -> Double? {
        guard total > 0 else { return nil }
        return Double(white) / Double(total)
    }
}
