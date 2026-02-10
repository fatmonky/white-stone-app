import SwiftUI

struct DayCell: View {
    let day: Int
    let ratio: Double?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(ColorHelpers.color(forRatio: ratio))
            Text("\(day)")
                .font(.caption)
                .foregroundStyle(ratio != nil ? (ratio! > 0.5 ? .black : .white) : .primary)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
