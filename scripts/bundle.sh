#!/bin/bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🏗️ Building Chords (release)..."
swift build -c release

BUNDLE_DIR="build/Chords.app"
rm -rf "$BUNDLE_DIR"

echo "📦 Assembling $BUNDLE_DIR..."
mkdir -p "$BUNDLE_DIR/Contents/MacOS"
mkdir -p "$BUNDLE_DIR/Contents/Resources"

cp .build/release/Chords "$BUNDLE_DIR/Contents/MacOS/"
cp Resources/Info.plist "$BUNDLE_DIR/Contents/"

codesign --force --sign - --options runtime "$BUNDLE_DIR" 2>/dev/null || true

echo "✅ Built: $BUNDLE_DIR"
echo "   Run: open \"$BUNDLE_DIR\""
