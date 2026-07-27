import Foundation

public struct QuizState: Codable, Sendable {
    public var rootCorrectCount = 0
    public var rootTotalCount = 0
    public var typeCorrectCount = 0
    public var typeTotalCount = 0
    public var combinedCorrectCount = 0
    public var combinedTotalCount = 0
    public var currentStreak = 0
    public var bestStreak = 0
    public var lastAnswerRootCorrect: Bool?
    public var lastAnswerTypeCorrect: Bool?
    public var lastAnswerCombinedCorrect: Bool?

    public var rootScore: Int {
        rootTotalCount > 0 ? rootCorrectCount * 100 / rootTotalCount : 0
    }

    public var typeScore: Int {
        typeTotalCount > 0 ? typeCorrectCount * 100 / typeTotalCount : 0
    }

    public var combinedScore: Int {
        combinedTotalCount > 0 ? combinedCorrectCount * 100 / combinedTotalCount : 0
    }

    public init() {}

    public mutating func record(rootCorrect: Bool, typeCorrect: Bool) {
        if rootCorrect { rootCorrectCount += 1 }
        rootTotalCount += 1
        if typeCorrect { typeCorrectCount += 1 }
        typeTotalCount += 1
        let combined = rootCorrect && typeCorrect
        if combined { combinedCorrectCount += 1 }
        combinedTotalCount += 1
        lastAnswerRootCorrect = rootCorrect
        lastAnswerTypeCorrect = typeCorrect
        lastAnswerCombinedCorrect = combined
        if combined {
            currentStreak += 1
            if currentStreak > bestStreak {
                bestStreak = currentStreak
            }
        } else {
            currentStreak = 0
        }
    }

    public mutating func reset() {
        rootCorrectCount = 0
        rootTotalCount = 0
        typeCorrectCount = 0
        typeTotalCount = 0
        combinedCorrectCount = 0
        combinedTotalCount = 0
        currentStreak = 0
        bestStreak = 0
        lastAnswerRootCorrect = nil
        lastAnswerTypeCorrect = nil
        lastAnswerCombinedCorrect = nil
    }
}
