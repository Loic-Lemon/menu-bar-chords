import XCTest
@testable import ChordsLib

final class ChordLibraryTests: XCTestCase {
    func testAllChordsHaveUniqueIds() {
        let ids = ChordLibrary.all.map(\.id)
        let uniqueIds = Set(ids)
        XCTAssertEqual(ids.count, uniqueIds.count, "Duplicate chord IDs found")
    }

    func testAllChordsHaveAtLeastOnePosition() {
        for chord in ChordLibrary.all {
            XCTAssertFalse(chord.positions.isEmpty, "Chord \(chord.id) has no positions")
        }
    }

    func testAllPositionsHaveSixFrets() {
        for chord in ChordLibrary.all {
            for position in chord.positions {
                XCTAssertEqual(
                    position.frets.count, 6,
                    "Chord \(chord.id) position \(position.id) has \(position.frets.count) frets, expected 6"
                )
            }
        }
    }

    func testAllPositionsHaveSixFingers() {
        for chord in ChordLibrary.all {
            for position in chord.positions {
                XCTAssertEqual(
                    position.fingers.count, 6,
                    "Chord \(chord.id) position \(position.id) has \(position.fingers.count) fingers, expected 6"
                )
            }
        }
    }

    func testAllPositionsHaveValidBaseFret() {
        for chord in ChordLibrary.all {
            for position in chord.positions {
                XCTAssertGreaterThanOrEqual(
                    position.baseFret, 1,
                    "Chord \(chord.id) position \(position.id) has baseFret \(position.baseFret)"
                )
            }
        }
    }

    func testAllPositionsHaveValidFretValues() {
        for chord in ChordLibrary.all {
            for position in chord.positions {
                for (index, fret) in position.frets.enumerated() {
                    if let f = fret {
                        XCTAssertGreaterThanOrEqual(
                            f, 0,
                            "Chord \(chord.id) position \(position.id) string \(index) has negative fret \(f)"
                        )
                    }
                }
            }
        }
    }

    func testAllBarresAreWithinPosition() {
        for chord in ChordLibrary.all {
            for position in chord.positions {
                for barre in position.barres {
                    let col = barre.fret - position.baseFret
                    XCTAssertGreaterThanOrEqual(
                        col, 0,
                        "Barre in \(chord.id) position \(position.id) is before baseFret"
                    )
                    XCTAssertLessThan(
                        col, 3,
                        "Barre in \(chord.id) position \(position.id) is beyond 3-fret window"
                    )
                    XCTAssertGreaterThanOrEqual(barre.startString, 0)
                    XCTAssertLessThan(barre.endString, 6)
                    XCTAssertGreaterThanOrEqual(barre.endString, barre.startString)
                }
            }
        }
    }

    func testAllChordsAreFindableById() {
        for chord in ChordLibrary.all {
            let found = ChordLibrary.byId[chord.id]
            XCTAssertNotNil(found, "Chord \(chord.id) not found in byId dictionary")
            XCTAssertEqual(found?.id, chord.id)
        }
    }

    func testChordLookup() {
        let cMajor = ChordLibrary.chord(root: .c, type: .major)
        XCTAssertNotNil(cMajor)
        XCTAssertEqual(cMajor?.root, .c)
        XCTAssertEqual(cMajor?.type, .major)

        let aMinor = ChordLibrary.chord(root: .a, type: .minor)
        XCTAssertNotNil(aMinor)
        XCTAssertEqual(aMinor?.root, .a)
        XCTAssertEqual(aMinor?.type, .minor)
    }

    func testChordNotFound() {
        let nonexistent = ChordLibrary.chord(root: .fSharp, type: .augmented)
        XCTAssertNil(nonexistent, "F# augmented should not exist in library yet")
    }

    func testRandomChordIsValid() {
        for _ in 0..<100 {
            let chord = ChordLibrary.random()
            XCTAssertNotNil(ChordLibrary.byId[chord.id])
        }
    }

    func testChordTypeIntervals() {
        let majorIntervals = ChordType.major.intervals
        XCTAssertEqual(majorIntervals, [0, 4, 7])

        let minorIntervals = ChordType.minor.intervals
        XCTAssertEqual(minorIntervals, [0, 3, 7])

        let dom7Intervals = ChordType.dominant7.intervals
        XCTAssertEqual(dom7Intervals, [0, 4, 7, 10])
    }

    func testChordTypeDisplayNames() {
        XCTAssertEqual(ChordType.major.displayName, "Major")
        XCTAssertEqual(ChordType.minor.displayName, "Minor")
        XCTAssertEqual(ChordType.dominant7.displayName, "7")
        XCTAssertEqual(ChordType.minor7.displayName, "m7")
        XCTAssertEqual(ChordType.diminished.displayName, "dim")
    }

    func testChordTypeSymbols() {
        XCTAssertEqual(ChordType.major.symbol, "")
        XCTAssertEqual(ChordType.minor.symbol, "m")
        XCTAssertEqual(ChordType.dominant7.symbol, "7")
        XCTAssertEqual(ChordType.major7.symbol, "maj7")
    }

    func testChordTypeEnumIsCaseIterable() {
        XCTAssertEqual(ChordType.allCases.count, 9)
    }

    func testChordDefinitionIdIncludesRootAndType() {
        let chord = ChordDefinition(
            id: "C_Major", root: .c, type: .major,
            positions: [ChordPosition(id: "open", frets: [0, 1, 0, 2, 3, nil], fingers: [nil, 1, nil, 2, 3, nil])]
        )
        XCTAssertEqual(chord.id, "C_Major")
        XCTAssertEqual(chord.root, .c)
        XCTAssertEqual(chord.type, .major)
    }
}
