import SwiftUI

struct PatternsView: View {
    let stones: [Stone]

    private var observations: [PatternObservation] {
        PatternEngine.observations(from: stones)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if observations.isEmpty {
                Text("Patterns will appear here once you've logged a few weeks of stones.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(observations) { observation in
                    Text(observation.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.secondarySystemBackground))
                        )
                }
            }
        }
        .font(.subheadline)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
