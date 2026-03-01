#!/usr/bin/env bash
set -euo pipefail

# Upload a presentation build to the slides-builds R2 bucket.
# Usage: upload_to_r2.sh <slug>

SLUG="${1:?Usage: upload_to_r2.sh <slug>}"
BUILDS_DIR="$HOME/Documents/thrallboy/presentations/builds"
BUILD_PATH="$BUILDS_DIR/$SLUG"

if [ ! -d "$BUILD_PATH" ]; then
  echo "Error: build directory not found: $BUILD_PATH" >&2
  exit 1
fi

# Map file extension to Content-Type
content_type() {
  case "${1##*.}" in
    html) echo "text/html" ;;
    css)  echo "text/css" ;;
    js)   echo "application/javascript" ;;
    json) echo "application/json" ;;
    png)  echo "image/png" ;;
    jpg|jpeg) echo "image/jpeg" ;;
    svg)  echo "image/svg+xml" ;;
    webp) echo "image/webp" ;;
    woff) echo "font/woff" ;;
    woff2) echo "font/woff2" ;;
    ttf)  echo "font/ttf" ;;
    ico)  echo "image/x-icon" ;;
    xml)  echo "application/xml" ;;
    txt)  echo "text/plain" ;;
    *)    echo "application/octet-stream" ;;
  esac
}

BUCKET="slides-builds"
COUNT=0

echo "Uploading $BUILD_PATH → r2://$BUCKET/$SLUG/"

while IFS= read -r -d '' file; do
  rel="${file#$BUILD_PATH/}"
  key="$SLUG/$rel"
  ct=$(content_type "$file")

  echo "  $key ($ct)"
  wrangler r2 object put "$BUCKET/$key" --file "$file" --content-type "$ct" 2>&1 | tail -1
  ((COUNT++))
done < <(find "$BUILD_PATH" -type f -print0)

echo "Done — uploaded $COUNT files to r2://$BUCKET/$SLUG/"
