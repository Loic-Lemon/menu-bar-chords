#!/bin/bash
set -e
echo "=== Running XCTests ==="
swift test
echo ""
echo "=== Running SelfTest ==="
swift run Chords --selftest
echo ""
echo "All tests passed."
