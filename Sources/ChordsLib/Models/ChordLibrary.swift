import Foundation

public enum ChordLibrary {
    public static let all: [ChordDefinition] = {
        openChords + barreChords
    }()

    public static let byId: [String: ChordDefinition] = {
        Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })
    }()

    public static func chord(root: Note, type: ChordType) -> ChordDefinition? {
        all.first { $0.root == root && $0.type == type }
    }

    public static func random() -> ChordDefinition {
        all.randomElement()!
    }

    private static let openChords: [ChordDefinition] = [
        ChordDefinition(id: "C_Major", root: .c, type: .major, positions: [ChordPosition(id: "open", frets: [0, 1, 0, 2, 3, nil], fingers: [nil, 1, nil, 2, 3, nil], baseFret: 1)]),
        ChordDefinition(id: "A_Major", root: .a, type: .major, positions: [ChordPosition(id: "open", frets: [0, 2, 2, 2, 0, nil], fingers: [nil, 3, 2, 1, nil, nil], baseFret: 1)]),
        ChordDefinition(id: "G_Major", root: .g, type: .major, positions: [ChordPosition(id: "open", frets: [3, 0, 0, 0, 2, 3], fingers: [3, nil, nil, nil, 1, 2], baseFret: 1)]),
        ChordDefinition(id: "E_Major", root: .e, type: .major, positions: [ChordPosition(id: "open", frets: [0, 0, 1, 2, 2, 0], fingers: [nil, nil, 1, 3, 2, nil], baseFret: 1)]),
        ChordDefinition(id: "D_Major", root: .d, type: .major, positions: [ChordPosition(id: "open", frets: [2, 3, 2, 0, nil, nil], fingers: [2, 3, 1, nil, nil, nil], baseFret: 1)]),
        ChordDefinition(id: "A_Minor", root: .a, type: .minor, positions: [ChordPosition(id: "open", frets: [0, 1, 2, 2, 0, nil], fingers: [nil, 1, 3, 2, nil, nil], baseFret: 1)]),
        ChordDefinition(id: "E_Minor", root: .e, type: .minor, positions: [ChordPosition(id: "open", frets: [0, 0, 0, 2, 2, 0], fingers: [nil, nil, nil, 2, 1, nil], baseFret: 1)]),
        ChordDefinition(id: "D_Minor", root: .d, type: .minor, positions: [ChordPosition(id: "open", frets: [1, 3, 2, 0, nil, nil], fingers: [1, 3, 2, nil, nil, nil], baseFret: 1)]),
        ChordDefinition(id: "A7", root: .a, type: .dominant7, positions: [ChordPosition(id: "open", frets: [0, 2, 0, 2, 0, nil], fingers: [nil, 3, nil, 2, nil, nil], baseFret: 1)]),
        ChordDefinition(id: "B7", root: .b, type: .dominant7, positions: [ChordPosition(id: "open", frets: [2, 0, 2, 1, 2, nil], fingers: [4, nil, 3, 1, 2, nil], baseFret: 1)]),
        ChordDefinition(id: "C7", root: .c, type: .dominant7, positions: [ChordPosition(id: "open", frets: [0, 1, 3, 2, 3, nil], fingers: [nil, 1, 4, 2, 3, nil], baseFret: 1)]),
        ChordDefinition(id: "D7", root: .d, type: .dominant7, positions: [ChordPosition(id: "open", frets: [2, 1, 2, 0, nil, nil], fingers: [2, 1, 3, nil, nil, nil], baseFret: 1)]),
        ChordDefinition(id: "E7", root: .e, type: .dominant7, positions: [ChordPosition(id: "open", frets: [0, 0, 1, 0, 2, 0], fingers: [nil, nil, 2, nil, 1, nil], baseFret: 1)]),
        ChordDefinition(id: "G7", root: .g, type: .dominant7, positions: [ChordPosition(id: "open", frets: [1, 0, 0, 0, 2, 3], fingers: [1, nil, nil, nil, 2, 3], baseFret: 1)]),
        ChordDefinition(id: "Am7", root: .a, type: .minor7, positions: [ChordPosition(id: "open", frets: [0, 1, 0, 2, 0, nil], fingers: [nil, 1, nil, 2, nil, nil], baseFret: 1)]),
        ChordDefinition(id: "Dm7", root: .d, type: .minor7, positions: [ChordPosition(id: "open", frets: [1, 1, 2, 0, nil, nil], fingers: [1, 1, 2, nil, nil, nil], barres: [Barre(fret: 1, startString: 0, endString: 1)], baseFret: 1)]),
        ChordDefinition(id: "Em7", root: .e, type: .minor7, positions: [ChordPosition(id: "open", frets: [0, 0, 0, 0, 2, 0], fingers: [nil, nil, nil, nil, 1, nil], baseFret: 1)]),
        ChordDefinition(id: "Amaj7", root: .a, type: .major7, positions: [ChordPosition(id: "open", frets: [0, 2, 1, 2, 0, nil], fingers: [nil, 3, 1, 2, nil, nil], baseFret: 1)]),
        ChordDefinition(id: "Cmaj7", root: .c, type: .major7, positions: [ChordPosition(id: "open", frets: [0, 0, 0, 2, 3, nil], fingers: [nil, nil, nil, 2, 3, nil], baseFret: 1)]),
        ChordDefinition(id: "Dmaj7", root: .d, type: .major7, positions: [ChordPosition(id: "open", frets: [2, 2, 2, 0, nil, nil], fingers: [1, 1, 1, nil, nil, nil], barres: [Barre(fret: 2, startString: 0, endString: 2)], baseFret: 1)]),
        ChordDefinition(id: "Fmaj7", root: .f, type: .major7, positions: [ChordPosition(id: "open", frets: [0, 1, 2, 3, nil, nil], fingers: [nil, 1, 2, 3, nil, nil], baseFret: 1)]),
        ChordDefinition(id: "D_Sus2", root: .d, type: .sus2, positions: [ChordPosition(id: "open", frets: [0, 3, 2, 0, nil, nil], fingers: [nil, 3, 1, nil, nil, nil], baseFret: 1)]),
        ChordDefinition(id: "A_Sus2", root: .a, type: .sus2, positions: [ChordPosition(id: "open", frets: [0, 0, 2, 2, 0, nil], fingers: [nil, nil, 3, 2, nil, nil], baseFret: 1)]),
        ChordDefinition(id: "A_Sus4", root: .a, type: .sus4, positions: [ChordPosition(id: "open", frets: [0, 3, 2, 2, 0, nil], fingers: [nil, 3, 2, 1, nil, nil], baseFret: 1)]),
        ChordDefinition(id: "D_Sus4", root: .d, type: .sus4, positions: [ChordPosition(id: "open", frets: [3, 3, 2, 0, nil, nil], fingers: [2, 3, 1, nil, nil, nil], baseFret: 1)]),
        ChordDefinition(id: "G_Sus4", root: .g, type: .sus4, positions: [ChordPosition(id: "open", frets: [3, 1, 0, 0, 3, 3], fingers: [4, 1, nil, nil, 3, 2], baseFret: 1)]),
    ]

    private static let barreChords: [ChordDefinition] = {
        var chords: [ChordDefinition] = []

        let majorRoots: [Int: Note] = [1: .f, 3: .g, 5: .a, 7: .b, 8: .c]
        let minorRoots: [Int: Note] = [1: .f, 3: .g, 5: .a, 7: .b]
        let aMajorRoots: [Int: Note] = [1: .aSharp, 3: .c, 5: .d, 7: .e]
        let aMinorRoots: [Int: Note] = [1: .aSharp, 3: .c, 5: .d, 7: .e]

        for (fret, root) in majorRoots {
            chords.append(ChordDefinition(
                id: "\(root.name)_Major_E_shape_\(fret)", root: root, type: .major,
                positions: [ChordPosition(id: "e_shape_\(fret)", frets: [fret, fret, fret + 1, fret + 2, fret + 2, fret], fingers: [1, 1, 2, 3, 4, 1], barres: [Barre(fret: fret, startString: 0, endString: 5)], baseFret: fret)]
            ))
        }
        for (fret, root) in minorRoots {
            chords.append(ChordDefinition(
                id: "\(root.name)_Minor_E_shape_\(fret)", root: root, type: .minor,
                positions: [ChordPosition(id: "e_shape_\(fret)", frets: [fret, fret, fret, fret + 2, fret + 2, fret], fingers: [1, 1, 1, 3, 4, 1], barres: [Barre(fret: fret, startString: 0, endString: 5)], baseFret: fret)]
            ))
        }
        for (fret, root) in aMajorRoots {
            chords.append(ChordDefinition(
                id: "\(root.name)_Major_A_shape_\(fret)", root: root, type: .major,
                positions: [ChordPosition(id: "a_shape_\(fret)", frets: [fret, fret + 2, fret + 2, fret + 2, fret, nil], fingers: [1, 4, 3, 2, 1, nil], barres: [Barre(fret: fret, startString: 0, endString: 4)], baseFret: fret)]
            ))
        }
        for (fret, root) in aMinorRoots {
            chords.append(ChordDefinition(
                id: "\(root.name)_Minor_A_shape_\(fret)", root: root, type: .minor,
                positions: [ChordPosition(id: "a_shape_\(fret)", frets: [fret, fret + 1, fret + 2, fret + 2, fret, nil], fingers: [1, 2, 4, 3, 1, nil], barres: [Barre(fret: fret, startString: 0, endString: 4)], baseFret: fret)]
            ))
        }
        return chords
    }()
}
