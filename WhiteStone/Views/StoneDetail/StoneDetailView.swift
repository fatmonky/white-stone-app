import SwiftUI
import SwiftData

struct StoneDetailView: View {
    let stoneID: PersistentIdentifier

    @Query private var allStones: [Stone]
    @State private var isEditing = false
    @State private var editedNote = ""
    @State private var editedDate = Date.now

    private var stone: Stone? {
        allStones.first { $0.persistentModelID == stoneID }
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
                        Text(DateHelpers.timeString(for: stone.timestamp))
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
                            }
                            Button("Save") {
                                stone.note = editedNote
                                stone.timestamp = editedDate
                                stone.dayKey = DateHelpers.dayKey(for: editedDate)
                                isEditing = false
                            }
                            .fontWeight(.semibold)
                        }
                    } else {
                        Button("Edit") {
                            editedNote = stone.note
                            editedDate = stone.timestamp
                            isEditing = true
                        }
                    }
                }
            }
        } else {
            ContentUnavailableView("Stone not found", systemImage: "questionmark.circle")
        }
    }
}
