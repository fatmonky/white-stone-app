import SwiftUI
import SwiftData

struct AddStoneSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let stoneType: StoneType
    @State private var note: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        StoneIcon(type: stoneType, size: 32)
                        Text(stoneType == .white ? "White Stone" : "Black Stone")
                            .font(.headline)
                    }
                }

                Section("Note (optional)") {
                    TextEditor(text: $note)
                        .frame(minHeight: 100)
                        .overlay(alignment: .topLeading) {
                            if note.isEmpty {
                                Text("What happened?")
                                    .foregroundStyle(.tertiary)
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                                    .allowsHitTesting(false)
                            }
                        }
                }
            }
            .navigationTitle("Add Stone")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        let stone = Stone(type: stoneType, note: note)
                        modelContext.insert(stone)
                        dismiss()
                    }
                }
            }
        }
    }
}
