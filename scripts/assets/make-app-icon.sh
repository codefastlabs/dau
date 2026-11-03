#!/usr/bin/env bash
# Regenerates the temporary app icon (docs/BRAND.md "Biểu tượng", D25).
# Side effects: writes repo files
#
#   scripts/assets/make-app-icon.sh [<preview-dir>]
#       Render Resources/Brand/AppIcon*.svg and
#       Apps/Dau/Resources/Assets.xcassets/AppIcon.appiconset from the outlined glyphs in
#       Resources/Brand/app-icon-glyphs.txt. No font needed. With <preview-dir>, also write
#       icon-512.png and sizes.png (16/32/64/128 px, actual size and magnified).
#
#   scripts/assets/make-app-icon.sh outline <BeVietnamPro-Bold.ttf>
#       Re-extract the glyph outlines. Download the font from the official source
#       (https://github.com/google/fonts/tree/main/ofl/bevietnampro or
#       https://github.com/bettergui/BeVietnamPro) to a directory outside the repo.
#       Never commit the font file.
#
# TODO(M7): the official icon is built in Icon Composer (Default / Dark / Clear / Tinted).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
BRAND="$ROOT/Resources/Brand"
GLYPHS="$BRAND/app-icon-glyphs.txt"
ICONSET="$ROOT/Apps/Dau/Resources/Assets.xcassets/AppIcon.appiconset"
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"

if [[ "${1:-}" == "outline" ]]; then
  [[ $# -eq 2 ]] || { echo "usage: $0 outline <font.ttf>" >&2; exit 2; }
  mkdir -p "$BRAND"
  exec xcrun swift "$ROOT/scripts/assets/make-app-icon.swift" outline "$2" "$GLYPHS"
fi

mkdir -p "$ROOT/Apps/Dau/Resources/Assets.xcassets"
if [[ ! -f "$ROOT/Apps/Dau/Resources/Assets.xcassets/Contents.json" ]]; then
  printf '{\n  "info" : {\n    "author" : "xcode",\n    "version" : 1\n  }\n}\n' \
    > "$ROOT/Apps/Dau/Resources/Assets.xcassets/Contents.json"
fi

# Render into a temp dir first; the repo's SVGs and iconset are replaced only when the
# render succeeded, so a failed run never leaves the iconset empty or half written.
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/svg" "$TMP/iconset"
xcrun swift "$ROOT/scripts/assets/make-app-icon.swift" render "$GLYPHS" "$TMP/svg" "$TMP/iconset" ${1:+"$1"}
if ! ls "$TMP"/iconset/*.png >/dev/null 2>&1 || [[ ! -f "$TMP/iconset/Contents.json" ]]; then
  echo "Render không ra đủ file (không có PNG hoặc Contents.json): giữ nguyên $ICONSET" >&2
  exit 1
fi
mkdir -p "$ICONSET" "$BRAND"
rm -f "$ICONSET"/*.png
cp "$TMP"/iconset/* "$ICONSET"/
cp "$TMP"/svg/* "$BRAND"/
echo "Đã cập nhật $ICONSET và các SVG trong $BRAND"
