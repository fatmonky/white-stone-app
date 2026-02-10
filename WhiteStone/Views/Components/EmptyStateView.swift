import SwiftUI

struct EmptyStateView: View {
    let message: String

    var body: some View {
        ContentUnavailableView {
            Label("Nothing here", systemImage: "tray")
        } description: {
            Text(message)
        }
    }
}
