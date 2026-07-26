import XCTest
@testable import ChordsLib

final class QuizStateTests: XCTestCase {
    func testInitialState() {
        let state = QuizState()
        XCTAssertEqual(state.correctCount, 0)
        XCTAssertEqual(state.totalCount, 0)
        XCTAssertEqual(state.currentStreak, 0)
        XCTAssertEqual(state.bestStreak, 0)
        XCTAssertNil(state.lastAnswerCorrect)
    }

    func testScorePercentIsZeroOnInit() {
        let state = QuizState()
        XCTAssertEqual(state.scorePercent, 0)
    }

    func testRecordCorrect() {
        let state = QuizState()
        state.recordCorrect()
        XCTAssertEqual(state.correctCount, 1)
        XCTAssertEqual(state.totalCount, 1)
        XCTAssertEqual(state.currentStreak, 1)
        XCTAssertEqual(state.bestStreak, 1)
        XCTAssertTrue(state.lastAnswerCorrect!)
    }

    func testRecordIncorrect() {
        let state = QuizState()
        state.recordIncorrect()
        XCTAssertEqual(state.correctCount, 0)
        XCTAssertEqual(state.totalCount, 1)
        XCTAssertEqual(state.currentStreak, 0)
        XCTAssertEqual(state.bestStreak, 0)
        XCTAssertFalse(state.lastAnswerCorrect!)
    }

    func testStreakIncrementsOnConsecutiveCorrect() {
        let state = QuizState()
        state.recordCorrect()
        state.recordCorrect()
        state.recordCorrect()
        XCTAssertEqual(state.correctCount, 3)
        XCTAssertEqual(state.totalCount, 3)
        XCTAssertEqual(state.currentStreak, 3)
        XCTAssertEqual(state.bestStreak, 3)
    }

    func testStreakResetsOnIncorrect() {
        let state = QuizState()
        state.recordCorrect()
        state.recordCorrect()
        state.recordIncorrect()
        XCTAssertEqual(state.correctCount, 2)
        XCTAssertEqual(state.totalCount, 3)
        XCTAssertEqual(state.currentStreak, 0)
        XCTAssertEqual(state.bestStreak, 2)
    }

    func testBestStreakTracksMax() {
        let state = QuizState()
        state.recordCorrect()
        state.recordCorrect()
        state.recordCorrect()
        XCTAssertEqual(state.bestStreak, 3)
        state.recordIncorrect()
        state.recordCorrect()
        state.recordCorrect()
        XCTAssertEqual(state.bestStreak, 3)
        state.recordCorrect()
        state.recordCorrect()
        state.recordCorrect()
        state.recordCorrect()
        XCTAssertEqual(state.bestStreak, 4)
    }

    func testScorePercentCalculation() {
        let state = QuizState()
        state.recordCorrect()
        state.recordIncorrect()
        state.recordCorrect()
        state.recordCorrect()
        XCTAssertEqual(state.correctCount, 3)
        XCTAssertEqual(state.totalCount, 4)
        XCTAssertEqual(state.scorePercent, 75)
    }

    func testReset() {
        let state = QuizState()
        state.recordCorrect()
        state.recordCorrect()
        state.recordIncorrect()
        state.reset()
        XCTAssertEqual(state.correctCount, 0)
        XCTAssertEqual(state.totalCount, 0)
        XCTAssertEqual(state.currentStreak, 0)
        XCTAssertEqual(state.bestStreak, 0)
        XCTAssertNil(state.lastAnswerCorrect)
        XCTAssertEqual(state.scorePercent, 0)
    }

    func testLastAnswerCorrectTracks() {
        let state = QuizState()
        state.recordCorrect()
        XCTAssertTrue(state.lastAnswerCorrect!)
        state.recordCorrect()
        XCTAssertTrue(state.lastAnswerCorrect!)
        state.recordIncorrect()
        XCTAssertFalse(state.lastAnswerCorrect!)
    }

    func testQuizStateIsCodable() {
        let state = QuizState()
        state.recordCorrect()
        state.recordCorrect()
        state.recordIncorrect()
        state.recordCorrect()

        let data = try! JSONEncoder().encode(state)
        let decoded = try! JSONDecoder().decode(QuizState.self, from: data)

        XCTAssertEqual(decoded.correctCount, state.correctCount)
        XCTAssertEqual(decoded.totalCount, state.totalCount)
        XCTAssertEqual(decoded.currentStreak, state.currentStreak)
        XCTAssertEqual(decoded.bestStreak, state.bestStreak)
    }
}
