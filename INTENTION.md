# Menu Bar Chords — Intention Document

A lightweight, native macOS menu bar app for guitarists to browse chords & scales, practice chord identification, and train note recognition on the fretboard. Zero dependencies. Built with SwiftUI.

---

## Modes

### 1. Browse Mode
The default/reference mode. User selects a chord or scale from a picker and sees it rendered on a mini fretboard.

- Select chord by root note + chord type (Maj, min, 7, m7, Maj7, dim, aug, sus2, sus4, etc.)
- Select scale by root note + scale type (Major, Minor, Pentatonic Major, Pentatonic Minor, Blues, etc.)
- Fretboard shows finger positions (dots with numbers for fingering)
- Muted strings shown with an "X", open strings shown with an "O"
- Chord name displayed above the fretboard

### 2. Chord Identification Quiz
Quiz mode to practice recognizing chord shapes.

- Displays a random chord shape on the mini fretboard (no name shown)
- User types or selects the chord name (root + type)
- "Submit" button to check answer
- Feedback: correct (green) / incorrect (red) with the correct answer shown
- "Next" button to get a new random chord
- Score tracking: correct / total attempts, streak counter

### 3. Note Recognition Mode
Train finding notes on the fretboard.

- User selects a target string (1–6), or chooses "Random"
- App displays a random note name (e.g., "Find: E")
- User tries to play it on their guitar
- "Reveal" button shows the answer on a mini fretboard:
  - The mini fretboard shows the selected string, and highlights the correct fret(s) for that note
  - Shows fret numbers on the first displayed fret for orientation
- "Next Note" to get a new random note
- Option to filter by a position range (e.g., "open to 5th fret", "5th to 12th fret", "any")

---

## Mini Fretboard Component

The core visual component, used in all modes. Inspired by standard guitar chord diagram notation.

**Layout:**
- 6 horizontal lines (strings), thickest at the bottom (low E) → thinnest at the top (high e)
- 3 frets wide (columns) — a sliding window onto the neck
- The **first column always has a fret number** (e.g., "5" for 5th position) to orient the player
- Vertical lines for frets

**Annotations:**
- **Finger positions**: filled circles with a number (1-4 for fingers)
- **Open strings**: "O" above the string
- **Muted strings**: "X" above the string
- **Root note highlight**: different color or outline
- **Barre chords**: horizontal bar arc spanning multiple strings at the same fret

**Sizing:** Compact enough to fit in a menu bar popover (~300pt wide), but readable.

---

## Data Model

### Notes
- 12 chromatic notes: A, A#/Bb, B, C, C#/Db, D, D#/Eb, E, F, F#/Gb, G, G#/Ab
- Each note has a numerical value (0–11) for interval math
- Standard guitar tuning: E2 A2 D3 G3 B3 E4 (in MIDI: 40, 45, 50, 55, 59, 64)

### Chord Definition
```swift
struct ChordDefinition {
    let name: String           // "Major", "Minor", "7", etc.
    let suffix: String         // "", "m", "7", "m7", "Maj7", "dim", "aug", etc.
    let intervals: [Int]       // Semitone offsets from root (0 = root)
    let positions: [ChordPosition] // Multiple voicings/shapes
}

struct ChordPosition {
    let frets: [Int?]          // 6 values (one per string): fret number, nil = muted, 0 = open
    let fingers: [Int?]        // 6 values: finger number for each string, nil = not played
    let barres: [Barre]        // Barre chords spanning multiple strings
    let baseFret: Int          // The fret number shown on the first column of the diagram
}
```

### Scale Definition
```swift
struct ScaleDefinition {
    let name: String           // "Major", "Minor", etc.
    let intervals: [Int]       // Semitone offsets from root
    let positions: [ScalePosition] // Different box shapes / positions
}

struct ScalePosition {
    let frets: [[Int?]]        // 6 strings × N frets: fret numbers for each string at each position
    let baseFret: Int
}
```

### Preloaded Chord Library (Open/Voicings)
Initial set of common open and barre chord shapes:
- **Major**: C, A, G, E, D (open) + E-shape barre, A-shape barre
- **Minor**: Am, Em, Dm (open) + Em-shape barre, Am-shape barre
- **7**: A7, B7, C7, D7, E7, G7 (open) + E7-shape barre, A7-shape barre
- **Minor 7**: Am7, Dm7, Em7 (open) + Em7-shape barre, Am7-shape barre
- **Major 7**: Amaj7, Cmaj7, Dmaj7, Fmaj7 (open) + Emaj7-shape barre, Amaj7-shape barre
- **Diminished**: Dim7 shapes
- **Augmented**: Aug shapes
- **Sus2 / Sus4**: Common shapes

### Preloaded Scale Library
- Major: All 12 keys, CAGED positions
- Natural Minor: All 12 keys, CAGED positions
- Pentatonic Major: All 12 keys, 5 box positions
- Pentatonic Minor: All 12 keys, 5 box positions
- Blues: All 12 keys, 5 box positions

---

## User Interface

### Menu Bar Icon
- SF Symbol: `guitars` or custom icon (maybe a small fretboard simplified to 2-3 frets)
- Left click: toggle popover
- Right click: context menu (About, Quit)

### Popover Layout
```
┌──────────────────────────────────┐
│  🎸 Menu Bar Chords              │  ← Title bar
├──────────────────────────────────┤
│  [Browse | Quiz | Notes]         │  ← Mode selector (segmented control)
├──────────────────────────────────┤
│                                  │
│  (Mode-specific content)         │  ← Dynamic content area
│                                  │
│  ┌────────────────────────────┐  │
│  │     X  O     O            │  │  ← Mini fretboard (~250pt wide)
│  │   ╒═╤═╤═╗                 │  │
│  │   │ │ │ │●│               │  │
│  │   ├─┼─┼─┼─┤               │  │
│  │   │●│ │ │ │               │  │
│  │   ├─┼─┼─┼─┤               │  │
│  │   │ │●│●│●│               │  │
│  │   ├─┼─┼─┼─┤               │  │
│  │   │ │ │ │●│               │  │
│  │   ├─┼─┼─┼─┤               │  │
│  │   │ │ │●│ │               │  │
│  │   ├─┼─┼─┼─┤               │  │
│  │   │ │ │ │●│               │  │
│  │   ╘═╧═╧═╝                 │  │
│  │      3fr                   │  │  ← Fret number label
│  └────────────────────────────┘  │
│                                  │
│  [Controls for current mode]     │
│                                  │
└──────────────────────────────────┘
```

### Browse Mode UI
- **Root note picker**: Dropdown or segmented control with 12 notes
- **Chord/Scale toggle**: Segmented (Chord | Scale)
- **Type picker**: Dropdown based on selection (chord types or scale types)
- **Fretboard**: Shows selected chord/scale
- **Position selector** (if multiple voicings/boxes exist): Stepper or picker

### Chord Quiz Mode UI
- **Fretboard**: Shows a random chord shape (no name)
- **Guess input**: Two pickers — Root note + Chord type (or a single text field)
- **Submit button**: Check answer
- **Feedback**: "Correct! 🎉" or "Nope, that was Cmaj7"
- **Next button**: New random chord
- **Score display**: "3/5 correct · Streak: 2"

### Note Recognition Mode UI
- **String selector**: Segmented control (E, A, D, G, B, e) + "Random"
- **Position range filter**: Segmented (Open–5 | 5–12 | Any)
- **Note prompt**: Large text "Find: E" (or "E♭")
- **Reveal button**: Shows the answer on the mini fretboard
- **Mini fretboard**: Highlights all positions of the note on the selected string within range
- **Next Note button**

---

## Architecture

Following the same patterns as `menu-bar-metronome`:

```
menu-bar-chords/
├── Package.swift                    # SPM executable, macOS 14+
├── INTENTION.md                     # This file
├── Resources/
│   ├── Info.plist                   # LSUIElement=YES
│   └── Chords.entitlements          # Hardened runtime (no sandbox)
├── scripts/
│   └── bundle.sh                    # Build → assemble .app bundle
└── Sources/Chords/
    ├── ChordsApp.swift              # @main, MenuBarExtra / NSStatusItem + NSPopover
    ├── ContentView.swift            # Main popover: mode selector + content
    ├── FretboardView.swift          # Core mini fretboard rendering component
    ├── BrowseView.swift             # Browse mode: chord/scale reference
    ├── ChordQuizView.swift          # Quiz mode: guess the chord
    ├── NoteRecognitionView.swift    # Note recognition mode: find the note
    ├── Models/
    │   ├── AppModel.swift           # @Observable central state, mode selection, persistence
    │   ├── Note.swift               # Note enum, interval math, string/fret mapping
    │   ├── ChordDefinition.swift    # Chord data structures
    │   ├── ChordLibrary.swift       # Static chord database (open & barre shapes)
    │   ├── ScaleDefinition.swift    # Scale data structures
    │   ├── ScaleLibrary.swift       # Static scale database
    │   └── QuizState.swift          # Quiz scoring, streak, etc.
    └── Helpers/
        └── Persistence.swift        # @AppStorage / UserDefaults helpers
```

### Key Architectural Decisions
- **No Xcode required** — Pure SPM project, buildable with `swift run`
- **Zero dependencies** — Only SwiftUI, AppKit, Foundation
- **`@Observable`** for central state management (macOS 14+)
- **`NSStatusItem` + `NSPopover`** — Same pattern as the metronome for reliable menu bar behavior
- **Static data** — All chord/scale definitions are compile-time constants in Swift structs
- **No audio** — This is a visual reference + quiz tool, no sound needed
- **Persistent settings** — Mode, quiz scores, preferences via `@AppStorage`
- **Unsandboxed + hardened runtime** — Same security profile as the metronome

---

## Fretboard Rendering Details

The mini fretboard is drawn using SwiftUI `Canvas` or `Path`/`Shape`:

- **String lines**: 6 horizontal lines, optionally thicker at the bottom
- **Fret lines**: Vertical lines dividing the 3 columns
- **First column fret marker**: A small label (e.g., "5fr") at the top or bottom of the first column
- **Dots**: Filled circles at fret positions
  - Standard fill for regular notes
  - Distinct fill/outline for the root note
  - Numbers inside dots for finger positions
- **Barre arc**: A thick horizontal arc/line spanning multiple strings at the same fret
- **String labels**: "X" / "O" / empty above each string column

### Fretboard Config
- **Width**: ~250pt
- **Height**: ~150pt (enough space for 6 strings + fret number labels)
- **String spacing**: Evenly spaced vertically
- **Fret spacing**: Evenly spaced horizontally (3 columns = 2 fret gaps)

---

## Quiz Mode Logic

### Chord Quiz
1. Randomly pick a chord from the library (filtered by difficulty if needed)
2. Display it on the fretboard (no name shown)
3. User selects root note + chord type
4. On submit:
   - Check if root + type match the displayed chord
   - Update score: correct count, total count, streak
   - Show feedback animation
5. "Next" loads a new random chord

### Note Recognition
1. User picks a string (or "Random")
2. User picks a position range filter (or "Any")
3. Random note is selected
4. Note name is displayed prominently (e.g., "Find: C")
5. User practices finding and playing it
6. "Reveal" shows:
   - All positions of that note on the selected string within the range
   - Highlighted on the mini fretboard
   - The fretboard slides to show the position
7. "Next Note" repeats

---

## Future Ideas (Out of Scope for v1)

- Audio playback of chords (strum simulation)
- Left-handed fretboard option
- Custom chord builder (tap frets to build a chord, get its name)
- Scale degree highlighting (1, 3, 5, b7 etc.)
- Fretboard ear training (hear a chord, identify it)
- Export/import custom chord libraries
- Dark/light mode follow system
- iPad/iPhone companion via Catalyst or separate target
- Alternate tunings (Drop D, Open G, DADGAD, etc.)
- MIDI input support for quiz answers

---

## Technology Stack

| Layer | Technology |
|-------|-----------|
| Language | Swift 5.10+ |
| UI | SwiftUI |
| Window | `NSStatusItem` + `NSPopover` |
| State | `@Observable` (Swift Observation) |
| Persistence | `@AppStorage` / `UserDefaults` |
| Build | Swift Package Manager |
| Min macOS | 14 (Sonoma) |
| Dependencies | None (system frameworks only) |
