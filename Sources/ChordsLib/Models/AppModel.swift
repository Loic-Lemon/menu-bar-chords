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

public enum ChordQuizFilter: String, CaseIterable, Codable, Sendable {
    case all
    case openOnly

    public var label: String {
        switch self {
        case .all: "All"
        case .openOnly: "Open"
        }
    }
}

public enum NoteNamingScheme: String, CaseIterable, Codable, Sendable {
    case sharps
    case flats

    public var label: String {
        switch self {
        case .sharps: "Sharps (C#)"
        case .flats: "Flats (D♭)"
        }
    }
}

public enum PopoverSize: String, CaseIterable, Codable, Sendable {
    case compact
    case spacious

    public var label: String {
        switch self {
        case .compact: "Compact"
        case .spacious: "Spacious"
        }
    }

    public var width: CGFloat {
        switch self {
        case .compact: 320
        case .spacious: 380
        }
    }
}

public enum GuitarSound: String, CaseIterable, Codable, Sendable {
    case acousticNylon
    case acousticSteel
    case electricClean
    case overdriven
    case distortion

    public var label: String {
        switch self {
        case .acousticNylon: "Acoustic (Nylon)"
        case .acousticSteel: "Acoustic (Steel)"
        case .electricClean: "Electric (Clean)"
        case .overdriven: "Overdriven"
        case .distortion: "Distortion"
        }
    }

    public var midiProgram: UInt8 {
        switch self {
        case .acousticNylon: 24
        case .acousticSteel: 25
        case .electricClean: 27
        case .overdriven: 29
        case .distortion: 30
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
    public var isQuizRootCorrect = false
    public var isQuizTypeCorrect = false
    public var quizFilter: ChordQuizFilter = .all

    public var currentSession: QuizSession?
    public var sessions: [QuizSession] = []

    public var showSettings = false
    public var showHistory = false

    public var selectedString: GuitarString?
    public var positionFilter: NotePositionFilter = .any
    public var currentNoteTarget: Note?
    public var isNoteRevealed = false
    public var isNoteAnswered = false
    public var isNoteAnswerCorrect = false
    public var noteTargetFret: Int?

    public var currentNoteSession: NoteSession?
    public var noteSessions: [NoteSession] = []

    public var menuBarIconName = "guitars"
    public var noteNaming: NoteNamingScheme = .sharps
    public var popoverSize: PopoverSize = .compact
    public var guitarSound: GuitarSound = .acousticSteel

    @ObservationIgnored
    public var onMenuBarIconChange: (@MainActor () -> Void)?

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        loadPreferences()
        generateQuizChord()
        generateNoteTarget()
        
        let sound = guitarSound
        Task {
            await AudioEngine.shared.updateSound(sound)
        }
    }

    @ObservationIgnored
    private let defaults: UserDefaults

    public func noteName(_ note: Note) -> String {
        noteNaming == .sharps ? note.name : note.flatName
    }

    public var currentChordPosition: ChordPosition? {
        guard let chord = ChordLibrary.chord(root: selectedRoot, type: selectedChordType) else {
            return nil
        }
        guard !chord.positions.isEmpty else { return nil }
        let idx = min(selectedChordPositionIndex, chord.positions.count - 1)
        return chord.positions[idx]
    }

    public func playCurrentChord() {
        guard let position = currentChordPosition else { return }
        let sound = guitarSound
        Task {
            await AudioEngine.shared.play(frets: position.frets, sound: sound)
        }
    }

    public var browseChord: ChordDefinition? {
        ChordLibrary.chord(root: selectedRoot, type: selectedChordType)
    }

    public var browseScale: ScaleDefinition? {
        ScaleLibrary.scale(root: selectedRoot, type: selectedScaleType)
    }

    public func generateQuizChord() {
        let pool: [ChordDefinition]
        switch quizFilter {
        case .all:
            pool = ChordLibrary.all
        case .openOnly:
            pool = ChordLibrary.all.filter { $0.positions.contains { $0.id == "open" } }
        }
        currentQuizChord = pool.randomElement() ?? ChordLibrary.random()
        userGuessRoot = nil
        userGuessType = nil
        isQuizAnswered = false
        isQuizCorrect = false
        isQuizRootCorrect = false
        isQuizTypeCorrect = false
    }

    @discardableResult
    public func submitQuizGuess(root: Note, type: ChordType) -> Bool {
        guard let chord = currentQuizChord else { return false }
        let rootCorrect = root == chord.root
        let typeCorrect = type == chord.type
        let combined = rootCorrect && typeCorrect

        isQuizAnswered = true
        isQuizCorrect = combined
        isQuizRootCorrect = rootCorrect
        isQuizTypeCorrect = typeCorrect

        quizState.record(rootCorrect: rootCorrect, typeCorrect: typeCorrect)

        if var session = currentSession {
            session.record(rootCorrect: rootCorrect, typeCorrect: typeCorrect)
            currentSession = session
        }

        savePreferences()
        return combined
    }

    public func startSession() {
        if var active = currentSession, active.combinedTotalCount > 0 {
            active.endSession()
            sessions.append(active)
        }
        currentSession = QuizSession()
        quizState.reset()
        savePreferences()
    }

    public func endSession() {
        guard var session = currentSession else { return }
        session.endSession()
        if session.combinedTotalCount > 0 {
            sessions.append(session)
        }
        currentSession = nil
        savePreferences()
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
        isNoteAnswered = false
        isNoteAnswerCorrect = false
    }

    public func revealNote() {
        isNoteRevealed = true
    }

    public func recordNoteAnswer(correct: Bool) {
        isNoteAnswered = true
        isNoteAnswerCorrect = correct
        if var session = currentNoteSession {
            session.recordAnswer(correct: correct)
            currentNoteSession = session
        }
    }

    public func startNoteSession() {
        if var active = currentNoteSession, active.totalNotes > 0 {
            active.endSession()
            noteSessions.append(active)
        }
        currentNoteSession = NoteSession()
        savePreferences()
    }

    public func endNoteSession() {
        guard var session = currentNoteSession else { return }
        session.endSession()
        if session.totalNotes > 0 {
            noteSessions.append(session)
        }
        currentNoteSession = nil
        savePreferences()
    }

    public func deleteNoteSession(id: UUID) {
        noteSessions.removeAll { $0.id == id }
        savePreferences()
    }

    public func deleteQuizSession(id: UUID) {
        sessions.removeAll { $0.id == id }
        savePreferences()
    }

    private func loadPreferences() {
        let defaults = self.defaults
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
        if let raw = defaults.string(forKey: "quizFilter"),
           let filter = ChordQuizFilter(rawValue: raw) { quizFilter = filter }
        if let raw = defaults.string(forKey: "menuBarIcon") { menuBarIconName = raw }
        if let raw = defaults.string(forKey: "noteNaming"),
           let scheme = NoteNamingScheme(rawValue: raw) { noteNaming = scheme }
        if let raw = defaults.string(forKey: "popoverSize"),
           let size = PopoverSize(rawValue: raw) { popoverSize = size }
        if let raw = defaults.string(forKey: "guitarSound"),
           let sound = GuitarSound(rawValue: raw) { guitarSound = sound }

        if let data = defaults.data(forKey: "quizState"),
           let state = try? JSONDecoder().decode(QuizState.self, from: data) {
            quizState = state
        }

        if let data = defaults.data(forKey: "currentSession"),
           let session = try? JSONDecoder().decode(QuizSession.self, from: data) {
            currentSession = session
        }

        if let data = defaults.data(forKey: "quizSessions"),
           let history = try? JSONDecoder().decode([QuizSession].self, from: data) {
            sessions = history
        }

        if let data = defaults.data(forKey: "currentNoteSession"),
           let session = try? JSONDecoder().decode(NoteSession.self, from: data) {
            currentNoteSession = session
        }

        if let data = defaults.data(forKey: "noteSessions"),
           let history = try? JSONDecoder().decode([NoteSession].self, from: data) {
            noteSessions = history
        }
    }

    public func didChangeMode() { savePreferences() }
    public func didChangeRoot() { savePreferences() }
    public func didChangeChordType() { savePreferences() }
    public func didChangeScaleType() { savePreferences() }
    public func didChangeBrowseMode() { savePreferences() }
    public func didChangePositionFilter() { savePreferences() }
    public func didChangeQuizFilter() { savePreferences() }
    public func didChangeMenuBarIcon() {
        savePreferences()
        onMenuBarIconChange?()
    }
    public func didChangeNoteNaming() { savePreferences() }
    public func didChangePopoverSize() { savePreferences() }
    public func didChangeGuitarSound() {
        savePreferences()
        let sound = guitarSound
        Task {
            await AudioEngine.shared.updateSound(sound)
        }
    }

    public func didChangeSelectedString() {
        generateNoteTarget()
    }

    private func savePreferences() {
        let defaults = self.defaults
        defaults.set(selectedMode.rawValue, forKey: "selectedMode")
        defaults.set("\(selectedRoot.rawValue)", forKey: "selectedRoot")
        defaults.set(selectedChordType.rawValue, forKey: "selectedChordType")
        defaults.set(selectedScaleType.rawValue, forKey: "selectedScaleType")
        defaults.set(positionFilter.rawValue, forKey: "positionFilter")
        defaults.set(quizFilter.rawValue, forKey: "quizFilter")
        defaults.set(menuBarIconName, forKey: "menuBarIcon")
        defaults.set(noteNaming.rawValue, forKey: "noteNaming")
        defaults.set(popoverSize.rawValue, forKey: "popoverSize")
        defaults.set(guitarSound.rawValue, forKey: "guitarSound")

        if let data = try? JSONEncoder().encode(quizState) {
            defaults.set(data, forKey: "quizState")
        }

        if let data = try? JSONEncoder().encode(currentSession) {
            defaults.set(data, forKey: "currentSession")
        } else {
            defaults.removeObject(forKey: "currentSession")
        }

        if let data = try? JSONEncoder().encode(sessions) {
            defaults.set(data, forKey: "quizSessions")
        }

        if let data = try? JSONEncoder().encode(currentNoteSession) {
            defaults.set(data, forKey: "currentNoteSession")
        } else {
            defaults.removeObject(forKey: "currentNoteSession")
        }

        if let data = try? JSONEncoder().encode(noteSessions) {
            defaults.set(data, forKey: "noteSessions")
        }
    }
}
