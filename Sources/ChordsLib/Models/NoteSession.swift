import Foundation

public struct NoteSession: Codable, Sendable, Identifiable {
    public let id: UUID
    public let startTime: Date
    public var endTime: Date?
    public var totalNotes: Int
    public var correctCount: Int
    public var incorrectCount: Int

    public var duration: TimeInterval {
        guard let end = endTime else { return Date().timeIntervalSince(startTime) }
        return end.timeIntervalSince(startTime)
    }

    public var isActive: Bool { endTime == nil }

    public var accuracy: Int {
        totalNotes > 0 ? correctCount * 100 / totalNotes : 0
    }

    public init(
        id: UUID = UUID(),
        startTime: Date = Date(),
        endTime: Date? = nil,
        totalNotes: Int = 0,
        correctCount: Int = 0,
        incorrectCount: Int = 0
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.totalNotes = totalNotes
        self.correctCount = correctCount
        self.incorrectCount = incorrectCount
    }

    public mutating func recordAnswer(correct: Bool) {
        totalNotes += 1
        if correct {
            correctCount += 1
        } else {
            incorrectCount += 1
        }
    }

    public mutating func endSession() {
        if endTime == nil {
            endTime = Date()
        }
    }
}
