import SwiftUI
import SwiftData

struct ReflectionTodayView: View {
    @Environment(\.modelContext) private var modelContext

    let onOpenQuestionHistory: (Int) -> Void

    @State private var responseText = ""
    @State private var savedReflection: Reflection?
    @State private var previousCount = 0
    @State private var lastSavedAt: Date?
    @FocusState private var isResponseFocused: Bool

    private var today: Date {
        Calendar.current.startOfDay(for: .now)
    }

    private var todaysQuestion: (index: Int, text: String) {
        ReflectionQuestions.questionForDate(today)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(DateHelpers.fullDateString(for: today))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(todaysQuestion.text)
                        .font(.title2.weight(.semibold))
                        .fixedSize(horizontal: false, vertical: true)

                    if previousCount > 0 {
                        Button {
                            onOpenQuestionHistory(todaysQuestion.index)
                        } label: {
                            Text("you've reflected on this question \(previousCount) \(previousCount == 1 ? "time" : "times") before.")
                                .font(.footnote)
                                .foregroundStyle(Color(red: 0.53, green: 0.38, blue: 0.22))
                        }
                        .buttonStyle(.plain)
                    }
                }

                TextEditor(text: $responseText)
                    .focused($isResponseFocused)
                    .frame(minHeight: 220)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(.secondarySystemBackground))
                    )
                    .overlay(alignment: .topLeading) {
                        if responseText.isEmpty {
                            Text("Take your time. There's no need to write anything.")
                                .foregroundStyle(.tertiary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 18)
                                .allowsHitTesting(false)
                        }
                    }

                Text("Each date keeps one reflection. Saving again will overwrite the previous save for that date.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                HStack(alignment: .firstTextBaseline, spacing: 14) {
                    Button("Save") {
                        saveReflection()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 0.53, green: 0.38, blue: 0.22))

                    if let lastSavedAt {
                        Text("Saved at \(ReflectionDateFormatters.saveTimestamp.string(from: lastSavedAt)).")
                            .font(.footnote.italic())
                            .foregroundStyle(.secondary)
                    }
                }

                AttributionText()
                    .padding(.top, 10)
            }
            .padding()
        }
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isResponseFocused = false
                }
            }
        }
        .onAppear(perform: reload)
    }

    private func reload() {
        savedReflection = reflection(for: today)
        responseText = savedReflection?.responseText ?? ""
        lastSavedAt = savedReflection.flatMap { $0.updatedAt ?? $0.createdAt }
        previousCount = reflectionsForQuestion(todaysQuestion.index)
            .filter { !Calendar.current.isDate($0.date, inSameDayAs: today) }
            .count
    }

    private func saveReflection() {
        isResponseFocused = false
        let trimmed = responseText.trimmingCharacters(in: .whitespacesAndNewlines)
        let now = Date.now
        if trimmed.isEmpty {
            if let savedReflection {
                modelContext.delete(savedReflection)
            }
            savedReflection = nil
            responseText = ""
            lastSavedAt = nil
        } else if let savedReflection {
            savedReflection.responseText = responseText
            savedReflection.questionIndex = todaysQuestion.index
            savedReflection.date = today
            savedReflection.updatedAt = now
            lastSavedAt = now
        } else {
            let reflection = Reflection(
                date: today,
                questionIndex: todaysQuestion.index,
                responseText: responseText,
                createdAt: now
            )
            modelContext.insert(reflection)
            savedReflection = reflection
            lastSavedAt = now
        }

        try? modelContext.save()
        reload()
    }

    private func reflection(for date: Date) -> Reflection? {
        let interval = DateHelpers.dayInterval(for: date)
        let predicate = #Predicate<Reflection> { reflection in
            reflection.date >= interval.start && reflection.date < interval.end
        }
        let descriptor = FetchDescriptor<Reflection>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        return modelContext.fetchOrEmpty(descriptor).first
    }

    private func reflectionsForQuestion(_ questionIndex: Int) -> [Reflection] {
        let predicate = #Predicate<Reflection> { reflection in
            reflection.questionIndex == questionIndex
        }
        let descriptor = FetchDescriptor<Reflection>(predicate: predicate)
        return modelContext.fetchOrEmpty(descriptor)
    }
}
