import SwiftUI
import ChordsLib

struct ChordQuizView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        VStack(spacing: 12) {
            Text("Guess the chord")
                .font(.headline)
                .padding(.top, 4)

            if let chord = model.currentQuizChord, let position = chord.positions.first {
                FretboardView(
                    frets: position.frets,
                    fingers: position.fingers,
                    barres: position.barres,
                    baseFret: position.baseFret
                )
            }

            if !model.isQuizAnswered {
                guessControls
            } else {
                resultView
            }

            scoreDisplay

            if model.isQuizAnswered {
                Button("Next Chord") {
                    model.generateQuizChord()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
        }
    }

    private var guessControls: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Root")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Picker("", selection: guessRootBinding) {
                    ForEach(Note.allCases, id: \.self) { note in
                        Text(note.name).tag(note as Note?)
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)
            }

            HStack {
                Text("Type")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Picker("", selection: guessTypeBinding) {
                    ForEach(ChordType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type as ChordType?)
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)
            }

            Button("Check") {
                guard let root = model.userGuessRoot, let type = model.userGuessType else { return }
                _ = model.submitQuizGuess(root: root, type: type)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
            .disabled(model.userGuessRoot == nil || model.userGuessType == nil)
        }
    }

    private var resultView: some View {
        VStack(spacing: 4) {
            if model.isQuizCorrect {
                Label("Correct!", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.headline)
            } else if let chord = model.currentQuizChord {
                VStack(spacing: 2) {
                    Label("Nope!", systemImage: "xmark.circle.fill")
                        .foregroundStyle(.red)
                        .font(.headline)
                    Text("That was \(chord.root.name)\(chord.type.symbol)")
                        .font(.subheadline)
                }
            }
        }
    }

    private var scoreDisplay: some View {
        VStack(spacing: 2) {
            Text("Score: \(model.quizState.correctCount)/\(model.quizState.totalCount) (\(Int(model.quizState.scorePercent))%)")
                .font(.caption)
            Text("Streak: \(model.quizState.currentStreak)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var guessRootBinding: Binding<Note?> {
        Binding(
            get: { model.userGuessRoot },
            set: { model.userGuessRoot = $0 }
        )
    }

    private var guessTypeBinding: Binding<ChordType?> {
        Binding(
            get: { model.userGuessType },
            set: { model.userGuessType = $0 }
        )
    }
}
