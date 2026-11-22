#!/bin/zsh
# Regenerates the background of the Dấu disk image window (docs/Brand.md "File cần xuất").
# Side effects: builds, writes repo files
#
#   scripts/assets/make-dmg-background.sh
#       Write Resources/Brand/DmgBackground.png (640 × 400 px, 72 dpi) and DmgBackground@2x.png
#       (1280 × 800 px, 144 dpi), drawn from the canvas artboard "Cửa sổ ảnh đĩa DMG"
#       (docs/canvas/src/DmgWindow.dc.html). Giấy and the faint Mực arrow only: no icon, no
#       text, Finder draws those.
#
# Geometry the release scripts rely on (scripts/release/layout-dmg.sh):
#   window content area  640 × 400 pt (below the title bar; the window bounds are 640 × 428)
#   icon size            128 pt
#   icon centres (pt, origin top left of the content area)
#                        Dấu.app (160, 180), Applications (480, 180)
#   arrow                x 260–380, y 160–200
# scripts/release/build-release.sh joins the two PNGs into one multi-resolution TIFF with
# `tiffutil -cathidpicheck` (the 1x and 2x pictures; the 2x must be exactly twice the size,
# which the tool checks), so no TIFF is kept in the repo.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
OUT="$ROOT/Resources/Brand"
source "${0:A:h:h}/lib/log.sh"
source "${0:A:h:h}/lib/swift-tool.sh"
TOOL=$(dau_swift_tool make-dmg-background "$ROOT/scripts/assets/MakeDmgBackground.swift") || exit 1

log_step "Dựng nền cửa sổ DMG"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
# The renderer's "wrote …" lines are English; they are shown only when it fails.
out=$("$TOOL" "$TMP" 2>&1) || { log_error "Không dựng được nền DMG"; log_hint "${(@f)out}"; exit 1; }
mkdir -p "$OUT"
cp "$TMP/DmgBackground.png" "$TMP/DmgBackground@2x.png" "$OUT"/
log_detail "đã ghi $OUT/DmgBackground.png và DmgBackground@2x.png"
log_done "Đã dựng nền cửa sổ DMG"
