#!/bin/zsh
# Exports the GitHub social preview (1280×640) from the canvas artboard "Ảnh xem trước GitHub".
# Side effects: writes repo files
#
#   scripts/assets/export-github-preview.sh
#       Takes the artboard markup from docs/canvas/src/GithubPreview.dc.html, loads Be Vietnam
#       Pro (SIL OFL 1.1) from github.com/google/fonts into build/ (never committed), and
#       screenshots the page with headless Chrome into Resources/Brand/github-preview.png.
#       Why not the picture in docs/canvas/: the canvas puts its @import for the web font
#       after other CSS rules, where browsers ignore it, so that picture is set in a fallback
#       font; the logo must be Be Vietnam Pro (docs/Brand.md "Logo chữ").
#       Headless Chrome shows no window and keeps the keyboard focus where it is; the Dock
#       icon may flash once while it starts (see scripts/design/render-canvas.sh). It runs on
#       a profile of its own under build/. Needs network for the font download.
#       The picture is the file to upload at Settings > Social preview of the repository.
set -euo pipefail

ROOT="${0:A:h:h:h}"
source "$ROOT/scripts/lib/log.sh"
SRC="$ROOT/docs/canvas/src/GithubPreview.dc.html"
OUT="$ROOT/Resources/Brand/github-preview.png"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
[[ -f $SRC ]] || log_die "Không thấy $SRC"
[[ -x $CHROME ]] || log_die "Không thấy Google Chrome ở /Applications."

WORK="$ROOT/build/github-preview"
trap 'rm -rf "$WORK"' EXIT
rm -rf "$WORK"; mkdir -p "$WORK/fonts"

log_step "Tải phông Be Vietnam Pro"
for weight in Medium:500 SemiBold:600 Bold:700 ExtraBold:800; do
  curl -sfL -o "$WORK/fonts/${weight%%:*}.ttf" \
    "https://github.com/google/fonts/raw/main/ofl/bevietnampro/BeVietnamPro-${weight%%:*}.ttf" \
    || log_die "Không tải được BeVietnamPro-${weight%%:*}.ttf (cần mạng)."
done

log_step "Dựng trang và chụp"
{
  print '<!doctype html><html lang="vi"><head><meta charset="utf-8"><style>'
  for weight in Medium:500 SemiBold:600 Bold:700 ExtraBold:800; do
    print "@font-face{font-family:'Be Vietnam Pro';font-weight:${weight##*:};src:url('fonts/${weight%%:*}.ttf')}"
  done
  print 'html,body{margin:0}</style></head><body>'
  # The artboard is the markup between <x-dc> and </x-dc>; its only variable is the accent
  # colour, which this artboard does not use.
  sed -n '/<x-dc>/,/<\/x-dc>/p' "$SRC" | sed -e '/<\/\{0,1\}x-dc>/d' -e '/<helmet>/,/<\/helmet>/d' \
    -e 's/{{accent}}/#0A64D8/'
  print '</body></html>'
} > "$WORK/index.html"

"$CHROME" --headless=new --disable-gpu --hide-scrollbars --force-device-scale-factor=1 \
  --user-data-dir="$WORK/profile" --window-size=1280,640 --virtual-time-budget=5000 \
  --screenshot="$WORK/out.png" "file://$WORK/index.html" >/dev/null 2>&1 \
  || log_die "Chrome không chụp được trang."
[[ -f $WORK/out.png ]] || log_die "Chrome không ghi ảnh."
size=$(sips -g pixelWidth -g pixelHeight "$WORK/out.png" | awk '/pixel/ {printf "%s ", $2}')
[[ $size == "1280 640 " ]] || log_die "Ảnh ra ${size}, cần 1280 640."
mkdir -p "${OUT:h}"
cp "$WORK/out.png" "$OUT"
log_done "Đã xuất $OUT"
