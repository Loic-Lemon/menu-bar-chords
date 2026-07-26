import XCTest
@testable import ChordsLib

final class NoteTests: XCTestCase {
    func testNoteNames() {
        XCTAssertEqual(Note.c.name, "C")
        XCTAssertEqual(Note.cSharp.name, "C#")
        XCTAssertEqual(Note.a.name, "A")
        XCTAssertEqual(Note.aSharp.name, "A#")
        XCTAssertEqual(Note.b.name, "B")
    }

    func testNoteFlatNames() {
        XCTAssertEqual(Note.c.flatName, "C")
        XCTAssertEqual(Note.cSharp.flatName, "D♭")
        XCTAssertEqual(Note.dSharp.flatName, "E♭")
        XCTAssertEqual(Note.gSharp.flatName, "A♭")
    }

    func testNoteRawValues() {
        XCTAssertEqual(Note.c.rawValue, 0)
        XCTAssertEqual(Note.e.rawValue, 4)
        XCTAssertEqual(Note.g.rawValue, 7)
        XCTAssertEqual(Note.b.rawValue, 11)
    }

    func testNoteAddition() {
        XCTAssertEqual(Note.c + 0, .c)
        XCTAssertEqual(Note.c + 4, .e)
        XCTAssertEqual(Note.c + 7, .g)
        XCTAssertEqual(Note.c + 12, .c)
        XCTAssertEqual(Note.a + 2, .b)
        XCTAssertEqual(Note.b + 1, .c)
    }

    func testInterval() {
        XCTAssertEqual(Note.c.interval(to: .e), 4)
        XCTAssertEqual(Note.c.interval(to: .g), 7)
        XCTAssertEqual(Note.c.interval(to: .c), 0)
        XCTAssertEqual(Note.e.interval(to: .a), 5)
    }

    func testAllCasesCount() {
        XCTAssertEqual(Note.allCases.count, 12)
    }

    func testGuitarStringOpenNotes() {
        XCTAssertEqual(GuitarString.highE.openNote, .e)
        XCTAssertEqual(GuitarString.b.openNote, .b)
        XCTAssertEqual(GuitarString.g.openNote, .g)
        XCTAssertEqual(GuitarString.d.openNote, .d)
        XCTAssertEqual(GuitarString.a.openNote, .a)
        XCTAssertEqual(GuitarString.lowE.openNote, .e)
    }

    func testGuitarStringDisplayNames() {
        XCTAssertEqual(GuitarString.highE.displayName, "e")
        XCTAssertEqual(GuitarString.lowE.displayName, "E")
        XCTAssertEqual(GuitarString.a.displayName, "A")
    }

    func testFretCalculation() {
        let highE = GuitarString.highE
        XCTAssertEqual(highE.fret(for: .e), 0)
        XCTAssertEqual(highE.fret(for: .f), 1)
        XCTAssertEqual(highE.fret(for: .fSharp), 2)
        XCTAssertEqual(highE.fret(for: .g), 3)

        let aString = GuitarString.a
        XCTAssertEqual(aString.fret(for: .a), 0)
        XCTAssertEqual(aString.fret(for: .aSharp), 1)
        XCTAssertEqual(aString.fret(for: .b), 2)
        XCTAssertEqual(aString.fret(for: .c), 3)
        XCTAssertEqual(aString.fret(for: .cSharp), 4)
        XCTAssertEqual(aString.fret(for: .d), 5)
    }

    func testFretCalculationWithRange() {
        let aString = GuitarString.a
        XCTAssertEqual(aString.fret(for: .c, in: 0...5), 3)
        XCTAssertEqual(aString.fret(for: .c, in: 0...4), nil)
        XCTAssertEqual(aString.fret(for: .a, in: 0...2), 0)
        XCTAssertEqual(aString.fret(for: .a, in: 5...12), 12)
    }

    func testFretWrapsAtOctave() {
        let aString = GuitarString.a
        XCTAssertEqual(aString.fret(for: .a), 0)
        XCTAssertEqual(aString.fret(for: .a, in: 0...24), 0)
    }

    func testGuitarStringAllCases() {
        XCTAssertEqual(GuitarString.allCases.count, 6)
    }

    func testNoteEnumIsCodable() {
        let data = try! JSONEncoder().encode(Note.cSharp)
        let decoded = try! JSONDecoder().decode(Note.self, from: data)
        XCTAssertEqual(decoded, .cSharp)
    }

    func testGuitarStringEnumIsCodable() {
        let data = try! JSONEncoder().encode(GuitarString.lowE)
        let decoded = try! JSONDecoder().decode(GuitarString.self, from: data)
        XCTAssertEqual(decoded, .lowE)
    }
}
