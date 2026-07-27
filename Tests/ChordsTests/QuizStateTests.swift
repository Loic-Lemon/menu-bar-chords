import XCTest
@testable import ChordsLib

final class QuizStateTests: XCTestCase {
    func testInitialState() {
        let state = QuizState()
        XCTAssertEqual(state.rootCorrectCount, 0)
        XCTAssertEqual(state.rootTotalCount, 0)
        XCTAssertEqual(state.typeCorrectCount, 0)
        XCTAssertEqual(state.typeTotalCount, 0)
        XCTAssertEqual(state.combinedCorrectCount, 0)
        XCTAssertEqual(state.combinedTotalCount, 0)
        XCTAssertEqual(state.currentStreak, 0)
        XCTAssertEqual(state.bestStreak, 0)
        XCTAssertNil(state.lastAnswerRootCorrect)
        XCTAssertNil(state.lastAnswerTypeCorrect)
        XCTAssertNil(state.lastAnswerCombinedCorrect)
    }

    func testRecordRootCorrectOnly() {
        var state = QuizState()
        state.record(rootCorrect: true, typeCorrect: false)
        XCTAssertEqual(state.rootCorrectCount, 1)
        XCTAssertEqual(state.rootTotalCount, 1)
        XCTAssertEqual(state.typeCorrectCount, 0)
        XCTAssertEqual(state.typeTotalCount, 1)
        XCTAssertEqual(state.combinedCorrectCount, 0)
        XCTAssertEqual(state.combinedTotalCount, 1)
        XCTAssertTrue(state.lastAnswerRootCorrect!)
        XCTAssertFalse(state.lastAnswerTypeCorrect!)
        XCTAssertFalse(state.lastAnswerCombinedCorrect!)
        XCTAssertEqual(state.currentStreak, 0)
    }

    func testRecordTypeCorrectOnly() {
        var state = QuizState()
        state.record(rootCorrect: false, typeCorrect: true)
        XCTAssertEqual(state.rootCorrectCount, 0)
        XCTAssertEqual(state.rootTotalCount, 1)
        XCTAssertEqual(state.typeCorrectCount, 1)
        XCTAssertEqual(state.typeTotalCount, 1)
        XCTAssertEqual(state.combinedCorrectCount, 0)
        XCTAssertEqual(state.combinedTotalCount, 1)
        XCTAssertFalse(state.lastAnswerRootCorrect!)
        XCTAssertTrue(state.lastAnswerTypeCorrect!)
        XCTAssertFalse(state.lastAnswerCombinedCorrect!)
        XCTAssertEqual(state.currentStreak, 0)
    }

    func testRecordBothCorrect() {
        var state = QuizState()
        state.record(rootCorrect: true, typeCorrect: true)
        XCTAssertEqual(state.rootCorrectCount, 1)
        XCTAssertEqual(state.typeCorrectCount, 1)
        XCTAssertEqual(state.combinedCorrectCount, 1)
        XCTAssertEqual(state.rootTotalCount, 1)
        XCTAssertEqual(state.typeTotalCount, 1)
        XCTAssertEqual(state.combinedTotalCount, 1)
        XCTAssertTrue(state.lastAnswerRootCorrect!)
        XCTAssertTrue(state.lastAnswerTypeCorrect!)
        XCTAssertTrue(state.lastAnswerCombinedCorrect!)
        XCTAssertEqual(state.currentStreak, 1)
        XCTAssertEqual(state.bestStreak, 1)
    }

    func testStreakIncrementsOnCombinedCorrect() {
        var state = QuizState()
        state.record(rootCorrect: true, typeCorrect: true)
        state.record(rootCorrect: true, typeCorrect: true)
        state.record(rootCorrect: true, typeCorrect: true)
        XCTAssertEqual(state.combinedCorrectCount, 3)
        XCTAssertEqual(state.combinedTotalCount, 3)
        XCTAssertEqual(state.currentStreak, 3)
        XCTAssertEqual(state.bestStreak, 3)
    }

    func testStreakResetsOnIncorrect() {
        var state = QuizState()
        state.record(rootCorrect: true, typeCorrect: true)
        state.record(rootCorrect: true, typeCorrect: true)
        state.record(rootCorrect: false, typeCorrect: false)
        XCTAssertEqual(state.combinedCorrectCount, 2)
        XCTAssertEqual(state.combinedTotalCount, 3)
        XCTAssertEqual(state.currentStreak, 0)
        XCTAssertEqual(state.bestStreak, 2)
    }

    func testBestStreakTracksMax() {
        var state = QuizState()
        state.record(rootCorrect: true, typeCorrect: true)
        state.record(rootCorrect: true, typeCorrect: true)
        state.record(rootCorrect: true, typeCorrect: true)
        XCTAssertEqual(state.bestStreak, 3)
        state.record(rootCorrect: false, typeCorrect: false)
        state.record(rootCorrect: true, typeCorrect: true)
        state.record(rootCorrect: true, typeCorrect: true)
        XCTAssertEqual(state.bestStreak, 3)
        state.record(rootCorrect: true, typeCorrect: true)
        state.record(rootCorrect: true, typeCorrect: true)
        state.record(rootCorrect: true, typeCorrect: true)
        state.record(rootCorrect: true, typeCorrect: true)
        XCTAssertEqual(state.bestStreak, 4)
    }

    func testScorePercentages() {
        var state = QuizState()
        state.record(rootCorrect: true, typeCorrect: true)
        state.record(rootCorrect: true, typeCorrect: false)
        state.record(rootCorrect: false, typeCorrect: true)
        state.record(rootCorrect: false, typeCorrect: false)
        XCTAssertEqual(state.rootScore, 50)
        XCTAssertEqual(state.typeScore, 50)
        XCTAssertEqual(state.combinedScore, 25)
    }

    func testReset() {
        var state = QuizState()
        state.record(rootCorrect: true, typeCorrect: true)
        state.record(rootCorrect: true, typeCorrect: false)
        state.record(rootCorrect: false, typeCorrect: false)
        state.reset()
        XCTAssertEqual(state.rootCorrectCount, 0)
        XCTAssertEqual(state.rootTotalCount, 0)
        XCTAssertEqual(state.typeCorrectCount, 0)
        XCTAssertEqual(state.typeTotalCount, 0)
        XCTAssertEqual(state.combinedCorrectCount, 0)
        XCTAssertEqual(state.combinedTotalCount, 0)
        XCTAssertEqual(state.currentStreak, 0)
        XCTAssertEqual(state.bestStreak, 0)
        XCTAssertNil(state.lastAnswerRootCorrect)
        XCTAssertNil(state.lastAnswerTypeCorrect)
        XCTAssertNil(state.lastAnswerCombinedCorrect)
    }

    func testLastAnswerTracks() {
        var state = QuizState()
        state.record(rootCorrect: true, typeCorrect: true)
        XCTAssertTrue(state.lastAnswerRootCorrect!)
        XCTAssertTrue(state.lastAnswerTypeCorrect!)
        XCTAssertTrue(state.lastAnswerCombinedCorrect!)
        state.record(rootCorrect: false, typeCorrect: false)
        XCTAssertFalse(state.lastAnswerRootCorrect!)
        XCTAssertFalse(state.lastAnswerTypeCorrect!)
        XCTAssertFalse(state.lastAnswerCombinedCorrect!)
        state.record(rootCorrect: true, typeCorrect: false)
        XCTAssertTrue(state.lastAnswerRootCorrect!)
        XCTAssertFalse(state.lastAnswerTypeCorrect!)
        XCTAssertFalse(state.lastAnswerCombinedCorrect!)
    }

    func testQuizStateIsCodable() {
        var state = QuizState()
        state.record(rootCorrect: true, typeCorrect: true)
        state.record(rootCorrect: true, typeCorrect: false)
        state.record(rootCorrect: false, typeCorrect: false)
        state.record(rootCorrect: true, typeCorrect: true)

        let data = try! JSONEncoder().encode(state)
        let decoded = try! JSONDecoder().decode(QuizState.self, from: data)

        XCTAssertEqual(decoded.rootCorrectCount, state.rootCorrectCount)
        XCTAssertEqual(decoded.rootTotalCount, state.rootTotalCount)
        XCTAssertEqual(decoded.typeCorrectCount, state.typeCorrectCount)
        XCTAssertEqual(decoded.typeTotalCount, state.typeTotalCount)
        XCTAssertEqual(decoded.combinedCorrectCount, state.combinedCorrectCount)
        XCTAssertEqual(decoded.combinedTotalCount, state.combinedTotalCount)
        XCTAssertEqual(decoded.currentStreak, state.currentStreak)
        XCTAssertEqual(decoded.bestStreak, state.bestStreak)
        XCTAssertEqual(decoded.lastAnswerRootCorrect!, state.lastAnswerRootCorrect!)
        XCTAssertEqual(decoded.lastAnswerTypeCorrect!, state.lastAnswerTypeCorrect!)
        XCTAssertEqual(decoded.lastAnswerCombinedCorrect!, state.lastAnswerCombinedCorrect!)
    }
}
