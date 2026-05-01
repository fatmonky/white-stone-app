import SwiftUI

struct PatternsView: View {
    var body: some View {
        Text("Patterns will appear here once you've logged a few weeks of stones.")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.vertical, 8)
    }
}
