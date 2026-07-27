import SwiftUI
import ChordsLib

struct ChordQuizView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        VStack(spacing: 10) {
            Text("Guess the chord")
                .font(.headline)
                .padding(.top, 4)

            sessionControls

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

    private var sessionControls: some View {
        HStack {
            if let session = model.currentSession, session.isActive {
                Text("Session · \(formatDuration(session.duration))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("End") {
                    model.endSession()
                }
                .buttonStyle(.borderless)
                .controlSize(.small)
                .foregroundStyle(.red)
            } else {
                Spacer()
                Button("Start Session") {
                    model.startSession()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding(.vertical, 2)
    }

    private var guessControls: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Root")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                PopUpButtonPicker(
                    selection: guessRootBinding,
                    items: [nil] + Note.allCases.map(Optional.some),
                    title: { $0.map { model.noteName($0) } ?? "—" }
                )
            }

            HStack {
                Text("Type")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                PopUpButtonPicker(
                    selection: guessTypeBinding,
                    items: [nil] + ChordType.allCases.map(Optional.some),
                    title: { $0?.displayName ?? "—" }
                )
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
                    HStack(spacing: 12) {
                        Label(
                            model.isQuizRootCorrect ? "Root ✓" : "Root ✗",
                            systemImage: model.isQuizRootCorrect ? "checkmark" : "xmark"
                        )
                        .font(.caption)
                        .foregroundStyle(model.isQuizRootCorrect ? .green : .red)
                        Label(
                            model.isQuizTypeCorrect ? "Type ✓" : "Type ✗",
                            systemImage: model.isQuizTypeCorrect ? "checkmark" : "xmark"
                        )
                        .font(.caption)
                        .foregroundStyle(model.isQuizTypeCorrect ? .green : .red)
                    }
                    Text("That was \(model.noteName(chord.root))\(chord.type.symbol)")
                        .font(.subheadline)
                }
            }
        }
    }

    private var scoreDisplay: some View {
        let session = model.currentSession
        let rootC = session?.rootCorrectCount ?? model.quizState.rootCorrectCount
        let rootT = session?.rootTotalCount ?? model.quizState.rootTotalCount
        let typeC = session?.typeCorrectCount ?? model.quizState.typeCorrectCount
        let typeT = session?.typeTotalCount ?? model.quizState.typeTotalCount
        let combC = session?.combinedCorrectCount ?? model.quizState.combinedCorrectCount
        let combT = session?.combinedTotalCount ?? model.quizState.combinedTotalCount
        return VStack(spacing: 2) {
            HStack(spacing: 8) {
                scoreChip(label: "Roots", correct: rootC, total: rootT)
                Text("·").foregroundStyle(.secondary)
                scoreChip(label: "Types", correct: typeC, total: typeT)
                Text("·").foregroundStyle(.secondary)
                scoreChip(label: "Combined", correct: combC, total: combT)
            }
            .font(.caption)
            Text("Streak: \(model.quizState.currentStreak)  ·  Best: \(model.quizState.bestStreak)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private func scoreChip(label: String, correct: Int, total: Int) -> some View {
        let pct = total > 0 ? correct * 100 / total : 0
        return Text("\(label) \(correct)/\(total) (\(pct)%)")
    }

    private func formatDuration(_ interval: TimeInterval) -> String {
        let total = Int(interval)
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%d:%02d", minutes, seconds)
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
