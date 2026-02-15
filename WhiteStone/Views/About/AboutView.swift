import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("White Stone is a mental tracking app that helps spiritual practitioners track the goodness of their thoughts & actions throughout a day.")
                    .font(.body)

                VStack(alignment: .leading, spacing: 16) {
                    Text("This app is inspired by Upagupta, the spiritual teacher of the ancient Indian Emperor Ashoka.")
                        .font(.body)

                    Text("\u{201C}Upagupta \u{2026} was a native of the Madura country. His instructor \u{2026} told him to keep black and white pebbles. When he had a bad thought he was to throw down into a basket a black pebble; when he had a good thought he was to throw down a white pebble. Upagupta did as he was told. At first bad thoughts abounded, and black pebbles were very numerous.\nThen the white and black were about equal.\nOn the seventh day there were only white pebbles.\n(His instructor) then undertook to expound to him the four truths.\u{201D}")
                        .font(.body)

                    Text("\u{2014} Chinese Buddhism, Joseph Edkins, 1893, p.68")
                        .font(.footnote)
                        .foregroundStyle(Color(red: 0.53, green: 0.38, blue: 0.22))
                }

                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("What is a good thought?")
                            .font(.body).bold()
                        Text("Thoughts of letting go, kindness and gentleness.")
                            .font(.body)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("What is a bad thought?")
                            .font(.body).bold()
                        Text("Thoughts of sensual desire, ill will and ruthlessness.")
                            .font(.body)
                    }
                }

                Text("But you are free to decide for yourself what are good thoughts or bad thoughts that you will be tracking with White Stone.")
                    .font(.body)
            }
            .padding()
        }
        .navigationTitle("About")
    }
}
