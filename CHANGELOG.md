# Changelog

## [Unreleased]

### Added

- Audio playback — tap play button to hear chords via built-in DLS Synth MIDI engine
- Settings panel with configurable: menu bar icon, note naming (sharps/flats), popover size (Compact/Spacious), guitar sound (5 voices), quiz filter (All / Open only)
- PopUpButtonPicker (NSPopUpButton via NSViewRepresentable) replacing SwiftUI .pickerStyle(.menu) to fix macOS 14+ crash in popovers
- SelfTest CLI runner via `swift run Chords --selftest`
- Combined test script `scripts/test.sh`
- Auto-sizing popover height based on content instead of fixed 400pt
- Fret value labels on right side of fretboard, open string (O) markers
- Injectable UserDefaults for testability in AppModel
- Note naming scheme preference (sharps .name / flats .flatName)

### Fixed

- .pickerStyle(.menu) crash on macOS 14+ in popover context
- Fretboard X markers positioned per-string instead of clipped at top
- Chord data: corrected fingerings for A, Am, A7, B7, C7, Amaj7, Cmaj7, Dmaj7, Fmaj7, A_sus2, A_sus4, G_sus4, E-shape/A-shape barre chords
- A_sus2 fret 1 corrected from 2 to 0
- Popover sizing now fits content dynamically
- Segmented picker labels hidden for cleaner appearance

### Changed

- ChordLibrary.chord() lookup from byId dictionary to all.first { $0.root == root && $0.type == type }
- All pickers (root, type, string) replaced with PopUpButtonPicker
- Note names use AppModel.noteName() respecting naming scheme
- Tests restructured under Tests/ChordsTests/ with new AppModelTests.swift
