import Foundation
import ChordsLib

enum SelfTest {
    @MainActor
    static func run() -> Never {
        var passed = 0
        var failed = 0

        func check(_ label: String, condition: Bool) {
            if condition {
                passed += 1
            } else {
                print("[FAIL] \(label)")
                failed += 1
            }
        }

        // Chord library integrity
        let ids = ChordLibrary.all.map(\.id)
        check("unique chord IDs", condition: ids.count == Set(ids).count)
        for chord in ChordLibrary.all {
            check("\(chord.id) has positions", condition: !chord.positions.isEmpty)
            for pos in chord.positions {
                check("\(chord.id) \(pos.id) 6 frets", condition: pos.frets.count == 6)
                check("\(chord.id) \(pos.id) 6 fingers", condition: pos.fingers.count == 6)
                check("\(chord.id) \(pos.id) baseFret >= 1", condition: pos.baseFret >= 1)
                for (si, f) in pos.frets.enumerated() {
                    if let f { check("\(chord.id) \(pos.id) string \(si) fret >= 0", condition: f >= 0) }
                }
                for barre in pos.barres {
                    let col = barre.fret - pos.baseFret
                    check("\(chord.id) \(pos.id) barre in window", condition: col >= 0 && col < 3)
                    check("\(chord.id) \(pos.id) barre strings valid", condition: barre.startString >= 0 && barre.endString < 6 && barre.endString >= barre.startString)
                }
            }
            check("\(chord.id) in byId", condition: ChordLibrary.byId[chord.id] != nil)
        }

        // All root × chord type lookups
        for root in Note.allCases {
            for type in ChordType.allCases {
                let result = ChordLibrary.chord(root: root, type: type)
                if let chord = result {
                    check("chord \(root.rawValue) \(type.rawValue) root match", condition: chord.root == root)
                    check("chord \(root.rawValue) \(type.rawValue) type match", condition: chord.type == type)
                } else {
                    check("chord \(root.rawValue) \(type.rawValue) nil (ok to be missing)", condition: true)
                }
            }
        }

        // All root × scale type lookups
        for root in Note.allCases {
            for type in ScaleType.allCases {
                let result = ScaleLibrary.scale(root: root, type: type)
                if let scale = result {
                    check("scale \(root.rawValue) \(type.rawValue) root match", condition: scale.root == root)
                    check("scale \(root.rawValue) \(type.rawValue) type match", condition: scale.type == type)
                } else {
                    check("scale \(root.rawValue) \(type.rawValue) nil (ok to be missing)", condition: true)
                }
            }
        }

        // Note math
        check("12 notes", condition: Note.allCases.count == 12)
        check("C + 4 = E", condition: Note.c + 4 == .e)
        check("B + 1 = C", condition: Note.b + 1 == .c)
        check("C interval to E = 4", condition: Note.c.interval(to: .e) == 4)

        // GuitarString fret calculation
        for string in GuitarString.allCases {
            for note in Note.allCases {
                let fret = string.fret(for: note)
                check("\(string) fret(for: \(note)) in 0..12", condition: fret >= 0 && fret < 12)
                for range in [0...5, 5...12, 0...24] {
                    let inRange = string.fret(for: note, in: range)
                    if range.contains(fret) {
                        check("\(string) fret(for: \(note), in: \(range)) = \(fret)", condition: inRange == fret)
                    } else {
                        check("\(string) fret(for: \(note), in: \(range)) needs octave", condition: inRange == nil || range.contains(inRange!))
                    }
                }
            }
        }

        // QuizState
        var state = QuizState()
        check("initial rootCorrect 0", condition: state.rootCorrectCount == 0)
        check("initial combinedScore 0", condition: state.combinedScore == 0)
        state.record(rootCorrect: true, typeCorrect: true)
        state.record(rootCorrect: true, typeCorrect: true)
        state.record(rootCorrect: true, typeCorrect: true)
        check("3 combined correct streak 3 best 3", condition: state.combinedCorrectCount == 3 && state.currentStreak == 3 && state.bestStreak == 3)
        state.record(rootCorrect: false, typeCorrect: false)
        check("after incorrect streak 0", condition: state.currentStreak == 0)
        check("best streak 3 retained", condition: state.bestStreak == 3)
        state.record(rootCorrect: true, typeCorrect: true)
        state.record(rootCorrect: true, typeCorrect: true)
        state.record(rootCorrect: true, typeCorrect: true)
        state.record(rootCorrect: true, typeCorrect: true)
        check("4 more combined correct best 4", condition: state.bestStreak == 4)
        state.reset()
        check("reset all zero", condition: state.rootCorrectCount == 0 && state.rootTotalCount == 0 && state.currentStreak == 0 && state.bestStreak == 0 && state.lastAnswerCombinedCorrect == nil)

        // QuizState Codable
        var state2 = QuizState()
        state2.record(rootCorrect: true, typeCorrect: true)
        state2.record(rootCorrect: false, typeCorrect: true)
        let data = try! JSONEncoder().encode(state2)
        let decoded = try! JSONDecoder().decode(QuizState.self, from: data)
        check("quizState Codable rootCorrectCount", condition: decoded.rootCorrectCount == state2.rootCorrectCount)
        check("quizState Codable rootTotalCount", condition: decoded.rootTotalCount == state2.rootTotalCount)
        check("quizState Codable typeCorrectCount", condition: decoded.typeCorrectCount == state2.typeCorrectCount)
        check("quizState Codable combinedCorrectCount", condition: decoded.combinedCorrectCount == state2.combinedCorrectCount)

        // QuizSession
        var session = QuizSession()
        check("session initial combined 0", condition: session.combinedTotalCount == 0)
        check("session initial active", condition: session.isActive == true)
        session.record(rootCorrect: true, typeCorrect: true)
        session.record(rootCorrect: true, typeCorrect: false)
        session.record(rootCorrect: false, typeCorrect: true)
        check("session root 2/3 type 2/3 combined 1/3", condition: session.rootCorrectCount == 2 && session.rootTotalCount == 3 && session.typeCorrectCount == 2 && session.typeTotalCount == 3 && session.combinedCorrectCount == 1 && session.combinedTotalCount == 3)
        session.endSession()
        check("session not active after end", condition: session.isActive == false)
        check("session duration > 0", condition: session.duration > 0)

        // QuizSession Codable
        let sessionData = try! JSONEncoder().encode(session)
        let decodedSession = try! JSONDecoder().decode(QuizSession.self, from: sessionData)
        check("session Codable rootCorrect", condition: decodedSession.rootCorrectCount == session.rootCorrectCount)
        check("session Codable combinedTotal", condition: decodedSession.combinedTotalCount == session.combinedTotalCount)

        // AppModel persistence round-trip
        let suiteName = UUID().uuidString
        let defaults = UserDefaults(suiteName: suiteName)!
        let model = AppModel(defaults: defaults)
        model.selectedRoot = .gSharp
        model.didChangeRoot()
        model.selectedChordType = .diminished
        model.didChangeChordType()
        model.selectedScaleType = .blues
        model.didChangeScaleType()
        model.menuBarIconName = "pianokeys"
        model.didChangeMenuBarIcon()
        model.noteNaming = .flats
        model.didChangeNoteNaming()
        model.popoverSize = .spacious
        model.didChangePopoverSize()
        model.positionFilter = .fiveTo12
        model.didChangePositionFilter()
        model.quizFilter = .openOnly
        model.didChangeQuizFilter()
        model.selectedMode = .notes
        model.didChangeMode()
        model.quizState.record(rootCorrect: true, typeCorrect: true)
        model.quizState.record(rootCorrect: true, typeCorrect: true)
        model.quizState.record(rootCorrect: true, typeCorrect: true)
        model.quizState.record(rootCorrect: false, typeCorrect: false)
        model.didChangeMenuBarIcon()

        let model2 = AppModel(defaults: defaults)
        check("persistence root", condition: model2.selectedRoot == .gSharp)
        check("persistence chordType", condition: model2.selectedChordType == .diminished)
        check("persistence scaleType", condition: model2.selectedScaleType == .blues)
        check("persistence menuBarIcon", condition: model2.menuBarIconName == "pianokeys")
        check("persistence noteNaming", condition: model2.noteNaming == .flats)
        check("persistence popoverSize", condition: model2.popoverSize == .spacious)
        check("persistence positionFilter", condition: model2.positionFilter == .fiveTo12)
        check("persistence quizFilter", condition: model2.quizFilter == .openOnly)
        check("persistence mode", condition: model2.selectedMode == .notes)
        check("persistence quizState combinedCorrect", condition: model2.quizState.combinedCorrectCount == 3)
        check("persistence quizState combinedTotal", condition: model2.quizState.combinedTotalCount == 4)

        // Session persistence
        let sessionModel = AppModel(defaults: defaults)
        sessionModel.startSession()
        let cMajor = ChordLibrary.chord(root: .c, type: .major)!
        sessionModel.currentQuizChord = cMajor
        sessionModel.submitQuizGuess(root: .c, type: .major)
        sessionModel.submitQuizGuess(root: .c, type: .major)
        sessionModel.submitQuizGuess(root: .c, type: .minor)
        sessionModel.endSession()

        let reloadedSessionModel = AppModel(defaults: defaults)
        check("persistence session count 1", condition: reloadedSessionModel.sessions.count == 1)
        check("persistence session root 3/3", condition: reloadedSessionModel.sessions[0].rootCorrectCount == 3 && reloadedSessionModel.sessions[0].rootTotalCount == 3)
        check("persistence session type 2/3", condition: reloadedSessionModel.sessions[0].typeCorrectCount == 2 && reloadedSessionModel.sessions[0].typeTotalCount == 3)
        check("persistence session combined 2/3", condition: reloadedSessionModel.sessions[0].combinedCorrectCount == 2 && reloadedSessionModel.sessions[0].combinedTotalCount == 3)

        defaults.removePersistentDomain(forName: suiteName)

        print("[SelfTest] \(passed) passed, \(failed) failed")
        exit(failed == 0 ? 0 : 1)
    }
}
