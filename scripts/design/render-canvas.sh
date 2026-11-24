#!/bin/zsh
# Renders the design canvas artboards to PNG and copies their sources into docs/canvas/,
# so the approved design can be read without access to the canvas on claude.ai.
# Side effects: builds, writes repo files (also rewrites <dir>/project/canvas.json when a page board is not its frame height)
#
# Usage: scripts/design/render-canvas.sh <dir> [--out <folder>]
#   dir     a local copy of the canvas files: <dir>/project/*.dc.html, <dir>/project/canvas.json
#           and <dir>/artifact-type/dc-runtime.js. Claude saves them with the Artifact tool
#           (action "read" with `paths`); there is no other way to download them. Images an
#           artboard shows from the canvas uploads (src="/_blob/<id>") go in <dir>/_blob/, saved
#           with the Artifact tool (action "read", path <id>, which names the file <id>.<ext>).
#   --out   write the snapshot to <folder> instead of docs/canvas/ (to try a render without
#           touching the repo). The folder must be missing, empty or an earlier snapshot.
#
# Renders every artboard on every canvas page except "archive" with one
# headless Chrome for the whole run (CanvasRender.swift drives it over the DevTools pipe):
# no window is shown and the keyboard focus stays where it is. macOS lists that Chrome as a
# foreground app for a few hundredths of a second while it starts, before Chrome declares
# itself a background process, so its Dock icon can flash once at the start. Chrome runs on
# a profile of its own under build/canvas/, never the user's.
# The canvas runtime (dc-runtime.js) is the canvas publisher's code: it is opened from
# build/canvas/ as a file:// page for the render only and never copied into the repo.
# A page board ("expand": "fill") is captured at the height of its content, not of its frame,
# so a longer text is never cut off. When that height differs from the frame, the new height
# goes into the snapshot's canvas.json and into <dir>/project/canvas.json, boards below it in its
# column move by the same amount, and the script says so: publish that file to the canvas
# (Apps/Dau/CLAUDE.md) so the frames match the snapshot.
# Writes <name>.png, src/<name>.dc.html, canvas.json and README.md (index by section) into
# the output folder. The old snapshot is replaced only after every board rendered; when a
# board fails or the run is interrupted it stays as it was. build/canvas/ and the Chrome
# this script started are removed on every exit.
# Needs network for the web fonts: a resource that does not load is reported per board and
# the run goes on, so read the warnings before committing the pictures.
set -euo pipefail
ROOT="${0:A:h:h:h}"
source "$ROOT/scripts/lib/log.sh"
source "$ROOT/scripts/lib/swift-tool.sh"
source "$ROOT/scripts/lib/wait.sh"

SRC=""
OUT="$ROOT/docs/canvas"
while (( $# )); do
  case $1 in
    -h|--help) log_usage "$0"; exit 0 ;;
    --out) (( $# >= 2 )) || log_die 2 "--out cần một thư mục."; OUT=${2:a}; shift 2 ;;
    -*) log_die 2 "Tuỳ chọn lạ: $1" ;;
    *) [[ -z $SRC ]] || log_die 2 "Chỉ nhận một thư mục canvas."; SRC=$1; shift ;;
  esac
done
[[ -n "$SRC" && -f "$SRC/project/canvas.json" && -f "$SRC/artifact-type/dc-runtime.js" ]] \
  || log_die 2 "Cần thư mục có project/canvas.json và artifact-type/dc-runtime.js (xem đầu script)."
# The output folder is deleted before the new snapshot moves in: only ever a snapshot.
[[ ! -e $OUT || -f $OUT/canvas.json || ( -d $OUT && -z "$(ls -A "$OUT")" ) ]] \
  || log_die 2 "$OUT đã có nội dung không phải bản chụp canvas; chọn thư mục khác."
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
[[ -x "$CHROME" ]] || log_die "Không thấy Google Chrome ở /Applications."

WORK="$ROOT/build/canvas"
PROFILE="$WORK/profile"

chrome_gone() { ! kill -0 "$1" 2>/dev/null }

# Stops the Chrome this run started, if it is still there, then removes the work folder.
# The pid comes from a file, so the process is checked to be that Chrome (its command line
# names this run's profile) before it is signalled.
cleanup() {
  local pid=""
  [[ -f $WORK/chrome.pid ]] && pid=$(< "$WORK/chrome.pid")
  if [[ $pid == <-> && "$(ps -o command= -p "$pid" 2>/dev/null)" == *"--user-data-dir=$PROFILE"* ]]; then
    kill "$pid" 2>/dev/null
    wait_until -i 0.1 5 chrome_gone "$pid" || kill -9 "$pid" 2>/dev/null
  fi
  rm -rf "$WORK"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM HUP

rm -rf "$WORK"; mkdir -p "$WORK/project" "$PROFILE" "$WORK/out/src"
cp "$SRC"/project/*.dc.html "$SRC/project/canvas.json" "$WORK/project/"
# Canvas uploads live only on claude.ai: the render copy points /_blob/<id> at the saved files.
if [[ -d $SRC/_blob ]]; then
  mkdir -p "$WORK/project/_blob"
  for upload in "$SRC"/_blob/*(N.); do cp "$upload" "$WORK/project/_blob/${${upload:t}%%.*}"; done
  sed -i "" "s|\"/_blob/|\"./_blob/|g" "$WORK"/project/*.dc.html
fi
cp "$SRC/artifact-type/dc-runtime.js" "$WORK/project/support.js"

INDEX=$(dau_swift_tool canvas-index "${0:A:h}/CanvasIndex.swift") || exit 1
RENDER=$(dau_swift_tool canvas-render "${0:A:h}/CanvasRender.swift") || exit 1

# name<TAB>width<TAB>height<TAB>kind for the boards outside the "archive" page, in canvas order.
"$INDEX" boards "$WORK/project/canvas.json" > "$WORK/boards.tsv"
count=$(wc -l < "$WORK/boards.tsv" | tr -d ' ')
(( count > 0 )) || log_die "canvas.json không có artboard nào ngoài trang archive."
while IFS=$'\t' read -r name w h kind; do
  [[ -f $WORK/project/$name ]] || log_die "canvas.json có $name nhưng thư mục không có file đó."
done < "$WORK/boards.tsv"

log_step "Chụp $count artboard bằng một Chrome chạy ẩn"
failed=0 warned=0
resized=()  # name height, for the page boards whose content is not their frame height
# Lines from canvas-render: ok/warn/resize/fail, then the board, then the details.
"$RENDER" "$CHROME" "$PROFILE" "$WORK/project" "$WORK/out" "$WORK/chrome.pid" < "$WORK/boards.tsv" \
  | while IFS=$'\t' read -r kind name a b; do
      case $kind in
        ok)   cp "$SRC/project/$name" "$WORK/out/src/"; log_detail "$name (${a}×${b})" ;;
        warn) log_warn "$name: $a"; warned=1 ;;
        resize) resized+=("$name" "$a") ;;
        fail) log_warn "Không chụp được $name: $a"; failed=1 ;;
      esac
    done || failed=1
(( failed == 0 )) || log_die "Có artboard không chụp được (xem trên); $OUT giữ nguyên."
(( warned == 0 )) || log_hint "Ảnh của các artboard trên có thể thiếu phông hoặc hình; kiểm lại mạng rồi chạy lại."

if (( ${#resized} )); then
  heights="{}"
  for name h in "${resized[@]}"; do
    log_detail "$name: khung trên canvas thành $h px cho vừa nội dung"
    (( h <= 8000 )) || log_warn "$name cao $h px, quá giới hạn 8000 px của canvas: tách artboard ở ranh giới một mục (Apps/Dau/CLAUDE.md)."
    heights=$(jq --arg n "$name" --argjson h "$h" '. + {($n): $h}' <<< "$heights")
  done
  # Each resized board takes its new height, and every board on its page that starts below its
  # old bottom and shares part of its columns moves by the same amount: the gap between rows
  # stays and no frame covers another.
  jq --argjson heights "$heights" '
    reduce ($heights | to_entries[]) as $r (.;
      .boards[$r.key] as $b
      | ($r.value - $b.h) as $delta
      | .boards |= with_entries(
          if .key == $r.key then .value.h = $r.value
          elif (.value.page // "") == ($b.page // "") and .value.y >= $b.y + $b.h
               and .value.x < $b.x + $b.w and $b.x < .value.x + .value.w
          then .value.y += $delta
          else . end))' "$WORK/project/canvas.json" > "$WORK/canvas.json"
  mv "$WORK/canvas.json" "$WORK/project/canvas.json"
  cp "$WORK/project/canvas.json" "$SRC/project/canvas.json"
  log_hint "Publish $SRC/project/canvas.json lên canvas để khung khớp bản chụp (Apps/Dau/CLAUDE.md)."
fi
cp "$WORK/project/canvas.json" "$WORK/out/"
"$INDEX" readme "$WORK/project/canvas.json" > "$WORK/out/README.md"
rm -rf "$OUT"; mkdir -p "${OUT:h}"; mv "$WORK/out" "$OUT"
log_ok "Xong: $OUT"
log_done
