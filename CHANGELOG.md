# Changelog

## [Unreleased]

### Added

- Note practice session tracking — start/end session with got-it/missed buttons and feedback
- Note session history in hover view with session duration, notes attempted, correct/wrong counts, accuracy
- History tab filter (Quiz / Notes) and per-session delete with confirmation alert
- Bundle outputs directly to `~/Applications/Chords.app` for Spotlight and Raycast discoverability

### Fixed

- History section scroll height increased from 180pt to 250pt for better visibility of more sessions

### Changed

- `scripts/bundle.sh` now builds `.app` directly into `~/Applications/` instead of `build/`
- Quiz sessions can now be individually deleted via x-mark button in history view
