import SwiftUI

struct RatioBar: View {
    let white: Int
    let black: Int

    private var ratio: Double {
        let total = white + black
        guard total > 0 else { return 0.5 }
        return Double(white) / Double(total)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Black portion (full width)
                RoundedRectangle(cornerRadius: 6)
                    .fill(ColorHelpers.color(forRatio: 0.0))

                // White portion (proportional)
                RoundedRectangle(cornerRadius: 6)
                    .fill(ColorHelpers.color(forRatio: 1.0))
                    .frame(width: geo.size.width * ratio)
            }
        }
    }
}
