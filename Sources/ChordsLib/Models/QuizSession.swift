import Foundation

public struct QuizSession: Codable, Sendable, Identifiable {
    public let id: UUID
    public let startTime: Date
    public var endTime: Date?
    public var rootCorrectCount: Int
    public var rootTotalCount: Int
    public var typeCorrectCount: Int
    public var typeTotalCount: Int
    public var combinedCorrectCount: Int
    public var combinedTotalCount: Int

    public var rootScore: Int {
        rootTotalCount > 0 ? rootCorrectCount * 100 / rootTotalCount : 0
    }

    public var typeScore: Int {
        typeTotalCount > 0 ? typeCorrectCount * 100 / typeTotalCount : 0
    }

    public var combinedScore: Int {
        combinedTotalCount > 0 ? combinedCorrectCount * 100 / combinedTotalCount : 0
    }

    public var duration: TimeInterval {
        guard let end = endTime else { return Date().timeIntervalSince(startTime) }
        return end.timeIntervalSince(startTime)
    }

    public var isActive: Bool { endTime == nil }

    public init(
        id: UUID = UUID(),
        startTime: Date = Date(),
        endTime: Date? = nil,
        rootCorrectCount: Int = 0,
        rootTotalCount: Int = 0,
        typeCorrectCount: Int = 0,
        typeTotalCount: Int = 0,
        combinedCorrectCount: Int = 0,
        combinedTotalCount: Int = 0
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.rootCorrectCount = rootCorrectCount
        self.rootTotalCount = rootTotalCount
        self.typeCorrectCount = typeCorrectCount
        self.typeTotalCount = typeTotalCount
        self.combinedCorrectCount = combinedCorrectCount
        self.combinedTotalCount = combinedTotalCount
    }

    public mutating func record(rootCorrect: Bool, typeCorrect: Bool) {
        if rootCorrect { rootCorrectCount += 1 }
        rootTotalCount += 1
        if typeCorrect { typeCorrectCount += 1 }
        typeTotalCount += 1
        if rootCorrect && typeCorrect { combinedCorrectCount += 1 }
        combinedTotalCount += 1
    }

    public mutating func endSession() {
        if endTime == nil {
            endTime = Date()
        }
    }
}
