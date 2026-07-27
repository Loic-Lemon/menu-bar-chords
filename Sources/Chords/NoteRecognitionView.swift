import SwiftUI
import ChordsLib

struct NoteRecognitionView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        VStack(spacing: 12) {
            sessionControls
                .padding(.top, 4)

            stringSelector

            positionFilterPicker

            if let target = model.currentNoteTarget {
                notePrompt(note: target)
            }

            if model.isNoteRevealed, let target = model.currentNoteTarget {
                revealFretboard(target: target)
                if !model.isNoteAnswered {
                    answerButtons
                } else {
                    answerFeedback
                }
            } else {
                FretboardView(
                    frets: [nil, nil, nil, nil, nil, nil],
                    fingers: [nil, nil, nil, nil, nil, nil],
                    baseFret: 1
                )
                .opacity(0.2)
            }

            Spacer().frame(height: 4)

            HStack(spacing: 12) {
                if !model.isNoteRevealed {
                    Button("Reveal") {
                        model.revealNote()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }

                if model.isNoteAnswered {
                    Button("Next Note") {
                        model.generateNoteTarget()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
        }
    }

    private var sessionControls: some View {
        HStack {
            if let session = model.currentNoteSession, session.isActive {
                Text("Session · \(formatDuration(session.duration))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("End") {
                    model.endNoteSession()
                }
                .buttonStyle(.borderless)
                .controlSize(.small)
                .foregroundStyle(.red)
            } else {
                Spacer()
                Button("Start Session") {
                    model.startNoteSession()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding(.vertical, 2)
    }

    private var answerButtons: some View {
        HStack(spacing: 20) {
            Button {
                model.recordNoteAnswer(correct: true)
            } label: {
                Label("Got it", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
            .buttonStyle(.bordered)
            .controlSize(.small)

            Button {
                model.recordNoteAnswer(correct: false)
            } label: {
                Label("Missed", systemImage: "xmark.circle.fill")
                    .foregroundStyle(.red)
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding(.vertical, 4)
    }

    private var answerFeedback: some View {
        Label(
            model.isNoteAnswerCorrect ? "Correct!" : "Missed — keep practicing!",
            systemImage: model.isNoteAnswerCorrect ? "hand.thumbsup.fill" : "figure.run"
        )
        .font(.subheadline)
        .foregroundStyle(model.isNoteAnswerCorrect ? .green : .orange)
        .padding(.vertical, 4)
    }

    private var stringSelector: some View {
        HStack {
            Text("String")
                .font(.caption)
                .foregroundStyle(.secondary)
            PopUpButtonPicker(
                selection: stringBinding,
                items: [nil] + GuitarString.allCases.map(Optional.some),
                title: { $0?.displayName ?? "Random" }
            )
        }
    }

    private var positionFilterPicker: some View {
        Picker("", selection: positionFilterBinding) {
            ForEach(NotePositionFilter.allCases, id: \.self) { filter in
                Text(filter.label).tag(filter)
            }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
    }

    private func notePrompt(note: Note) -> some View {
        Text("Find: \(model.noteName(note))")
            .font(.system(size: 32, weight: .bold, design: .rounded))
            .foregroundStyle(Color.accentColor)
            .padding(.vertical, 8)
    }

    private func revealFretboard(target: Note) -> some View {
        let stringIndex: Int
        let targetFret: Int

        if let s = model.selectedString {
            stringIndex = s.rawValue
        } else {
            stringIndex = target.rawValue % 6
        }

        targetFret = model.noteTargetFret ?? 0
        let base = max(1, targetFret - 1)

        var frets: [Int?] = Array(repeating: nil as Int?, count: 6)
        var fingers: [Int?] = Array(repeating: nil as Int?, count: 6)
        let barres: [Barre] = []

        frets[stringIndex] = targetFret
        if targetFret > 0 {
            fingers[stringIndex] = 1
        }

        return FretboardView(
            frets: frets,
            fingers: fingers,
            barres: barres,
            baseFret: base,
            rootString: stringIndex,
            highlightFret: targetFret,
            highlightString: stringIndex
        )
    }

    private func formatDuration(_ interval: TimeInterval) -> String {
        let total = Int(interval)
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private var stringBinding: Binding<GuitarString?> {
        Binding(
            get: { model.selectedString },
            set: {
                model.selectedString = $0
                model.didChangeSelectedString()
            }
        )
    }

    private var positionFilterBinding: Binding<NotePositionFilter> {
        Binding(
            get: { model.positionFilter },
            set: {
                model.positionFilter = $0
                model.didChangePositionFilter()
            }
        )
    }
}
