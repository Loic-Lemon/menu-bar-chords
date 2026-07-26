import SwiftUI
import ChordsLib

struct SettingsView: View {
    @Environment(AppModel.self) private var model

    private let iconChoices = ["guitars", "music.note.list", "guitars.fill", "pianokeys"]

    var body: some View {
        VStack(spacing: 8) {
            iconRow
            Divider()
            namingRow
            Divider()
            sizeRow
            Divider()
            soundRow
            Divider()
            quizRow
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(Color(.separatorColor).opacity(0.08))
        .cornerRadius(8)
    }

    private var iconRow: some View {
        HStack {
            Text("Icon")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            HStack(spacing: 2) {
                ForEach(iconChoices, id: \.self) { name in
                    Image(systemName: name)
                        .font(.caption)
                        .padding(5)
                        .background(
                            model.menuBarIconName == name
                                ? Color.accentColor.opacity(0.2)
                                : Color.clear
                        )
                        .cornerRadius(4)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            model.menuBarIconName = name
                            model.didChangeMenuBarIcon()
                        }
                }
            }
        }
    }

    private var namingRow: some View {
        cycleRow(
            label: "Notes",
            binding: noteNamingBinding,
            display: \.label
        )
    }

    private var sizeRow: some View {
        cycleRow(
            label: "Size",
            binding: popoverSizeBinding,
            display: \.label
        )
    }

    private var quizRow: some View {
        cycleRow(
            label: "Quiz",
            binding: quizFilterBinding,
            display: \.label
        )
    }

    private var soundRow: some View {
        cycleRow(
            label: "Sound",
            binding: soundBinding,
            display: \.label
        )
    }

    private func cycleRow<Enum: CaseIterable & Equatable>(
        label: String,
        binding: Binding<Enum>,
        display: KeyPath<Enum, String>
    ) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(binding.wrappedValue[keyPath: display])
                .font(.caption)
                .foregroundStyle(Color.accentColor)
                .contentShape(Rectangle())
                .onTapGesture {
                    let all = Array(Enum.allCases)
                    let idx = all.firstIndex(of: binding.wrappedValue) ?? 0
                    binding.wrappedValue = all[(idx + 1) % all.count]
                }
        }
    }

    private var noteNamingBinding: Binding<NoteNamingScheme> {
        Binding(
            get: { model.noteNaming },
            set: {
                model.noteNaming = $0
                model.didChangeNoteNaming()
            }
        )
    }

    private var popoverSizeBinding: Binding<PopoverSize> {
        Binding(
            get: { model.popoverSize },
            set: {
                model.popoverSize = $0
                model.didChangePopoverSize()
            }
        )
    }

    private var quizFilterBinding: Binding<ChordQuizFilter> {
        Binding(
            get: { model.quizFilter },
            set: {
                model.quizFilter = $0
                model.didChangeQuizFilter()
            }
        )
    }

    private var soundBinding: Binding<GuitarSound> {
        Binding(
            get: { model.guitarSound },
            set: {
                model.guitarSound = $0
                model.didChangeGuitarSound()
            }
        )
    }
}
