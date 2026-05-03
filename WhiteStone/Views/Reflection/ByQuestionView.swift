import SwiftUI
import SwiftData

struct ByQuestionView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var expandedQuestionIndex: Int?

    @State private var reflectionsByQuestion: [Int: [Reflection]] = [:]

    var body: some View {
        List {
            Section {
                AttributionText()
                    .padding(.vertical, 4)
            }

            ForEach(ReflectionQuestions.questions.indices, id: \.self) { index in
                let reflections = reflectionsByQuestion[index] ?? []
                Section {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            expandedQuestionIndex = expandedQuestionIndex == index ? nil : index
                        }
                    } label: {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(ReflectionQuestions.questions[index])
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)

                                Text(countText(for: reflections.count))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if !reflections.isEmpty {
                                Image(systemName: expandedQuestionIndex == index ? "chevron.up" : "chevron.down")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .buttonStyle(.plain)

                    if expandedQuestionIndex == index {
                        ForEach(reflections) { reflection in
                            NavigationLink {
                                ReflectionDetailView(reflectionID: reflection.persistentModelID)
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(DateHelpers.fullDateString(for: reflection.date))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(reflection.responseText)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .onAppear(perform: reload)
    }

    private func reload() {
        let descriptor = FetchDescriptor<Reflection>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let reflections = (try? modelContext.fetch(descriptor)) ?? []
        reflectionsByQuestion = Dictionary(grouping: reflections, by: \.questionIndex)
    }

    private func countText(for count: Int) -> String {
        if count == 0 {
            return "no reflections yet on this question."
        }
        return "\(count) \(count == 1 ? "reflection" : "reflections")."
    }
}
