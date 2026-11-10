#!/bin/zsh
# Types the cells of docs/research/TERMINAL-AND-UNDERLINE.md (section 6) in Sublime Text and Ghostty, with Dấu and with Apple's Vietnamese Telex as the control.
# Side effects: builds, takes the screen, changes input source, changes user settings
#
# Usage: scripts/research/terminal-underline/run.sh [--delay MS] [CELL]...
#   --delay MS   pause between keys (default 120, close to normal typing)
#   CELL         ids from the table below to run (default: all, in table order)
#
# Each cell is one call of scripts/selftest/typing/run.sh (its safety rules apply: keys
# only while the app's test window is in front; input source, clipboard and the Debug
# defaults keys put back at the end). Needs the Debug input method for --underline
# (scripts/dev/install-app.sh --debug); Dấu and Apple's Telex must be enabled already
# (N4). The text of each cell, Ghostty's raw bytes, the perf/diag log and the full output
# go to build/terminal-underline/<time>/<cell>/, a table of all cells to summary.md there.
# "expect" is correct Vietnamese typing (Telex rules, D20, D26), not the predicted result.
set -uo pipefail
ROOT="${0:A:h:h:h:h}"
source "$ROOT/scripts/lib/log.sh"

APPLE_TELEX=com.apple.inputmethod.VietnameseIM.VietnameseTelex
TYPING="$ROOT/scripts/selftest/typing/run.sh"
DELAY=120

# id | app | source (dau, apple) | mode (inplace, underline) | keys | expect
# Keys: ⌫ Delete, ← left arrow, ↩ Return (typing/run.sh). Sublime: one cell holds the three
# edits of an already typed word: change the mark (D26), ⌫ back into a committed word then
# add a mark (D20), move left into a word then add a mark (D20). Ghostty: each cell starts
# at an empty line, as right after Return; the underline cell ends with Return.
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
for w in $WANT; do
  (( ${CELLS[(I)${(b)w}\|*]} )) || log_die 2 "Không có ô \"$w\""
done

OUT="$ROOT/build/terminal-underline/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUT"
{
  print "| ô | phím | mong đợi | được | byte Ghostty gửi | mã thoát |"
  print "|---|---|---|---|---|---|"
} > "$OUT/summary.md"

FAILED=0
for cell in $CELLS; do
  parts=("${(@s:|:)cell}")
  id=$parts[1] app=$parts[2] src=$parts[3] mode=$parts[4] keys=$parts[5] expect=$parts[6]
  (( $#WANT == 0 || ${WANT[(Ie)$id]} )) || continue
  dir="$OUT/$id"; mkdir -p "$dir"
  args=(--delay "$DELAY" --keys "$keys" --expect "$expect" --save "$dir")
  [[ $src == apple ]] && args+=(--source "$APPLE_TELEX")
  [[ $mode == underline ]] && args+=(--underline)
  log_step "Ô $id: $app, $src, $mode, phím \"$keys\""
  rc=0
  "$TYPING" $args "$app" > "$dir/typing.log" 2>&1 || rc=$?
  got="$(cat "$dir/$app.txt" 2>/dev/null)"
  raw=""
  [[ -e "$dir/ghostty.raw" ]] && raw="$(grep -o 'byte Ghostty gửi xuống terminal: .*' "$dir/typing.log" | sed 's/^byte Ghostty gửi xuống terminal: //')"
  print -r -- "| $id | \`$keys\` | $expect | ${got:-—} | ${raw:-—} | $rc |" >> "$OUT/summary.md"
  case $rc in
    0) log_ok "$id: \"$got\"" ;;
    1) log_warn "$id: \"$got\" (mong đợi \"$expect\")" ;;
    3) tail -5 "$dir/typing.log" >&2; log_error "Dừng ở ô $id: app khác ra trước (mã 3)"; FAILED=3; break ;;
    *) tail -5 "$dir/typing.log" >&2; log_error "Ô $id không có kết quả (mã $rc), sang ô sau"; FAILED=1 ;;
  esac
  [[ $mode == underline && "$(cat "$dir/typing.log")" != *underline-on* ]] && log_warn "$id: không thấy underline-on"
done

cat "$OUT/summary.md"
log_detail "kết quả: $OUT"
(( FAILED == 0 )) && log_done
exit $FAILED
