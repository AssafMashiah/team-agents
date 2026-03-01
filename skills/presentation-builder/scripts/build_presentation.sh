#!/bin/bash
set -euo pipefail

# Build a Slidev presentation to a static SPA
# Usage: build_presentation.sh <project-dir> <slug>
#
# project-dir: path to the slidev project (contains slides.md + package.json)
#              Typically ~/Documents/thrallboy/slides/{slug}/
# slug: URL slug for the presentation (e.g., "my-talk")
#
# Output goes to ~/Documents/thrallboy/presentations/builds/<slug>/

PROJECT_DIR="${1:?Usage: build_presentation.sh <project-dir> <slug>}"
SLUG="${2:?Usage: build_presentation.sh <project-dir> <slug>}"
BUILDS_DIR="$HOME/Documents/thrallboy/presentations/builds"

# Ensure builds dir exists
mkdir -p "$BUILDS_DIR"

cd "$PROJECT_DIR"

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    npm install
fi

# Build static SPA
echo "Building presentation '$SLUG'..."
npx slidev build --base "/$SLUG/" --out "$BUILDS_DIR/$SLUG"

echo ""
echo "Build complete!"
echo "  Local:  http://localhost:3030/$SLUG/"
echo "  Public: https://slides.thrallboy.com/$SLUG/"
