import Foundation

public enum ScaleLibrary {
    public static let all: [ScaleDefinition] = {
        ScaleType.allCases.flatMap { type in
            Note.allCases.map { root in
                ScaleDefinition(
                    id: "\(root.name)_\(type.rawValue)",
                    root: root,
                    type: type,
                    positions: positionsForScale(root: root, type: type)
                )
            }
        }
    }()

    public static func scale(root: Note, type: ScaleType) -> ScaleDefinition? {
        all.first { $0.root == root && $0.type == type }
    }

    public static func random() -> ScaleDefinition {
        all.randomElement()!
    }

    private static func positionsForScale(root: Note, type: ScaleType) -> [ScalePosition] {
        let intervals = type.intervals
        let scaleNotes = intervals.map { root + $0 }

        return [
            ScalePosition(
                id: "position_1",
                baseFret: 1,
                notes: buildWindow(scaleNotes: scaleNotes, startFret: 1, numFrets: 3)
            )
        ]
    }

    private static func buildWindow(scaleNotes: [Note], startFret: Int, numFrets: Int) -> [[ScaleNote?]] {
        var result: [[ScaleNote?]] = []

        for string in GuitarString.allCases {
            let openNote = string.openNote
            var stringResult: [ScaleNote?] = []

            for col in 0..<numFrets {
                let absoluteFret = startFret + col
                let noteAtFret = Note(rawValue: (openNote.rawValue + absoluteFret) % 12)!

                if let scaleIndex = scaleNotes.firstIndex(of: noteAtFret) {
                    stringResult.append(ScaleNote(note: noteAtFret, interval: scaleIndex, finger: nil))
                } else {
                    stringResult.append(nil)
                }
            }

            result.append(stringResult)
        }

        return result
    }
}
