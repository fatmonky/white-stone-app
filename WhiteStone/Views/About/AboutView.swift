import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("This app is inspired by Upagupta, who was the spiritual teacher of the ancient Indian Emperor Ashoka.")
                    .font(.body)

                VStack(alignment: .leading, spacing: 16) {
                    Text("\u{201C}Upagupta, the fourth patriarch, was a native of the Madura country. He had a noble countenance which indicated his integrity, and was highly intelligent and eloquent.")
                        .font(.body)

                    Text("His instructor, Shangnavasu, the third patriarch, told him to keep black and white pebbles.")
                        .font(.body)

                    Text("When he had a ")
                        .font(.body)
                    + Text("bad thought")
                        .font(.body).bold()
                    + Text(" he was to throw down into a basket ")
                        .font(.body)
                    + Text("a black pebble")
                        .font(.body).bold()
                    + Text(";")
                        .font(.body)

                    Text("when he had ")
                        .font(.body)
                    + Text("a good thought")
                        .font(.body).bold()
                    + Text(" he was to throw down ")
                        .font(.body)
                    + Text("a white pebble")
                        .font(.body).bold()
                    + Text(".")
                        .font(.body)

                    Text("Upagupta did as he was told.")
                        .font(.body)

                    Text("At first bad thoughts abounded, and black pebbles were very numerous. Then the white and black were about equal. On the seventh day there were only white pebbles. Shangnavasu then undertook to expound to him the four truths.\u{201D}")
                        .font(.body)

                    Text("\u{2014} Chinese Buddhism, Joseph Edkins, 1893, p.68")
                        .font(.footnote)
                        .foregroundStyle(Color(red: 0.53, green: 0.38, blue: 0.22))
                }
            }
            .padding()
        }
        .navigationTitle("About")
    }
}
