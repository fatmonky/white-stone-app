import SwiftUI
import SwiftData

struct ReflectionDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let reflectionID: PersistentIdentifier

    @State private var editedText = ""
    @State private var currentID: PersistentIdentifier?

    private var reflection: Reflection? {
        guard let currentID else { return nil }
        return modelContext.model(for: currentID) as? Reflection
    }

    var body: some View {
        Group {
            if let reflection {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(DateHelpers.fullDateString(for: reflection.date))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("Last saved \(ReflectionDateFormatters.detailTimestamp.string(from: reflection.updatedAt ?? reflection.createdAt))")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Text(ReflectionQuestions.questions[safe: reflection.questionIndex] ?? "")
                            .font(.title3.weight(.semibold))
                    }

                    TextEditor(text: $editedText)
                        .frame(maxHeight: .infinity)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(.secondarySystemBackground))
                        )

                    navigationControls(for: reflection)
                }
                .padding()
                .navigationTitle("Reflection")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            save(reflection, forceTimestamp: true)
                        }
                    }
                }
                .onDisappear {
                    save(reflection)
                }
            } else {
                ContentUnavailableView("Reflection not found", systemImage: "questionmark.circle")
            }
        }
        .onAppear {
            if currentID == nil {
                currentID = reflectionID
            }
            editedText = reflection?.responseText ?? ""
        }
    }

    private func navigationControls(for reflection: Reflection) -> some View {
        let siblings = reflectionsForQuestion(reflection.questionIndex)
        let currentIndex = siblings.firstIndex { $0.persistentModelID == reflection.persistentModelID }
        let previous = currentIndex.flatMap { $0 > 0 ? siblings[$0 - 1] : nil }
        let next = currentIndex.flatMap { $0 < siblings.count - 1 ? siblings[$0 + 1] : nil }

        return HStack {
            Button("← previous on this question") {
                move(to: previous)
            }
            .disabled(previous == nil)
            .foregroundStyle(previous == nil ? .secondary : Color(red: 0.53, green: 0.38, blue: 0.22))
            .opacity(previous == nil ? 0.45 : 1)

            Spacer()

            Button("next on this question →") {
                move(to: next)
            }
            .disabled(next == nil)
            .foregroundStyle(next == nil ? .secondary : Color(red: 0.53, green: 0.38, blue: 0.22))
            .opacity(next == nil ? 0.45 : 1)
        }
        .font(.footnote)
    }

    private func move(to reflection: Reflection?) {
        guard let reflection else { return }
        if let current = self.reflection {
            save(current)
        }
        currentID = reflection.persistentModelID
        editedText = reflection.responseText
    }

    private func save(_ reflection: Reflection, forceTimestamp: Bool = false) {
        let trimmed = editedText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            modelContext.delete(reflection)
            try? modelContext.save()
            dismiss()
        } else if reflection.responseText != editedText || forceTimestamp {
            reflection.responseText = editedText
            reflection.updatedAt = .now
            try? modelContext.save()
        }
    }

    private func reflectionsForQuestion(_ questionIndex: Int) -> [Reflection] {
        let predicate = #Predicate<Reflection> { reflection in
            reflection.questionIndex == questionIndex
        }
        let descriptor = FetchDescriptor<Reflection>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
