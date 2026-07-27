import SwiftUI
import ChordsLib

struct SessionHistoryView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Session History")
                    .font(.caption.weight(.semibold))
                Spacer()
            }
            .padding(.bottom, 2)

            if model.sessions.isEmpty {
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
                        ForEach(sortedSessions) { session in
                            rowView(session)
                            Divider().opacity(0.5)
                        }
                    }
                }
                .frame(maxHeight: min(CGFloat(sortedSessions.count) * 26 + 4, 180))
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(Color(.separatorColor).opacity(0.08))
        .cornerRadius(8)
    }

    private var sortedSessions: [QuizSession] {
        model.sessions.sorted { $0.startTime > $1.startTime }
    }

    private var headerRow: some View {
        HStack(spacing: 0) {
            Text("Date").font(.caption2.weight(.medium)).frame(width: 90, alignment: .leading)
            Text("Roots").font(.caption2.weight(.medium)).frame(width: 48, alignment: .trailing)
            Text("Types").font(.caption2.weight(.medium)).frame(width: 48, alignment: .trailing)
            Text("Comb.").font(.caption2.weight(.medium)).frame(width: 48, alignment: .trailing)
            Text("Time").font(.caption2.weight(.medium)).frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.vertical, 2)
    }

    private func rowView(_ session: QuizSession) -> some View {
        HStack(spacing: 0) {
            Text(formatDate(session.startTime))
                .font(.system(size: 9, design: .monospaced))
                .frame(width: 90, alignment: .leading)
                .lineLimit(1)
            scoreText(correct: session.rootCorrectCount, total: session.rootTotalCount)
                .frame(width: 48, alignment: .trailing)
            scoreText(correct: session.typeCorrectCount, total: session.typeTotalCount)
                .frame(width: 48, alignment: .trailing)
            scoreText(correct: session.combinedCorrectCount, total: session.combinedTotalCount)
                .frame(width: 48, alignment: .trailing)
            Text(formatDuration(session.duration))
                .font(.system(size: 9, design: .monospaced))
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.vertical, 2)
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
