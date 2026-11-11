#!/bin/zsh
# Regenerates the temporary app icons: standard and development (docs/BRAND.md "Biểu tượng", "Biểu tượng bản phát triển"; D25).
# Side effects: builds, writes repo files
#
#   scripts/assets/make-app-icon.sh [<preview-dir>]
#       Render Resources/Brand/AppIcon*.svg and AppIconDev*.svg, and the asset catalog sets
#       Apps/Dau/Resources/Assets.xcassets/AppIcon.appiconset (standard, official build only)
#       and AppIconDev.appiconset (every other build), from the outlined glyphs in
#       Resources/Brand/app-icon-glyphs.txt. No font needed. With <preview-dir>, also write
#       icon-512.png and sizes.png (16/32/64/128 px, actual size and magnified) for the
#       standard icon, and the same two files in <preview-dir>/dev for the development icon.
#       project.yml picks the set by DAU_OFFICIAL.
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
ASSETS="$ROOT/Apps/Dau/Resources/Assets.xcassets"
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

log_step "Dựng biểu tượng app (chuẩn và bản phát triển)"
mkdir -p "$ASSETS"
if [[ ! -f "$ASSETS/Contents.json" ]]; then
  printf '{\n  "info" : {\n    "author" : "xcode",\n    "version" : 1\n  }\n}\n' > "$ASSETS/Contents.json"
fi

# Render into a temp dir first; the repo's SVGs and iconsets are replaced only when both
# renders succeeded, so a failed run never leaves an iconset empty or half written.
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
preview="${1:-}"

# render_variant <label> <name> [--dev]: render into $TMP/<name>/{svg,iconset}.
render_variant() {
  local label="$1" name="$2"; shift 2
  mkdir -p "$TMP/$name/svg" "$TMP/$name/iconset"
  local pv=()
  if [[ -n "$preview" ]]; then
    if [[ "$name" == "AppIconDev" ]]; then pv=("$preview/dev"); else pv=("$preview"); fi
  fi
  # The renderer's "wrote …" lines are English; they are shown only when it fails.
  local out
  out=$("$TOOL" render "$@" "$GLYPHS" "$TMP/$name/svg" "$TMP/$name/iconset" "${pv[@]}" 2>&1) \
    || { log_error "Không render được $label"; log_hint "${(@f)out}"; exit 1; }
  local rendered=("$TMP/$name"/iconset/*.png(N))
  if (( ${#rendered} == 0 )) || [[ ! -f "$TMP/$name/iconset/Contents.json" ]]; then
    log_die "Render $label không ra đủ file (không có PNG hoặc Contents.json): giữ nguyên $ASSETS/$name.appiconset"
  fi
}
render_variant "biểu tượng chuẩn" AppIcon
render_variant "biểu tượng bản phát triển" AppIconDev --dev

mkdir -p "$BRAND"
for name in AppIcon AppIconDev; do
  set="$ASSETS/$name.appiconset"
  mkdir -p "$set"
  old_pngs=("$set"/*.png(N))
  (( ${#old_pngs} == 0 )) || rm -f "${old_pngs[@]}"
  cp "$TMP/$name"/iconset/* "$set"/
  cp "$TMP/$name"/svg/* "$BRAND"/
  log_detail "đã cập nhật $set"
done
log_detail "đã cập nhật các SVG trong $BRAND"
log_done "Đã dựng biểu tượng app"
