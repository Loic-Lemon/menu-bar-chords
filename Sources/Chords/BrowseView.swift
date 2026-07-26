import SwiftUI
import ChordsLib

struct BrowseView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        VStack(spacing: 12) {
            browseModePicker
                .padding(.top, 4)

            rootPicker

            typePicker

            Spacer().frame(height: 4)

            fretboardSection

            if model.browseMode == .chord, let chord = model.browseChord {
                PositionStepper(chord: chord)
            }
        }
    }

    private var browseModePicker: some View {
        Picker("", selection: browseModeBinding) {
            ForEach(BrowseMode.allCases, id: \.self) { mode in
                Text(mode.label).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
    }

    private var rootPicker: some View {
        HStack {
            Text("Root")
                .font(.caption)
                .foregroundStyle(.secondary)
            PopUpButtonPicker(
                selection: rootBinding,
                items: Note.allCases,
                title: { model.noteName($0) }
            )
        }
    }

    private var typePicker: some View {
        Group {
            switch model.browseMode {
            case .chord:
                HStack {
                    Text("Type")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    PopUpButtonPicker(
                        selection: chordTypeBinding,
                        items: ChordType.allCases,
                        title: { $0.displayName }
                    )
                }
            case .scale:
                HStack {
                    Text("Type")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    PopUpButtonPicker(
                        selection: scaleTypeBinding,
                        items: ScaleType.allCases,
                        title: { $0.displayName }
                    )
                }
            }
        }
    }

    private var fretboardSection: some View {
        VStack(spacing: 4) {
            chordNameLabel

            if let position = model.currentChordPosition {
                FretboardView(
                    frets: position.frets,
                    fingers: position.fingers,
                    barres: position.barres,
                    baseFret: position.baseFret
                )
            } else {
                FretboardView(
                    frets: [nil, nil, nil, nil, nil, nil],
                    fingers: [nil, nil, nil, nil, nil, nil],
                    baseFret: 1
                )
                .opacity(0.3)
            }
        }
    }

    private var chordNameLabel: some View {
        HStack(alignment: .firstTextBaseline) {
            if let chord = model.browseChord {
                Text("\(model.noteName(chord.root))\(chord.type.symbol)")
                    .font(.title2.weight(.semibold))
                
                if model.browseMode == .chord {
                    Button {
                        model.playCurrentChord()
                    } label: {
                        Image(systemName: "play.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 4)
                }
            } else {
                Text("—")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var browseModeBinding: Binding<BrowseMode> {
        Binding(
            get: { model.browseMode },
            set: {
                model.browseMode = $0
                model.didChangeBrowseMode()
            }
        )
    }

    private var rootBinding: Binding<Note> {
        Binding(
            get: { model.selectedRoot },
            set: {
                model.selectedRoot = $0
                model.didChangeRoot()
            }
        )
    }

    private var chordTypeBinding: Binding<ChordType> {
        Binding(
            get: { model.selectedChordType },
            set: {
                model.selectedChordType = $0
                model.didChangeChordType()
            }
        )
    }

    private var scaleTypeBinding: Binding<ScaleType> {
        Binding(
            get: { model.selectedScaleType },
            set: {
                model.selectedScaleType = $0
                model.didChangeScaleType()
            }
        )
    }
}

private struct PositionStepper: View {
    let chord: ChordDefinition

    @Environment(AppModel.self) private var model

    var body: some View {
        if chord.positions.count > 1 {
            Stepper(
                "Position \(model.selectedChordPositionIndex + 1) / \(chord.positions.count)",
                value: positionBinding,
                in: 0...chord.positions.count - 1
            )
            .font(.caption)
            .controlSize(.small)
        }
    }

    private var positionBinding: Binding<Int> {
        Binding(
            get: { model.selectedChordPositionIndex },
            set: { model.selectedChordPositionIndex = $0 }
        )
    }
}
