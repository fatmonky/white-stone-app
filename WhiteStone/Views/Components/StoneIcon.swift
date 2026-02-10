import SwiftUI

struct StoneIcon: View {
    let type: StoneType
    let size: CGFloat

    var body: some View {
        Circle()
            .fill(type == .white ? Color.white : Color.black)
            .overlay(
                Circle()
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
            )
            .frame(width: size, height: size)
    }
}
