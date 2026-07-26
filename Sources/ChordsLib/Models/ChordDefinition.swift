import Foundation

public struct ChordDefinition: Identifiable, Sendable, Hashable {
    public let id: String
    public let root: Note
    public let type: ChordType
    public let positions: [ChordPosition]

    public init(id: String, root: Note, type: ChordType, positions: [ChordPosition]) {
        self.id = id
        self.root = root
        self.type = type
        self.positions = positions
    }

    public static func == (lhs: ChordDefinition, rhs: ChordDefinition) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public enum ChordType: String, CaseIterable, Codable, Sendable {
    case major
    case minor
    case dominant7
    case minor7
    case major7
    case diminished
    case augmented
    case sus2
    case sus4

    public var displayName: String {
        switch self {
        case .major: "Major"
        case .minor: "Minor"
        case .dominant7: "7"
        case .minor7: "m7"
        case .major7: "Maj7"
        case .diminished: "dim"
        case .augmented: "aug"
        case .sus2: "sus2"
        case .sus4: "sus4"
        }
    }

    public var symbol: String {
        switch self {
        case .major: ""
        case .minor: "m"
        case .dominant7: "7"
        case .minor7: "m7"
        case .major7: "maj7"
        case .diminished: "dim"
        case .augmented: "aug"
        case .sus2: "sus2"
        case .sus4: "sus4"
        }
    }

    public var intervals: [Int] {
        switch self {
        case .major: [0, 4, 7]
        case .minor: [0, 3, 7]
        case .dominant7: [0, 4, 7, 10]
        case .minor7: [0, 3, 7, 10]
        case .major7: [0, 4, 7, 11]
        case .diminished: [0, 3, 6]
        case .augmented: [0, 4, 8]
        case .sus2: [0, 2, 7]
        case .sus4: [0, 5, 7]
        }
    }
}

public struct ChordPosition: Identifiable, Sendable {
    public let id: String
    public let frets: [Int?]
    public let fingers: [Int?]
    public let barres: [Barre]
    public let baseFret: Int

    public init(id: String, frets: [Int?], fingers: [Int?], barres: [Barre] = [], baseFret: Int = 1) {
        self.id = id
        self.frets = frets
        self.fingers = fingers
        self.barres = barres
        self.baseFret = baseFret
    }
}

public struct Barre: Sendable {
    public let fret: Int
    public let startString: Int
    public let endString: Int

    public init(fret: Int, startString: Int, endString: Int) {
        self.fret = fret
        self.startString = startString
        self.endString = endString
    }
}
