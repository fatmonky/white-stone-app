import SwiftUI

struct AttributionText: View {
    private static let brownAccent = Color(red: 0.53, green: 0.38, blue: 0.22)
    var font: Font = .footnote

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(ReflectionQuestions.attributionPrefix)
            Link(ReflectionQuestions.attributionLinkText, destination: ReflectionQuestions.sourceURL)
                .underline()
                .foregroundStyle(Self.brownAccent)
            Text(ReflectionQuestions.attributionSuffix)
        }
        .font(font)
        .foregroundStyle(.secondary)
        .tint(Self.brownAccent)
    }
}
