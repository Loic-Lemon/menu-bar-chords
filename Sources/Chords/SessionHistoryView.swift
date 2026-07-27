import SwiftUI
import ChordsLib

private enum HistoryFilter: String, CaseIterable {
    case quiz, notes

    var label: String {
        switch self {
        case .quiz: "Quiz"
        case .notes: "Notes"
        }
    }
}

private enum DeleteTarget: Identifiable {
    case quiz(UUID)
    case notes(UUID)

    var id: UUID {
        switch self {
        case .quiz(let id): id
        case .notes(let id): id
        }
    }
}

struct SessionHistoryView: View {
    @Environment(AppModel.self) private var model
    @State private var filter: HistoryFilter = .quiz
    @State private var deleteConfirmation: DeleteTarget?

    private var currentSessionsEmpty: Bool {
        switch filter {
        case .quiz: model.sessions.isEmpty
        case .notes: model.noteSessions.isEmpty
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Session History")
                    .font(.caption.weight(.semibold))
                Spacer()
                Picker("", selection: $filter) {
                    ForEach(HistoryFilter.allCases, id: \.self) { f in
                        Text(f.label).tag(f)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .frame(width: 140)
            }
            .padding(.bottom, 2)

            if currentSessionsEmpty {
                Text("No completed sessions yet.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 12)
            } else {
                headerRow
                Divider()
                ScrollView(.vertical) {
                    VStack(spacing: 0) {
                        switch filter {
                        case .quiz:
                            ForEach(sortedQuizSessions) { session in
                                quizRowView(session)
                                Divider().opacity(0.5)
                            }
                        case .notes:
                            ForEach(sortedNoteSessions) { session in
                                noteRowView(session)
                                Divider().opacity(0.5)
                            }
                        }
                    }
                }
                .frame(height: min(maxListHeight, 250))
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(Color(.separatorColor).opacity(0.08))
        .cornerRadius(8)
        .alert(item: $deleteConfirmation) { target in
            switch target {
            case .quiz(let id):
                Alert(
                    title: Text("Delete Session"),
                    message: Text("Are you sure you want to delete this quiz session?"),
                    primaryButton: .destructive(Text("Delete")) {
                        model.deleteQuizSession(id: id)
                    },
                    secondaryButton: .cancel()
                )
            case .notes(let id):
                Alert(
                    title: Text("Delete Session"),
                    message: Text("Are you sure you want to delete this note practice session?"),
                    primaryButton: .destructive(Text("Delete")) {
                        model.deleteNoteSession(id: id)
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }

    private var maxListHeight: CGFloat {
        let count: Int
        switch filter {
        case .quiz: count = sortedQuizSessions.count
        case .notes: count = sortedNoteSessions.count
        }
        return CGFloat(count) * 26 + 4
    }

    private var sortedQuizSessions: [QuizSession] {
        model.sessions.sorted { $0.startTime > $1.startTime }
    }

    private var sortedNoteSessions: [NoteSession] {
        model.noteSessions.sorted { $0.startTime > $1.startTime }
    }

    @ViewBuilder
    private var headerRow: some View {
        switch filter {
        case .quiz:
            quizHeaderRow
        case .notes:
            noteHeaderRow
        }
    }

    private var quizHeaderRow: some View {
        HStack(spacing: 0) {
            Text("Date").font(.caption2.weight(.medium)).frame(width: 82, alignment: .leading)
            Text("Roots").font(.caption2.weight(.medium)).frame(width: 42, alignment: .trailing)
            Text("Types").font(.caption2.weight(.medium)).frame(width: 42, alignment: .trailing)
            Text("Comb.").font(.caption2.weight(.medium)).frame(width: 42, alignment: .trailing)
            Text("Time").font(.caption2.weight(.medium)).frame(width: 42, alignment: .trailing)
            Spacer().frame(width: 18)
        }
        .padding(.vertical, 2)
    }

    private var noteHeaderRow: some View {
        HStack(spacing: 0) {
            Text("Date").font(.caption2.weight(.medium)).frame(width: 82, alignment: .leading)
            Text("Notes").font(.caption2.weight(.medium)).frame(width: 42, alignment: .trailing)
            Text("Correct").font(.caption2.weight(.medium)).frame(width: 50, alignment: .trailing)
            Text("Wrong").font(.caption2.weight(.medium)).frame(width: 42, alignment: .trailing)
            Text("Acc.").font(.caption2.weight(.medium)).frame(width: 34, alignment: .trailing)
            Spacer().frame(width: 18)
        }
        .padding(.vertical, 2)
    }

    private func quizRowView(_ session: QuizSession) -> some View {
        HStack(spacing: 0) {
            Text(formatDate(session.startTime))
                .font(.system(size: 9, design: .monospaced))
                .frame(width: 82, alignment: .leading)
                .lineLimit(1)
            scoreText(correct: session.rootCorrectCount, total: session.rootTotalCount)
                .frame(width: 42, alignment: .trailing)
            scoreText(correct: session.typeCorrectCount, total: session.typeTotalCount)
                .frame(width: 42, alignment: .trailing)
            scoreText(correct: session.combinedCorrectCount, total: session.combinedTotalCount)
                .frame(width: 42, alignment: .trailing)
            Text(formatDuration(session.duration))
                .font(.system(size: 9, design: .monospaced))
                .frame(width: 42, alignment: .trailing)
            deleteButton { deleteConfirmation = .quiz(session.id) }
        }
        .padding(.vertical, 2)
    }

    private func noteRowView(_ session: NoteSession) -> some View {
        HStack(spacing: 0) {
            Text(formatDate(session.startTime))
                .font(.system(size: 9, design: .monospaced))
                .frame(width: 82, alignment: .leading)
                .lineLimit(1)
            Text("\(session.totalNotes)")
                .font(.system(size: 9, design: .monospaced))
                .frame(width: 42, alignment: .trailing)
            Text("\(session.correctCount)")
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(.green)
                .frame(width: 50, alignment: .trailing)
            Text("\(session.incorrectCount)")
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(.red)
                .frame(width: 42, alignment: .trailing)
            Text("\(session.accuracy)%")
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(session.accuracy >= 50 ? .green : session.accuracy > 0 ? .orange : .secondary)
                .frame(width: 34, alignment: .trailing)
            deleteButton { deleteConfirmation = .notes(session.id) }
        }
        .padding(.vertical, 2)
    }

    private func deleteButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 7, weight: .bold))
                .foregroundStyle(.secondary)
                .frame(width: 14, height: 14)
                .background(Color(.separatorColor).opacity(0.15))
                .cornerRadius(4)
        }
        .buttonStyle(.plain)
        .help("Delete session")
    }

    private func scoreText(correct: Int, total: Int) -> Text {
        let pct = total > 0 ? correct * 100 / total : 0
        return Text("\(pct)%")
            .font(.system(size: 9, design: .monospaced))
            .foregroundStyle(pct >= 50 ? .green : pct > 0 ? .orange : .secondary)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d · HH:mm"
        return formatter.string(from: date)
    }

    private func formatDuration(_ interval: TimeInterval) -> String {
        let total = Int(interval)
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
