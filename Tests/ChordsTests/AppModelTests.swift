import XCTest
@testable import ChordsLib

@MainActor
final class AppModelTests: XCTestCase {
    private func makeDefaults() -> UserDefaults {
        UserDefaults(suiteName: UUID().uuidString)!
    }

    // MARK: - Persistence Round-Trip

    func testPersistenceRoot() {
        let defaults = makeDefaults()
        let model = AppModel(defaults: defaults)
        model.selectedRoot = .gSharp
        model.didChangeRoot()
        let reloaded = AppModel(defaults: defaults)
        XCTAssertEqual(reloaded.selectedRoot, .gSharp)
    }

    func testPersistenceChordType() {
        let defaults = makeDefaults()
        let model = AppModel(defaults: defaults)
        model.selectedChordType = .diminished
        model.didChangeChordType()
        let reloaded = AppModel(defaults: defaults)
        XCTAssertEqual(reloaded.selectedChordType, .diminished)
    }

    func testPersistenceScaleType() {
        let defaults = makeDefaults()
        let model = AppModel(defaults: defaults)
        model.selectedScaleType = .blues
        model.didChangeScaleType()
        let reloaded = AppModel(defaults: defaults)
        XCTAssertEqual(reloaded.selectedScaleType, .blues)
    }

    func testPersistenceMenuBarIcon() {
        let defaults = makeDefaults()
        let model = AppModel(defaults: defaults)
        model.menuBarIconName = "pianokeys"
        model.didChangeMenuBarIcon()
        let reloaded = AppModel(defaults: defaults)
        XCTAssertEqual(reloaded.menuBarIconName, "pianokeys")
    }

    func testPersistenceNoteNaming() {
        let defaults = makeDefaults()
        let model = AppModel(defaults: defaults)
        model.noteNaming = .flats
        model.didChangeNoteNaming()
        let reloaded = AppModel(defaults: defaults)
        XCTAssertEqual(reloaded.noteNaming, .flats)
    }

    func testPersistencePopoverSize() {
        let defaults = makeDefaults()
        let model = AppModel(defaults: defaults)
        model.popoverSize = .spacious
        model.didChangePopoverSize()
        let reloaded = AppModel(defaults: defaults)
        XCTAssertEqual(reloaded.popoverSize, .spacious)
    }

    func testPersistencePositionFilter() {
        let defaults = makeDefaults()
        let model = AppModel(defaults: defaults)
        model.positionFilter = .fiveTo12
        model.didChangePositionFilter()
        let reloaded = AppModel(defaults: defaults)
        XCTAssertEqual(reloaded.positionFilter, .fiveTo12)
    }

    func testPersistenceQuizFilter() {
        let defaults = makeDefaults()
        let model = AppModel(defaults: defaults)
        model.quizFilter = .openOnly
        model.didChangeQuizFilter()
        let reloaded = AppModel(defaults: defaults)
        XCTAssertEqual(reloaded.quizFilter, .openOnly)
    }

    func testPersistenceMode() {
        let defaults = makeDefaults()
        let model = AppModel(defaults: defaults)
        model.selectedMode = .notes
        model.didChangeMode()
        let reloaded = AppModel(defaults: defaults)
        XCTAssertEqual(reloaded.selectedMode, .notes)
    }

    func testPersistenceQuizState() {
        let defaults = makeDefaults()
        let model = AppModel(defaults: defaults)
        model.quizState.recordCorrect()
        model.quizState.recordCorrect()
        model.quizState.recordCorrect()
        model.quizState.recordIncorrect()
        model.didChangeMode() // triggers save
        let reloaded = AppModel(defaults: defaults)
        XCTAssertEqual(reloaded.quizState.correctCount, 3)
        XCTAssertEqual(reloaded.quizState.totalCount, 4)
        XCTAssertEqual(reloaded.quizState.currentStreak, 0)
        XCTAssertEqual(reloaded.quizState.bestStreak, 3)
    }

    // MARK: - Quiz Flow

    func testGenerateQuizChordAll() {
        let model = AppModel(defaults: makeDefaults())
        model.quizFilter = .all
        model.generateQuizChord()
        XCTAssertNotNil(model.currentQuizChord)
        XCTAssertNil(model.userGuessRoot)
        XCTAssertNil(model.userGuessType)
        XCTAssertFalse(model.isQuizAnswered)
        XCTAssertFalse(model.isQuizCorrect)
    }

    func testGenerateQuizChordOpenOnly() {
        let model = AppModel(defaults: makeDefaults())
        model.quizFilter = .openOnly
        model.generateQuizChord()
        XCTAssertNotNil(model.currentQuizChord)
        let hasOpen = model.currentQuizChord?.positions.contains { $0.id == "open" }
        XCTAssertEqual(hasOpen, true)
    }

    func testSubmitQuizGuessCorrect() {
        let model = AppModel(defaults: makeDefaults())
        model.generateQuizChord()
        guard let chord = model.currentQuizChord else { return XCTFail("no chord") }
        let result = model.submitQuizGuess(root: chord.root, type: chord.type)
        XCTAssertTrue(result)
        XCTAssertTrue(model.isQuizAnswered)
        XCTAssertTrue(model.isQuizCorrect)
        XCTAssertTrue(model.quizState.lastAnswerCorrect!)
        XCTAssertEqual(model.quizState.currentStreak, 1)
    }

    func testSubmitQuizGuessIncorrect() {
        let model = AppModel(defaults: makeDefaults())
        model.generateQuizChord()
        guard let chord = model.currentQuizChord else { return XCTFail("no chord") }
        let wrongRoot = Note.allCases.first { $0 != chord.root } ?? .c
        let result = model.submitQuizGuess(root: wrongRoot, type: chord.type)
        XCTAssertFalse(result)
        XCTAssertTrue(model.isQuizAnswered)
        XCTAssertFalse(model.isQuizCorrect)
        XCTAssertFalse(model.quizState.lastAnswerCorrect!)
        XCTAssertEqual(model.quizState.currentStreak, 0)
    }

    func testGuessResetOnGenerate() {
        let model = AppModel(defaults: makeDefaults())
        model.generateQuizChord()
        model.userGuessRoot = .c
        model.userGuessType = .major
        model.generateQuizChord()
        XCTAssertNil(model.userGuessRoot)
        XCTAssertNil(model.userGuessType)
        XCTAssertFalse(model.isQuizAnswered)
    }

    // MARK: - Note Recognition

    func testGenerateNoteTargetAllStrings() {
        let model = AppModel(defaults: makeDefaults())
        for _ in 0..<100 {
            model.selectedString = nil
            model.positionFilter = .any
            model.generateNoteTarget()
            XCTAssertNotNil(model.currentNoteTarget)
            XCTAssertNotNil(model.noteTargetFret)
            XCTAssertFalse(model.isNoteRevealed)
        }
    }

    func testGenerateNoteTargetPerString() {
        let model = AppModel(defaults: makeDefaults())
        for string in GuitarString.allCases {
            for _ in 0..<50 {
                model.selectedString = string
                model.positionFilter = .any
                model.generateNoteTarget()
                XCTAssertNotNil(model.currentNoteTarget)
                XCTAssertNotNil(model.noteTargetFret)
                let fretRange = model.positionFilter.range
                if let fret = model.noteTargetFret {
                    XCTAssertTrue(fretRange.contains(fret), "Fret \(fret) should be in \(fretRange)")
                }
            }
        }
    }

    func testGenerateNoteTargetInRange() {
        let model = AppModel(defaults: makeDefaults())
        model.selectedString = nil
        for filter in [NotePositionFilter.openTo5, .fiveTo12] {
            model.positionFilter = filter
            for _ in 0..<50 {
                model.generateNoteTarget()
                if let fret = model.noteTargetFret {
                    XCTAssertTrue(filter.range.contains(fret))
                }
            }
        }
    }

    func testRevealNoteSetsFlag() {
        let model = AppModel(defaults: makeDefaults())
        model.generateNoteTarget()
        XCTAssertFalse(model.isNoteRevealed)
        model.revealNote()
        XCTAssertTrue(model.isNoteRevealed)
    }

    func testRevealResetsOnGenerate() {
        let model = AppModel(defaults: makeDefaults())
        model.generateNoteTarget()
        model.revealNote()
        model.generateNoteTarget()
        XCTAssertFalse(model.isNoteRevealed)
    }

    // MARK: - Current Chord Position

    func testCurrentChordPositionClamping() {
        let model = AppModel(defaults: makeDefaults())
        model.selectedRoot = .c
        model.selectedChordType = .major
        guard let chord = model.browseChord else { return XCTFail("C major not found") }
        model.selectedChordPositionIndex = 999
        let pos = model.currentChordPosition
        let lastPos = chord.positions.last
        XCTAssertEqual(pos, lastPos)
        model.selectedChordPositionIndex = 0
        let firstPos = model.currentChordPosition
        XCTAssertEqual(firstPos, chord.positions.first)
    }

    func testCurrentChordPositionNilWhenMissing() {
        let model = AppModel(defaults: makeDefaults())
        model.selectedRoot = .fSharp
        model.selectedChordType = .augmented
        let chord = model.browseChord
        if chord == nil {
            XCTAssertNil(model.currentChordPosition)
        }
    }

    // MARK: - Note Name

    func testNoteNameSharps() {
        let model = AppModel(defaults: makeDefaults())
        model.noteNaming = .sharps
        XCTAssertEqual(model.noteName(.cSharp), "C#")
        XCTAssertEqual(model.noteName(.c), "C")
    }

    func testNoteNameFlats() {
        let model = AppModel(defaults: makeDefaults())
        model.noteNaming = .flats
        XCTAssertEqual(model.noteName(.cSharp), "D\u{266D}")
        XCTAssertEqual(model.noteName(.c), "C")
    }
}
