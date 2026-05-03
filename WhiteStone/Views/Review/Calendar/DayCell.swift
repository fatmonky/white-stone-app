import SwiftUI

struct DayCell: View {
    let day: Int
    let ratio: Double?
    var hasReflection: Bool = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(ColorHelpers.color(forRatio: ratio))
            Text("\(day)")
                .font(.caption)
                .foregroundStyle(ratio != nil ? (ratio! > 0.5 ? .black : .white) : .primary)

            if hasReflection {
                Circle()
                    .fill(Color(red: 0.53, green: 0.38, blue: 0.22))
                    .frame(width: 5, height: 5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(5)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
