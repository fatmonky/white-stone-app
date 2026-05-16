import SwiftUI
import SwiftData

struct AddStoneSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let stoneType: StoneType
    var notePlaceholder: String = "What happened?"
    var onSave: (() -> Void)? = nil

    @AppStorage("stone.customRootDescriptors.white") private var whiteCustomRootDescriptors = ""
    @AppStorage("stone.customRootDescriptors.black") private var blackCustomRootDescriptors = ""

    @State private var note: String = ""
    @State private var selectedTime: Date = .now
    @State private var selectedRoots: Set<StoneRoot> = []
    @State private var selectedCustomRootDescriptors: Set<String> = []
    @State private var customRootDescriptor = ""
    @State private var selectedIntensity: StoneIntensity?

    private var savedCustomRootDescriptors: [String] {
        customRootDescriptorStorage
            .split(separator: "\n")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private var customRootDescriptorStorage: String {
        get {
            stoneType == .white ? whiteCustomRootDescriptors : blackCustomRootDescriptors
        }
        nonmutating set {
            if stoneType == .white {
                whiteCustomRootDescriptors = newValue
            } else {
                blackCustomRootDescriptors = newValue
            }
        }
    }

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

                Section("Date") {
                    DatePicker(
                        "Date",
                        selection: $selectedTime,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.compact)
                }

                Section("Time") {
                    DatePicker(
                        "Time",
                        selection: $selectedTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.compact)
                }

                Section("Note (optional)") {
                    TextEditor(text: $note)
                        .frame(minHeight: 100)
                        .overlay(alignment: .topLeading) {
                            if note.isEmpty {
                                Text(notePlaceholder)
                                    .foregroundStyle(.tertiary)
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                                    .allowsHitTesting(false)
                            }
                        }
                }

                Section("Root (optional)") {
                    MultiTagChipGroup(
                        options: StoneRoot.allowed(for: stoneType),
                        selection: $selectedRoots
                    )

                    if !savedCustomRootDescriptors.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Saved descriptors")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            CustomRootChipGroup(
                                options: savedCustomRootDescriptors,
                                selection: $selectedCustomRootDescriptors
                            )
                        }
                        .padding(.top, 6)
                    }

                    TextField("Add your own root descriptor", text: $customRootDescriptor)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                Section("Intensity (optional)") {
                    TagChipGroup(
                        options: StoneIntensity.allCases,
                        selection: $selectedIntensity
                    )
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
                        let stone = Stone(
                            type: stoneType,
                            note: note,
                            timestamp: selectedTime,
                            roots: selectedRootsInDisplayOrder(),
                            rootDescriptor: customRootDescriptorsForSave().joined(separator: "\n"),
                            intensity: selectedIntensity
                        )
                        rememberCustomRootDescriptors(customRootDescriptorsForSave())
                        modelContext.insert(stone)
                        dismiss()
                        DispatchQueue.main.async {
                            onSave?()
                        }
                    }
                }
            }
        }
    }

    private func selectedRootsInDisplayOrder() -> [StoneRoot] {
        StoneRoot.allowed(for: stoneType).filter { selectedRoots.contains($0) }
    }

    private func customRootDescriptorsForSave() -> [String] {
        var descriptors = savedCustomRootDescriptors.filter { selectedCustomRootDescriptors.contains($0) }
        let trimmed = customRootDescriptor.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty, !descriptors.contains(trimmed) {
            descriptors.append(trimmed)
        }
        return descriptors
    }

    private func rememberCustomRootDescriptors(_ descriptors: [String]) {
        let existing = savedCustomRootDescriptors
        let combined = existing + descriptors.filter { !existing.contains($0) }
        customRootDescriptorStorage = combined.joined(separator: "\n")
    }
}

private struct MultiTagChipGroup<Option: StoneTagOption>: View {
    let options: [Option]
    @Binding var selection: Set<Option>

    private let columns = [
        GridItem(.adaptive(minimum: 110), spacing: 8, alignment: .leading)
    ]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
            ForEach(options, id: \.self) { option in
                Button {
                    if selection.contains(option) {
                        selection.remove(option)
                    } else {
                        selection.insert(option)
                    }
                } label: {
                    TagChipLabel(
                        title: option.displayName,
                        isSelected: selection.contains(option)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct CustomRootChipGroup: View {
    let options: [String]
    @Binding var selection: Set<String>

    private let columns = [
        GridItem(.adaptive(minimum: 110), spacing: 8, alignment: .leading)
    ]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
            ForEach(options, id: \.self) { option in
                Button {
                    if selection.contains(option) {
                        selection.remove(option)
                    } else {
                        selection.insert(option)
                    }
                } label: {
                    TagChipLabel(title: option, isSelected: selection.contains(option))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct TagChipGroup<Option: StoneTagOption>: View {
    let options: [Option]
    @Binding var selection: Option?

    private let columns = [
        GridItem(.adaptive(minimum: 110), spacing: 8, alignment: .leading)
    ]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
            ForEach(options, id: \.self) { option in
                Button {
                    selection = selection == option ? nil : option
                } label: {
                    TagChipLabel(title: option.displayName, isSelected: selection == option)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct TagChipLabel: View {
    let title: String
    let isSelected: Bool

    var body: some View {
        Text(title)
            .font(.subheadline)
            .lineLimit(1)
            .minimumScaleFactor(0.85)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .frame(maxWidth: .infinity)
            .background(
                Capsule()
                    .fill(isSelected ? Color.primary.opacity(0.12) : Color.clear)
            )
            .overlay(
                Capsule()
                    .stroke(Color.secondary.opacity(isSelected ? 0.45 : 0.25), lineWidth: 1)
            )
    }
}
