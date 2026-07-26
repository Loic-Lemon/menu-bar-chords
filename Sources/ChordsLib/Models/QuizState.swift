import Foundation

public struct QuizState: Codable, Sendable {
    public var correctCount = 0
    public var totalCount = 0
    public var currentStreak = 0
    public var bestStreak = 0
    public var lastAnswerCorrect: Bool?

    public var scorePercent: Double {
        totalCount > 0 ? Double(correctCount) / Double(totalCount) * 100 : 0
    }

    public init() {}

    public mutating func recordCorrect() {
        correctCount += 1
        totalCount += 1
        currentStreak += 1
        if currentStreak > bestStreak {
            bestStreak = currentStreak
        }
        lastAnswerCorrect = true
    }

    public mutating func recordIncorrect() {
        totalCount += 1
        currentStreak = 0
        lastAnswerCorrect = false
    }

    public mutating func reset() {
        correctCount = 0
        totalCount = 0
        currentStreak = 0
        bestStreak = 0
        lastAnswerCorrect = nil
    }
}
