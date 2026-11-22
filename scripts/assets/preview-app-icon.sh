#!/bin/zsh
# Exports the app icon documents to PNG for a look by eye, without opening Icon Composer.
# Side effects: builds
#
#   scripts/assets/preview-app-icon.sh [<out-dir>]
#       For AppIcon.icon and AppIconDev.icon, with ictool from Icon Composer.app (inside
#       Xcode; no window is shown): <name>-<rendition>-<size>.png for the renditions Default,
#       Dark, TintedLight, TintedDark, ClearLight, ClearDark at 16, 32, 128, 512, 1024 px.
#       <out-dir> defaults to build/icon-check/ (git ignores build/); the pictures are
#       never committed (docs/Brand.md asks for the check by eye at 16–32 pt, and in the
#       Clear and Tinted renditions).
set -euo pipefail

ROOT="${0:A:h:h:h}"
source "$ROOT/scripts/lib/log.sh"
# Icon Composer's ictool, not the one in usr/bin (xcrun --find ictool), which cannot export images.
IC="$(xcode-select -p)/../Applications/Icon Composer.app/Contents/Executables/ictool"
[[ -x $IC ]] || log_die "Không thấy ictool trong Icon Composer.app của Xcode mà xcode-select chọn ($IC)."
OUT=${1:-$ROOT/build/icon-check}
mkdir -p "$OUT"

log_step "Xuất biểu tượng ra $OUT"
for name in AppIcon AppIconDev; do
  for rendition in Default Dark TintedLight TintedDark ClearLight ClearDark; do
    for px in 16 32 128 512 1024; do
      "$IC" "$ROOT/Apps/Dau/Resources/$name.icon" --export-image \
        --output-file "$OUT/$name-$rendition-$px.png" --platform macOS \
        --rendition $rendition --width $px --height $px --scale 1 >/dev/null \
        || log_die "ictool không xuất được $name $rendition $px"
    done
  done
done
log_done "Đã xuất 60 ảnh"
