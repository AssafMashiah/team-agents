#!/bin/bash
set -euo pipefail

# One-time setup for the AssafMashiah/slides GitHub repo
# Creates the repo on GitHub (if needed), clones it, and sets up .gitignore + README

SLIDES_DIR="$HOME/Documents/AssafMashiah/slides"

# Skip if already set up
if [ -d "$SLIDES_DIR/.git" ]; then
    echo "Slides repo already exists at $SLIDES_DIR"
    exit 0
fi

# Create GitHub repo if it doesn't exist
if ! gh repo view AssafMashiah/slides &>/dev/null; then
    echo "Creating GitHub repo AssafMashiah/slides..."
    gh repo create AssafMashiah/slides --public --description "Slide decks built by Jade"
fi

# Clone
echo "Cloning to $SLIDES_DIR..."
mkdir -p "$(dirname "$SLIDES_DIR")"
gh repo clone AssafMashiah/slides "$SLIDES_DIR"

cd "$SLIDES_DIR"

# .gitignore
cat > .gitignore << 'EOF'
node_modules/
dist/
.slidev/
package-lock.json
EOF

# README
cat > README.md << 'EOF'
# Slides

Presentation decks built with [Slidev](https://sli.dev) by Jade.

Each folder is a self-contained deck with:
- `data.md` — content source of truth
- `design-system.json` — color palette, fonts, layout strategy
- `slides.md` — final Slidev deck
- `public/` — generated images

Served at [slides.thrallboy.com](https://slides.thrallboy.com).
EOF

git add .gitignore README.md
git commit -m "init: repo setup"
git push

echo "Done! Slides repo ready at $SLIDES_DIR"
