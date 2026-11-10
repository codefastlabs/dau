#!/bin/zsh
# Types the cells of docs/research/TERMINAL-AND-UNDERLINE.md (section 6) in Sublime Text, Ghostty and xterm.js, with Dấu, its Debug trials and Apple's Vietnamese Telex as the control.
# Side effects: builds, takes the screen, changes input source, changes user settings
#
# Usage: scripts/research/terminal-underline/run.sh [--delay MS] [CELL]...
#   --delay MS   pause between keys (default 120, close to normal typing)
#   CELL         ids or patterns (t2-*) from the table below (default: all, in table order)
#
# Each cell is one call of scripts/selftest/typing/run.sh (its safety rules apply: keys
# only while the app's test window is in front; input source, clipboard and the Debug
# defaults keys put back at the end). Needs the Debug input method for underline and the
# trials (scripts/dev/install-app.sh --debug); Dấu and Apple's Telex must be enabled
# already (N4). xterm cells load xterm.js from jsDelivr (network). The text of each cell,
# raw bytes or xterm.js data, pictures, the perf/diag log and the full output go to
# build/terminal-underline/<time>/<cell>/, a table of all cells to summary.md there.
# "expect" is correct Vietnamese typing (Telex rules, D4, D20, D26, D32), not the
# predicted result.
set -uo pipefail
ROOT="${0:A:h:h:h:h}"
source "$ROOT/scripts/lib/log.sh"

APPLE_TELEX=com.apple.inputmethod.VietnameseIM.VietnameseTelex
TYPING="$ROOT/scripts/selftest/typing/run.sh"
DELAY=120

# id | app | source (dau, apple) | mode | keys | expect
# Mode: words joined by "+": inplace; underline (--underline); erase (--erase: Debug trial,
# DEL characters plus the new text in one insertText); plain (--underline --plain-marked:
# marked text with no underline attribute); shot (--shot: picture of the window right
# after the keys, before the last word is committed).
# Keys: ⌫ Delete, ← left arrow, ↩ Return (typing/run.sh).
# First round (11/11/2026): Sublime holds the three edits of an already typed word: change
# the mark (D26), ⌫ back into a committed word then add a mark (D20), move left into a
# word then add a mark (D20). Ghostty cells start at an empty line, as right after Return;
# the underline cell ends with Return.
# Second round (t2-): the erase trial in Ghostty (zsh line editor, vim insert mode) and in
# xterm.js (the terminal of the Claude desktop app, rebuilt in Chrome), the current
# behaviour and Apple's Telex in xterm.js, and pictures of marked text with and without
# the underline attribute. The mixed line covers D32 (hoaf ⌫) and D4 (windows).
CELLS=(
  "sub-dau|sublime|dau|inplace|tooisf ba ⌫j tooi←s|tồi bạ tối"
  "sub-dau-ul|sublime|dau|underline|tooisf ba ⌫j tooi←s|tồi bạ tối"
  "sub-apple|sublime|apple|inplace|tooisf ba ⌫j tooi←s|tồi bạ tối"
  "gh-dau-dd|ghostty|dau|inplace|dd|đ"
  "gh-dau-toois|ghostty|dau|inplace|toois|tối"
  "gh-dau-vieetj|ghostty|dau|inplace|vieetj|việt"
  "gh-dau-ul-ret|ghostty|dau|underline|toois vieetj↩|tối việt"
  "gh-apple-dd|ghostty|apple|inplace|dd|đ"
  "gh-apple-toois|ghostty|apple|inplace|toois|tối"
  "gh-apple-vieetj|ghostty|apple|inplace|vieetj|việt"
  "gh-apple-ret|ghostty|apple|inplace|toois vieetj↩|tối việt"
  "t2-gh-erase-dd|ghostty|dau|erase|dd|đ"
  "t2-gh-erase-toois|ghostty|dau|erase|toois|tối"
  "t2-gh-erase-vieetj|ghostty|dau|erase|vieetj|việt"
  "t2-gh-erase-mix|ghostty|dau|erase|toois vieetj ddi hoaf⌫ windows |tối việt đi hò windows "
  "t2-ghv-erase-mix|ghosttyvim|dau|erase|toois vieetj ddi hoaf⌫ windows |tối việt đi hò windows "
  "t2-gh-ul-shot|ghostty|dau|underline+shot|toois vieet|tối viêt"
  "t2-gh-plain-shot|ghostty|dau|plain+shot|toois vieet|tối viêt"
  "t2-xt-dau|xterm|dau|inplace|toois vieetj dd |tối việt đ "
  "t2-xt-erase|xterm|dau|erase|toois vieetj dd |tối việt đ "
  "t2-xt-ul|xterm|dau|underline|toois vieetj dd |tối việt đ "
  "t2-xt-apple|xterm|apple|inplace|toois vieetj dd |tối việt đ "
  "t2-xt-ul-shot|xterm|dau|underline+shot|toois vieet|tối viêt"
  "t2-xt-plain-shot|xterm|dau|plain+shot|toois vieet|tối viêt"
)

WANT=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --delay) DELAY="${2:?--delay cần số ms}"; shift 2 ;;
    -h|--help) log_usage "${0:A}"; exit 0 ;;
    -*) log_die 2 "Tham số không hợp lệ: $1" ;;
    *) WANT+=("$1"); shift ;;
  esac
done
ids=(${CELLS%%|*})
for w in $WANT; do
  (( ${#${(M)ids:#${~w}}} )) || log_die 2 "Không có ô \"$w\""
done
wanted() { # id
  (( $#WANT == 0 )) && return 0
  local w
  for w in $WANT; do [[ $1 == ${~w} ]] && return 0; done
  return 1
}

OUT="$ROOT/build/terminal-underline/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUT"
{
  print "| ô | phím | mong đợi | được | byte gửi cho shell | mã thoát |"
  print "|---|---|---|---|---|---|"
} > "$OUT/summary.md"

FAILED=0
for cell in $CELLS; do
  parts=("${(@s:|:)cell}")
  id=$parts[1] app=$parts[2] src=$parts[3] mode=$parts[4] keys=$parts[5] expect=$parts[6]
  wanted "$id" || continue
  dir="$OUT/$id"; mkdir -p "$dir"
  args=(--delay "$DELAY" --keys "$keys" --expect "$expect" --save "$dir")
  [[ $src == apple ]] && args+=(--source "$APPLE_TELEX")
  for m in ${(s:+:)mode}; do
    case $m in
      inplace) ;;
      underline) args+=(--underline) ;;
      erase) args+=(--erase) ;;
      plain) args+=(--underline --plain-marked) ;;
      shot) args+=(--shot) ;;
      *) log_die 2 "Ô $id: chế độ lạ \"$m\"" ;;
    esac
  done
  log_step "Ô $id: $app, $src, $mode, phím \"$keys\""
  rc=0
  "$TYPING" $args "$app" > "$dir/typing.log" 2>&1 || rc=$?
  got="$(cat "$dir/$app.txt" 2>/dev/null)"
  raw=""
  if [[ -e "$dir/$app.raw" ]]; then
    raw="$(grep -o 'byte Ghostty gửi xuống terminal: .*' "$dir/typing.log" | sed 's/^byte Ghostty gửi xuống terminal: //')"
  elif [[ -e "$dir/xterm.data" ]]; then
    raw="\"$(<"$dir/xterm.data")\""
  fi
  print -r -- "| $id | \`$keys\` | $expect | ${got:-—} | ${raw:-—} | $rc |" >> "$OUT/summary.md"
  case $rc in
    0) log_ok "$id: \"$got\"" ;;
    1) log_warn "$id: \"$got\" (mong đợi \"$expect\")" ;;
    3) tail -5 "$dir/typing.log" >&2; log_error "Dừng ở ô $id: app khác ra trước (mã 3)"; FAILED=3; break ;;
    *) tail -5 "$dir/typing.log" >&2; log_error "Ô $id không có kết quả (mã $rc), sang ô sau"; FAILED=1 ;;
  esac
  grep -h 'Không thấy' "$dir/typing.log" | sed "s/^/$id: /" >&2
done

cat "$OUT/summary.md"
log_detail "kết quả: $OUT"
(( FAILED == 0 )) && log_done
exit $FAILED
