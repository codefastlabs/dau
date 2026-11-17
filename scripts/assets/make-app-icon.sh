#!/bin/zsh
# Regenerates the app icon sources: standard and development (docs/Brand.md "Biểu tượng", "Biểu tượng bản phát triển"; D25).
# Side effects: builds, writes repo files
#
#   scripts/assets/make-app-icon.sh
#       Write the Icon Composer documents Apps/Dau/Resources/AppIcon.icon (standard, official
#       build only) and AppIconDev.icon (every other build), and the flat copies
#       Resources/Brand/AppIcon.svg and AppIconDev.svg, from the outlined glyph in
#       Resources/Brand/app-icon-glyphs.txt. No font needed. project.yml picks the document
#       by DAU_OFFICIAL, Xcode compiles it (actool). To look at the result without opening
#       Icon Composer: scripts/assets/preview-app-icon.sh.
#
#   scripts/assets/make-app-icon.sh outline <BeVietnamPro-Bold.ttf>
#       Re-extract the glyph outline. Download the font from the official source
#       (https://github.com/google/fonts/tree/main/ofl/bevietnampro or
#       https://github.com/bettergui/BeVietnamPro) to a directory outside the repo.
#       Never commit the font file.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
BRAND="$ROOT/Resources/Brand"
GLYPHS="$BRAND/app-icon-glyphs.txt"
ICONS="$ROOT/Apps/Dau/Resources"
source "${0:A:h:h}/lib/log.sh"
source "${0:A:h:h}/lib/xcode.sh"
source "${0:A:h:h}/lib/swift-tool.sh"
dau_developer_dir
TOOL=$(dau_swift_tool make-app-icon "$ROOT/scripts/assets/make-app-icon.swift") || exit 1

if [[ "${1:-}" == "outline" ]]; then
  [[ $# -eq 2 ]] || log_die 2 "Cách dùng: $0 outline <font.ttf>"
  mkdir -p "$BRAND"
  exec "$TOOL" outline "$2" "$GLYPHS"
fi
[[ $# -eq 0 ]] || log_die 2 "Cách dùng: $0 [outline <font.ttf>]"

log_step "Dựng nguồn biểu tượng app (chuẩn và bản phát triển)"
# Render into a temp dir first; the repo's files are replaced only when the render succeeded,
# so a failed run never leaves a document half written.
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
# The renderer's "wrote …" lines are English; they are shown only when it fails.
out=$("$TOOL" render "$GLYPHS" "$TMP/svg" "$TMP/icon" 2>&1) \
  || { log_error "Không dựng được biểu tượng"; log_hint "${(@f)out}"; exit 1; }
for f in svg/AppIcon.svg svg/AppIconDev.svg icon/AppIcon.icon/icon.json icon/AppIconDev.icon/icon.json; do
  [[ -f "$TMP/$f" ]] || log_die "Dựng thiếu $f: giữ nguyên các file hiện có"
done

mkdir -p "$BRAND" "$ICONS"
cp "$TMP"/svg/*.svg "$BRAND"/
log_detail "đã cập nhật các SVG trong $BRAND"
for name in AppIcon AppIconDev; do
  rm -rf "$ICONS/$name.icon"
  cp -R "$TMP/icon/$name.icon" "$ICONS/$name.icon"
  log_detail "đã cập nhật $ICONS/$name.icon"
done
log_done "Đã dựng nguồn biểu tượng app"
