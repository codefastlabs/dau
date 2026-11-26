#!/bin/zsh
# Measures how macOS's per-document input source memory splits Chrome's web content: per tab, per window or one shared memory for all pages.
# Side effects: builds, takes the screen, changes input source
#
# Usage: scripts/research/input-source-memory/run.sh [--rounds N]
#   --rounds N   tab A / tab B round trips (default 3)
#
# Needs macOS's "Automatically switch to a document's input source" on
# (com.apple.HIToolbox AppleGlobalTextInputProperties TextInputGlobalPropertyPerContextInput),
# the "Select next source in Input menu" shortcut on, and U.S. and Dấu enabled.
# Opens one new Chrome window with two tabs of a local page (a text field that copies its
# text into the page title; Esc empties it), puts U.S. in tab A and Dấu in tab B with the
# system's shortcut, then switches tabs and reads which source macOS selects and which
# input method actually handles keys: "vieetj " gives "việt " with Dấu, "vieetj " with U.S. Then tab A
# loads another page in the same tab, and a new tab is opened from tab A; both are read too.
# Keys are only sent while Chrome is the front app. At the end the window is closed and the
# input source put back. The pages and the table go to build/input-source-memory/<time>/.
# Exit status: 0 when every step was read; 1 when a step could not be read.
set -uo pipefail
ROOT="${0:A:h:h:h:h}"
source "$ROOT/scripts/lib/log.sh"
source "$ROOT/scripts/lib/swift-tool.sh"

ROUNDS=3
while (( $# )); do
  case "$1" in
    --rounds) ROUNDS="$2"; shift 2 ;;
    *) log_die "Tuỳ chọn không rõ: $1" ;;
  esac
done

US=com.apple.keylayout.US
DAU=com.codefastlabs.dau.inputmethod.Dau.vi
INPUT_SOURCE="$(dau_swift_tool input-source "$ROOT/scripts/lib/InputSource.swift")" || exit 1
OUT="$ROOT/build/input-source-memory/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUT"

per_context="$(defaults read com.apple.HIToolbox AppleGlobalTextInputProperties 2>/dev/null)"
[[ "$per_context" == *"TextInputGlobalPropertyPerContextInput = 1"* ]] \
  || log_die "Tuỳ chọn tự chuyển nguồn theo tài liệu của macOS đang tắt: phép đo này không có nghĩa"
"$INPUT_SOURCE" enabled "" | grep -qx "$DAU" || log_die "Dấu chưa có trong nguồn đầu vào"
"$INPUT_SOURCE" enabled "" | grep -qx "$US" || log_die "U.S. chưa có trong nguồn đầu vào"
START_SOURCE="$("$INPUT_SOURCE" current)"

# The page: one text field with focus on load; its text goes to the title, which Chrome's
# AppleScript reads without "Allow JavaScript from Apple Events".
page() { # name
  cat > "$OUT/$1.html" <<EOF
<!doctype html><meta charset="utf-8"><title>$1:</title>
<body style="font:32px system-ui;margin:40px"><p>$1</p>
<textarea id=t autofocus style="font:32px system-ui;width:80%;height:120px"></textarea>
<script>
const t = document.getElementById('t');
const show = () => document.title = '$1:' + t.value + '|';
t.addEventListener('input', show);
t.addEventListener('keydown', e => { if (e.key === 'Escape') { t.value = ''; show(); } });
</script>
EOF
}
page tabA; page tabB; page tabA2; page tabC

chrome() { osascript -e "tell application \"Google Chrome\" to $1" 2>/dev/null; }
front_is_chrome() {
  [[ "$(osascript -e 'tell application "System Events" to name of first process whose frontmost is true')" == "Google Chrome" ]]
}
key() { # osascript System Events body
  front_is_chrome || { log_error "Chrome không ở trước: không gửi phím"; return 1; }
  osascript -e "tell application \"System Events\" to $1" >/dev/null
}
current() { "$INPUT_SOURCE" current; }

# The system's "Select next source in Input menu" shortcut (symbolic hot key 61), pressed
# until macOS reports the wanted source; same reasoning as cycle_to_source in
# scripts/selftest/typing/run.sh.
cycle_to() { # source-id
  local json k mods using="" n
  json="$(plutil -extract AppleSymbolicHotKeys.61 json -o - "$HOME/Library/Preferences/com.apple.symbolichotkeys.plist" 2>/dev/null)"
  [[ "$json" == *'"enabled":true'* && "$json" =~ '"parameters":\[[0-9]+,([0-9]+),([0-9]+)\]' ]] \
    || { log_error "Phím tắt \"Select next source in Input menu\" đang tắt"; return 1; }
  k=$match[1]; mods=$match[2]
  (( mods & 131072 )) && using+="shift down, "
  (( mods & 262144 )) && using+="control down, "
  (( mods & 524288 )) && using+="option down, "
  (( mods & 1048576 )) && using+="command down, "
  using="${using%, }"
  [[ "$(current)" == "$1" ]] && return 0
  for n in {1..10}; do
    key "key code $k using {$using}" || return 1
    sleep 0.6
    [[ "$(current)" == "$1" ]] && return 0
  done
  log_error "Không chuyển được tới $1"; return 1
}

# Which input method handles keys in the focused field: types "vieetj " and reads the title.
probe() { # page-name -> prints "dau", "us" or the text seen
  local title text
  # One key every 120 ms, close to normal typing; a whole-string keystroke sends the keys
  # at once, which is not a real typing speed (D13).
  key 'repeat with c in characters of "vieetj "
    keystroke c
    delay 0.12
  end repeat' || { print "?"; return 1; }
  sleep 0.6
  title="$(chrome 'title of active tab of front window')"
  text="${${title#*:}%|}"
  key 'key code 53' >/dev/null  # Esc empties the field
  sleep 0.3
  case "$text" in
    "việt ") print dau ;;
    "vieetj ") print us ;;
    *) print "other($text)" ;;
  esac
}

short() { case "$1" in $US) print US ;; $DAU) print Dấu ;; *) print "$1" ;; esac; }

ERR=0
TABLE="$OUT/summary.md"
print "| Bước | Nguồn macOS báo | Phím ra |\n|---|---|---|" > "$TABLE"
row() { # step source probe
  print "| $1 | $2 | $3 |" >> "$TABLE"
  log_detail "$1: nguồn $2, phím ra $3"
}
read_step() { # step-name
  local src p
  sleep 1
  src="$(short "$(current)")"
  p="$(probe)" || ERR=1
  row "$1" "$src" "$p"
}

cleanup() {
  log_step "Dọn dẹp"
  [[ -n "${WIN_ID:-}" ]] && chrome "close (first window whose id is $WIN_ID)"
  if [[ "$(current)" != "$START_SOURCE" ]]; then
    "$INPUT_SOURCE" select "$START_SOURCE" >/dev/null 2>&1 || true
  fi
  log_ok "Đã đóng cửa sổ Chrome của phép đo, nguồn đầu vào: $(short "$(current)")"
}
trap cleanup EXIT INT TERM

log_step "Mở cửa sổ Chrome mới với hai tab"
chrome 'activate'
chrome 'make new window'
WIN_ID="$(chrome 'id of front window')"
chrome "set URL of active tab of front window to \"file://$OUT/tabA.html\""
chrome "make new tab at end of tabs of front window with properties {URL:\"file://$OUT/tabB.html\"}"
sleep 2

log_step "Đặt U.S. ở tab A, Dấu ở tab B"
chrome 'set active tab index of front window to 1'; sleep 1
cycle_to "$US" || exit 1
read_step "A, vừa đặt U.S."
chrome 'set active tab index of front window to 2'; sleep 1
read_step "B, lần đầu vào (chưa đặt)"
cycle_to "$DAU" || exit 1
read_step "B, vừa đặt Dấu"

log_step "Chuyển qua lại $ROUNDS vòng"
for r in {1..$ROUNDS}; do
  chrome 'set active tab index of front window to 1'
  read_step "vòng $r: về A"
  chrome 'set active tab index of front window to 2'
  read_step "vòng $r: về B"
done

log_step "Tab A mở trang khác trong cùng tab"
chrome 'set active tab index of front window to 1'; sleep 1
chrome "set URL of active tab of front window to \"file://$OUT/tabA2.html\""
sleep 2
read_step "A, sau khi mở trang khác"

log_step "Mở tab mới khi đang ở U.S. (tab A)"
chrome "make new tab at end of tabs of front window with properties {URL:\"file://$OUT/tabC.html\"}"
sleep 2
read_step "C, tab mới mở từ tab A"

log_ok "Bảng: $TABLE"
cat "$TABLE"
exit $ERR
