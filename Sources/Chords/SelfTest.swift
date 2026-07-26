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
        check("initial correct 0", condition: state.correctCount == 0)
        check("initial percent 0", condition: state.scorePercent == 0)
        state.recordCorrect()
        state.recordCorrect()
        state.recordCorrect()
        check("3 correct streak 3 best 3", condition: state.correctCount == 3 && state.currentStreak == 3 && state.bestStreak == 3)
        state.recordIncorrect()
        check("after incorrect streak 0", condition: state.currentStreak == 0)
        check("best streak 3 retained", condition: state.bestStreak == 3)
        state.recordCorrect()
        state.recordCorrect()
        state.recordCorrect()
        state.recordCorrect()
        check("4 more correct best 4", condition: state.bestStreak == 4)
        state.reset()
        check("reset all zero", condition: state.correctCount == 0 && state.totalCount == 0 && state.currentStreak == 0 && state.bestStreak == 0 && state.lastAnswerCorrect == nil)

        // QuizState Codable
        var state2 = QuizState()
        state2.recordCorrect()
        state2.recordIncorrect()
        let data = try! JSONEncoder().encode(state2)
        let decoded = try! JSONDecoder().decode(QuizState.self, from: data)
        check("quizState Codable correctCount", condition: decoded.correctCount == state2.correctCount)
        check("quizState Codable totalCount", condition: decoded.totalCount == state2.totalCount)

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
        model.quizState.recordCorrect()
        model.quizState.recordCorrect()
        model.quizState.recordCorrect()
        model.quizState.recordIncorrect()
        model.didChangeMenuBarIcon() // triggers save after quizState mutations

        let model2 = AppModel(defaults: defaults) // reloads from same defaults
        check("persistence root", condition: model2.selectedRoot == .gSharp)
        check("persistence chordType", condition: model2.selectedChordType == .diminished)
        check("persistence scaleType", condition: model2.selectedScaleType == .blues)
        check("persistence menuBarIcon", condition: model2.menuBarIconName == "pianokeys")
        check("persistence noteNaming", condition: model2.noteNaming == .flats)
        check("persistence popoverSize", condition: model2.popoverSize == .spacious)
        check("persistence positionFilter", condition: model2.positionFilter == .fiveTo12)
        check("persistence quizFilter", condition: model2.quizFilter == .openOnly)
        check("persistence mode", condition: model2.selectedMode == .notes)
        check("persistence quizState correct", condition: model2.quizState.correctCount == 3)
        check("persistence quizState total", condition: model2.quizState.totalCount == 4)
        defaults.removePersistentDomain(forName: suiteName)

        print("[SelfTest] \(passed) passed, \(failed) failed")
        exit(failed == 0 ? 0 : 1)
    }
}
