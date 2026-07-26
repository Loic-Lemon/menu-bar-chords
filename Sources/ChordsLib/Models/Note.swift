import Foundation

public enum Note: Int, CaseIterable, Codable, Sendable {
    case c = 0
    case cSharp
    case d
    case dSharp
    case e
    case f
    case fSharp
    case g
    case gSharp
    case a
    case aSharp
    case b

    public var name: String {
        switch self {
        case .c: "C"
        case .cSharp: "C#"
        case .d: "D"
        case .dSharp: "D#"
        case .e: "E"
        case .f: "F"
        case .fSharp: "F#"
        case .g: "G"
        case .gSharp: "G#"
        case .a: "A"
        case .aSharp: "A#"
        case .b: "B"
        }
    }

    public var flatName: String {
        switch self {
        case .c: "C"
        case .cSharp: "D♭"
        case .d: "D"
        case .dSharp: "E♭"
        case .e: "E"
        case .f: "F"
        case .fSharp: "G♭"
        case .g: "G"
        case .gSharp: "A♭"
        case .a: "A"
        case .aSharp: "B♭"
        case .b: "B"
        }
    }

    public static func + (lhs: Note, rhs: Int) -> Note {
        Note(rawValue: (lhs.rawValue + rhs) % 12)!
    }

    public func interval(to note: Note) -> Int {
        (note.rawValue - rawValue + 12) % 12
    }
}

public enum GuitarString: Int, CaseIterable, Codable, Sendable {
    case highE = 0
    case b
    case g
    case d
    case a
    case lowE

    public var openNote: Note {
        switch self {
        case .highE: .e
        case .b: .b
        case .g: .g
        case .d: .d
        case .a: .a
        case .lowE: .e
        }
    }

    public var displayName: String {
        switch self {
        case .highE: "e"
        case .b: "B"
        case .g: "G"
        case .d: "D"
        case .a: "A"
        case .lowE: "E"
        }
    }

    public func fret(for targetNote: Note) -> Int {
        (targetNote.rawValue - openNote.rawValue + 12) % 12
    }

    public func fret(for targetNote: Note, in range: ClosedRange<Int>) -> Int? {
        let halfSteps = (targetNote.rawValue - openNote.rawValue + 12) % 12
        for octave in 0...2 {
            let fret = halfSteps + octave * 12
            if range.contains(fret) {
                return fret
            }
        }
        return nil
    }
}
