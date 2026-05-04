import SwiftUI
import SwiftData

struct StoneDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let stoneID: PersistentIdentifier

    @State private var isEditing = false
    @State private var editedNote = ""
    @State private var editedDate = Date.now
    @State private var editedRoots: Set<StoneRoot> = []
    @State private var editedCustomRootDescriptors: Set<String> = []
    @State private var customRootDescriptor = ""
    @State private var editedIntensity: StoneIntensity?

    @AppStorage("stone.customRootDescriptors.white") private var whiteCustomRootDescriptors = ""
    @AppStorage("stone.customRootDescriptors.black") private var blackCustomRootDescriptors = ""

    private var stone: Stone? {
        modelContext.model(for: stoneID) as? Stone
    }

    private var savedCustomRootDescriptors: [String] {
        guard let stone else { return [] }
        return customRootDescriptorStorage(for: stone.type)
            .split(separator: "\n")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    var body: some View {
        if let stone {
            List {
                Section {
                    HStack {
                        StoneIcon(type: stone.type, size: 40)
                        Text(stone.type == .white ? "White Stone" : "Black Stone")
                            .font(.title2)
                    }
                }

                Section("Time") {
                    if isEditing {
                        DatePicker(
                            "Date & Time",
                            selection: $editedDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                    } else {
                        Text(DateHelpers.fullDateString(for: stone.timestamp))
                        VStack(alignment: .leading, spacing: 4) {
                            Text(DateHelpers.timeString(for: stone.timestamp))
                            DetailStoneTagPills(stone: stone)
                        }
                    }
                }

                Section("Note") {
                    if isEditing {
                        TextEditor(text: $editedNote)
                            .frame(minHeight: 100)
                            .overlay(alignment: .topLeading) {
                                if editedNote.isEmpty {
                                    Text("What happened?")
                                        .foregroundStyle(.tertiary)
                                        .padding(.top, 8)
                                        .padding(.leading, 4)
                                        .allowsHitTesting(false)
                                }
                            }
                    } else if !stone.note.isEmpty {
                        Text(stone.note)
                    } else {
                        Text("No note")
                            .foregroundStyle(.secondary)
                    }
                }

                if isEditing {
                    Section("Root (optional)") {
                        DetailMultiTagChipGroup(
                            options: StoneRoot.allowed(for: stone.type),
                            selection: $editedRoots
                        )

                        if !savedCustomRootDescriptors.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Saved descriptors")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                DetailCustomRootChipGroup(
                                    options: savedCustomRootDescriptors,
                                    selection: $editedCustomRootDescriptors
                                )
                            }
                            .padding(.top, 6)
                        }

                        TextField("Add your own root descriptor", text: $customRootDescriptor)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }

                    Section("Intensity (optional)") {
                        DetailTagChipGroup(
                            options: StoneIntensity.allCases,
                            selection: $editedIntensity
                        )
                    }
                }
            }
            .navigationTitle("Stone Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if isEditing {
                        HStack {
                            Button("Cancel") {
                                isEditing = false
                                editedNote = stone.note
                                editedDate = stone.timestamp
                                editedRoots = Set(stone.roots)
                                editedCustomRootDescriptors = Set(stone.customRootDescriptors)
                                customRootDescriptor = ""
                                editedIntensity = stone.intensity
                            }
                            Button("Save") {
                                stone.note = editedNote
                                stone.timestamp = editedDate
                                stone.roots = selectedRootsInDisplayOrder(for: stone.type)
                                stone.rootDescriptor = customRootDescriptorsForSave().joined(separator: "\n")
                                rememberCustomRootDescriptors(customRootDescriptorsForSave(), for: stone.type)
                                stone.intensity = editedIntensity
                                isEditing = false
                            }
                            .fontWeight(.semibold)
                        }
                    } else {
                        Button("Edit") {
                            editedNote = stone.note
                            editedDate = stone.timestamp
                            editedRoots = Set(stone.roots)
                            editedCustomRootDescriptors = Set(stone.customRootDescriptors)
                            customRootDescriptor = ""
                            editedIntensity = stone.intensity
                            isEditing = true
                        }
                    }
                }
            }
        } else {
            ContentUnavailableView("Stone not found", systemImage: "questionmark.circle")
        }
    }

    private func customRootDescriptorStorage(for type: StoneType) -> String {
        type == .white ? whiteCustomRootDescriptors : blackCustomRootDescriptors
    }

    private func setCustomRootDescriptorStorage(_ value: String, for type: StoneType) {
        if type == .white {
            whiteCustomRootDescriptors = value
        } else {
            blackCustomRootDescriptors = value
        }
    }

    private func selectedRootsInDisplayOrder(for type: StoneType) -> [StoneRoot] {
        StoneRoot.allowed(for: type).filter { editedRoots.contains($0) }
    }

    private func customRootDescriptorsForSave() -> [String] {
        var descriptors = savedCustomRootDescriptors.filter { editedCustomRootDescriptors.contains($0) }
        let trimmed = customRootDescriptor.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty, !descriptors.contains(trimmed) {
            descriptors.append(trimmed)
        }
        return descriptors
    }

    private func rememberCustomRootDescriptors(_ descriptors: [String], for type: StoneType) {
        let existing = savedCustomRootDescriptors
        let combined = existing + descriptors.filter { !existing.contains($0) }
        setCustomRootDescriptorStorage(combined.joined(separator: "\n"), for: type)
    }
}

private struct DetailStoneTagPills: View {
    let stone: Stone

    var body: some View {
        HStack(spacing: 6) {
            if !stone.rootDisplayNames.isEmpty {
                tag(
                    label: stone.rootDisplayNames.count == 1 ? "root" : "roots",
                    value: stone.rootDisplayNames.joined(separator: ", ")
                )
            }
            if let intensity = stone.intensity {
                tag(label: "intensity", value: intensity.displayName)
            }
        }
    }

    private func tag(label: String, value: String) -> some View {
        Text("\(label): \(value)")
            .font(.caption.weight(.medium))
            .foregroundStyle(Color(red: 0.53, green: 0.38, blue: 0.22))
            .lineLimit(1)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Color(red: 0.53, green: 0.38, blue: 0.22).opacity(0.11))
            )
    }
}

private struct DetailMultiTagChipGroup<Option: StoneTagOption>: View {
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
                    DetailTagChipLabel(
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

private struct DetailCustomRootChipGroup: View {
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
                    DetailTagChipLabel(title: option, isSelected: selection.contains(option))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct DetailTagChipGroup<Option: StoneTagOption>: View {
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
                    DetailTagChipLabel(title: option.displayName, isSelected: selection == option)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct DetailTagChipLabel: View {
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
