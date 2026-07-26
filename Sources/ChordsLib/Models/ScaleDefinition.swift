import Foundation

public struct ScaleDefinition: Identifiable, Sendable, Hashable {
    public let id: String
    public let root: Note
    public let type: ScaleType
    public let positions: [ScalePosition]

    public init(id: String, root: Note, type: ScaleType, positions: [ScalePosition]) {
        self.id = id
        self.root = root
        self.type = type
        self.positions = positions
    }

    public static func == (lhs: ScaleDefinition, rhs: ScaleDefinition) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public enum ScaleType: String, CaseIterable, Codable, Sendable {
    case major
    case naturalMinor
    case majorPentatonic
    case minorPentatonic
    case blues

    public var displayName: String {
        switch self {
        case .major: "Major"
        case .naturalMinor: "Minor"
        case .majorPentatonic: "Maj Pentatonic"
        case .minorPentatonic: "Min Pentatonic"
        case .blues: "Blues"
        }
    }

    public var intervals: [Int] {
        switch self {
        case .major: [0, 2, 4, 5, 7, 9, 11]
        case .naturalMinor: [0, 2, 3, 5, 7, 8, 10]
        case .majorPentatonic: [0, 2, 4, 7, 9]
        case .minorPentatonic: [0, 3, 5, 7, 10]
        case .blues: [0, 3, 5, 6, 7, 10]
        }
    }
}

public struct ScalePosition: Identifiable, Sendable {
    public let id: String
    public let baseFret: Int
    public let notes: [[ScaleNote?]]

    public init(id: String, baseFret: Int, notes: [[ScaleNote?]]) {
        self.id = id
        self.baseFret = baseFret
        self.notes = notes
    }
}

public struct ScaleNote: Sendable {
    public let note: Note
    public let interval: Int
    public let finger: Int?

    public init(note: Note, interval: Int, finger: Int?) {
        self.note = note
        self.interval = interval
        self.finger = finger
    }
}
