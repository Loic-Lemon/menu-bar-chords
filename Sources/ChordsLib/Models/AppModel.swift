import Foundation
import Observation

public enum AppMode: String, CaseIterable, Codable, Sendable {
    case browse
    case quiz
    case notes

    public var label: String {
        switch self {
        case .browse: "Browse"
        case .quiz: "Quiz"
        case .notes: "Notes"
        }
    }
}

public enum BrowseMode: String, CaseIterable, Codable, Sendable {
    case chord
    case scale

    public var label: String {
        switch self {
        case .chord: "Chord"
        case .scale: "Scale"
        }
    }
}

public enum NotePositionFilter: String, CaseIterable, Codable, Sendable {
    case openTo5
    case fiveTo12
    case any

    public var label: String {
        switch self {
        case .openTo5: "Open–5"
        case .fiveTo12: "5–12"
        case .any: "Any"
        }
    }

    public var range: ClosedRange<Int> {
        switch self {
        case .openTo5: 0...5
        case .fiveTo12: 5...12
        case .any: 0...24
        }
    }
}

@MainActor
@Observable
public final class AppModel {
    public var selectedMode: AppMode = .browse
    public var popoverVisible = false

    public var browseMode: BrowseMode = .chord
    public var selectedRoot: Note = .c
    public var selectedChordType: ChordType = .major
    public var selectedScaleType: ScaleType = .major
    public var selectedChordPositionIndex: Int = 0
    public var selectedScalePositionIndex: Int = 0

    public var quizState = QuizState()
    public var currentQuizChord: ChordDefinition?
    public var userGuessRoot: Note?
    public var userGuessType: ChordType?
    public var isQuizAnswered = false
    public var isQuizCorrect = false

    public var selectedString: GuitarString?
    public var positionFilter: NotePositionFilter = .any
    public var currentNoteTarget: Note?
    public var isNoteRevealed = false
    public var noteTargetFret: Int?

    public init() {
        loadPreferences()
        generateQuizChord()
        generateNoteTarget()
    }

    public var currentChordPosition: ChordPosition? {
        guard let chord = ChordLibrary.chord(root: selectedRoot, type: selectedChordType) else {
            return nil
        }
        guard !chord.positions.isEmpty else { return nil }
        let idx = min(selectedChordPositionIndex, chord.positions.count - 1)
        return chord.positions[idx]
    }

    public var browseChord: ChordDefinition? {
        ChordLibrary.chord(root: selectedRoot, type: selectedChordType)
    }

    public var browseScale: ScaleDefinition? {
        ScaleLibrary.scale(root: selectedRoot, type: selectedScaleType)
    }

    public func generateQuizChord() {
        let chord = ChordLibrary.random()
        currentQuizChord = chord
        userGuessRoot = nil
        userGuessType = nil
        isQuizAnswered = false
        isQuizCorrect = false
    }

    @discardableResult
    public func submitQuizGuess(root: Note, type: ChordType) -> Bool {
        guard let chord = currentQuizChord else { return false }
        let correct = root == chord.root && type == chord.type
        isQuizAnswered = true
        isQuizCorrect = correct
        if correct {
            quizState.recordCorrect()
        } else {
            quizState.recordIncorrect()
        }
        return correct
    }

    public func generateNoteTarget() {
        let targetNote = Note.allCases.randomElement()!
        let strings: [GuitarString] = selectedString.map { [$0] } ?? GuitarString.allCases
        guard let targetString = strings.randomElement() else { return }

        currentNoteTarget = targetNote
        let fret = targetString.fret(for: targetNote, in: positionFilter.range)
        if fret == nil {
            generateNoteTarget()
            return
        }
        noteTargetFret = fret
        isNoteRevealed = false
    }

    public func revealNote() {
        isNoteRevealed = true
    }

    private func loadPreferences() {
        let defaults = UserDefaults.standard
        if let raw = defaults.string(forKey: "selectedMode"),
           let mode = AppMode(rawValue: raw) { selectedMode = mode }
        if let raw = defaults.string(forKey: "selectedRoot"),
           let val = Int(raw),
           let note = Note(rawValue: val) { selectedRoot = note }
        if let raw = defaults.string(forKey: "selectedChordType"),
           let type = ChordType(rawValue: raw) { selectedChordType = type }
        if let raw = defaults.string(forKey: "selectedScaleType"),
           let type = ScaleType(rawValue: raw) { selectedScaleType = type }
        if let raw = defaults.string(forKey: "positionFilter"),
           let filter = NotePositionFilter(rawValue: raw) { positionFilter = filter }

        if let data = defaults.data(forKey: "quizState"),
           let state = try? JSONDecoder().decode(QuizState.self, from: data) {
            quizState = state
        }
    }

    public func didChangeMode() { savePreferences() }
    public func didChangeRoot() { savePreferences() }
    public func didChangeChordType() { savePreferences() }
    public func didChangeScaleType() { savePreferences() }
    public func didChangeBrowseMode() { savePreferences() }
    public func didChangePositionFilter() { savePreferences() }

    public func didChangeSelectedString() {
        generateNoteTarget()
    }

    private func savePreferences() {
        let defaults = UserDefaults.standard
        defaults.set(selectedMode.rawValue, forKey: "selectedMode")
        defaults.set("\(selectedRoot.rawValue)", forKey: "selectedRoot")
        defaults.set(selectedChordType.rawValue, forKey: "selectedChordType")
        defaults.set(selectedScaleType.rawValue, forKey: "selectedScaleType")
        defaults.set(positionFilter.rawValue, forKey: "positionFilter")

        if let data = try? JSONEncoder().encode(quizState) {
            defaults.set(data, forKey: "quizState")
        }
    }
}
