#!/bin/zsh
# Types the cells of docs/research/TerminalAndUnderline.md (sections 1–3) in Sublime Text, Ghostty, xterm.js, Terminal.app, the terminal and editor of VS Code and text fields, with Dấu and Apple's Vietnamese Telex as the control.
# Side effects: builds, takes the screen, changes input source, changes user settings
#
# Usage: scripts/research/terminal-underline/run.sh [--delay MS] [CELL]...
#   --delay MS   pause between keys (default 120, close to normal typing)
#   CELL         ids or patterns (t4-*, t5-*, t6-*) from the table below (default: all, in table order)
#
# Each cell is one call of scripts/selftest/typing/run.sh (its safety rules apply: keys
# only while the app's test window is in front; input source, clipboard and the Debug
# defaults keys put back at the end). Needs the Debug input method for underline and the
# perf log (scripts/dev/install-app.sh --debug); Dấu and Apple's Telex must be enabled
# already (N4). xterm cells load xterm.js from jsDelivr (network). The text of each cell,
# raw bytes or xterm.js data, pictures, the perf/diag log and the full output go to
# build/terminal-underline/<time>/<cell>/, a table of all cells to summary.md there.
# Exit status: 0 when every cell gave the expected text; 1 when a cell gave other text or
# had no result (the run goes on); 3 the run stopped at a cell on a failed check before
# typing (typing/run.sh, code 3).
# "expect" is correct Vietnamese typing (Telex rules, D4, D20, D26, D32), not the
# predicted result.
set -uo pipefail
ROOT="${0:A:h:h:h:h}"
source "$ROOT/scripts/lib/log.sh"

APPLE_TELEX=com.apple.inputmethod.VietnameseIM.VietnameseTelex
TYPING="$ROOT/scripts/selftest/typing/run.sh"
DELAY=120

# id | app | source (dau, apple) | mode | keys | expect [| keys2 | expect2]
# Mode: words joined by "+": inplace; underline (--underline); shot (--shot: picture of
# the window right after the keys, before the last word is committed); busy (--busy
# 300:1000: the test page blocks its main thread 300 ms of every second, M6); fast (30 ms
# between keys instead of --delay).
# Keys: ⌫ Delete, ← left arrow, ↩ Return (typing/run.sh).
# First round (11/11/2026): Sublime holds the three edits of an already typed word: change
# the mark (D26), ⌫ back into a committed word then add a mark (D20), move left into a
# word then add a mark (D20). Ghostty cells start at an empty line, as right after Return;
# the underline cell ends with Return.
# Second and third rounds (11/11/2026, t2- and t3- cells): Debug trials that D43 replaced
# (DEL erase in the key, after the key, a document length probe); they ran builds 13d4df7
# and 237e68f, results in the log of docs/Progress.md. Their cells went with the trials.
# Fourth round (t4-): D43 as built. The terminals (Ghostty with zsh and vim, xterm.js)
# must be told apart and come out right from the word where they are; the text fields
# (Chrome, also with a busy page; Safari; Sublime Text) must never be taken for one
# (typing/run.sh reports "D43: …" for each cell). One line covers D32 (hoaf ⌫), D4
# (windows), a word whose first replacement comes late (nguwowif) and short ones.
# Fifth round (t5-): D43 in terminals of Electron apps, and the move from a terminal to an
# editor in the same window (docs/research/TerminalAndUnderline.md, section 2, "Chuyển ô
# trong cùng view"). Terminal.app at 120 and 30 ms; VS Code's integrated terminal
# (vscodeterm: xterm.js in Electron, also with a Return in the line); vscodeswitch types in
# the terminal, then moves the focus to an empty editor of the same window and types there
# (the 7th and 8th fields: keys and expected text of the editor); t5-vsterm-apple is the
# control of t5-vsterm with Apple's Telex; t5-ghostty is the Ghostty cell with the same sentence
# (no ↩: Return ends the line of the Ghostty cell). Roughly 9 to 11 minutes for the six cells
# (VS Code opens a window and a terminal for each of the three: about 2 minutes each; the
# others about 1 minute).
# The sentence is Vietnamese with a meaning: "tôi dùng windows để hò hát với bạn", then, after a
# Return, "đường đẹp vui vẻ". Keys checked one by one against the answer (Telex, D4, D32):
# tooi→tôi (oo); dungf→dùng (tone f); windows→windows (D4, restored); ddeer→để (dd, ee, hỏi r);
# hoaf⌫→hò (⌫ in the middle of a word that took a tone, D32); hats→hát; vowis→với (ow→ơ, sắc s on
# ơ); banj→bạn; ↩; dduwowngf→đường (dd, uw→ư, ow→ơ, huyền f); ddepj→đẹp; vui; ver→vẻ. The
# editor line of t5-vsswitch: hoom→hôm, nay, dduwowngf→đường, ddepj→đẹp, vui, ver→vẻ.
# "expect" is the text the keys mean in Vietnamese, with ↩ shown as in the line of the
# cell (typing/run.sh). For t5-vsterm it is not the prediction: D43 as built sends no DEL
# to a field told apart as xterm.js, so the replacements double, as before D43; the cell
# measures whether that is what the VS Code terminal gives. The line of the cell is the
# verdict (what a zsh prompt shows); the raw bytes and the log's `event=range-ignored mode=`
# line are what to read next to it.
# Sixth round (t6-): underline (D13) in VS Code, for the choice between D13 as it is (the
# user turns underline on for the app) and underline only in xterm.js fields. Same keys as
# t5-vsterm and t5-vsswitch; --underline forces it for the whole app, so the editor of
# t6-vsswitch-ul is underlined too and shows what a user who turns it on for VS Code gets.
# The control (Apple's Telex in the same terminal) is t5-vsterm-apple, already measured.
# About 4 to 5 minutes for the two cells.
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
  "t4-gh|ghostty|dau|inplace|toois vieetj ddi hocj nhaf nguwowif hoaf⌫ windows |tối việt đi học nhà người hò windows "
  "t4-ghv|ghosttyvim|dau|inplace|toois vieetj ddi hocj nhaf nguwowif hoaf⌫ windows |tối việt đi học nhà người hò windows "
  "t4-gh-fast|ghostty|dau|inplace+fast|toois vieetj ddi hocj nhaf nguwowif hoaf⌫ windows |tối việt đi học nhà người hò windows "
  "t4-xt|xterm|dau|inplace|toois vieetj ddi hocj nhaf nguwowif hoaf⌫ windows |tối việt đi học nhà người hò windows "
  "t4-chrome|chrome|dau|inplace|toois vieetj ddi hocj nhaf nguwowif hoaf⌫ windows |tối việt đi học nhà người hò windows "
  "t4-chrome-busy|chrome|dau|inplace+busy|toois vieetj ddi hocj nhaf nguwowif hoaf⌫ windows |tối việt đi học nhà người hò windows "
  "t4-safari|safari|dau|inplace|toois vieetj ddi hocj nhaf nguwowif hoaf⌫ windows |tối việt đi học nhà người hò windows "
  "t4-sublime|sublime|dau|inplace|toois vieetj ddi hocj nhaf nguwowif hoaf⌫ windows |tối việt đi học nhà người hò windows "
  "t5-term120|terminal|dau|inplace|tooi dungf windows ddeer hoaf⌫ hats vowis banj |tôi dùng windows để hò hát với bạn "
  "t5-term30|terminal|dau|inplace+fast|tooi dungf windows ddeer hoaf⌫ hats vowis banj |tôi dùng windows để hò hát với bạn "
  "t5-ghostty|ghostty|dau|inplace|tooi dungf windows ddeer hoaf⌫ hats vowis banj |tôi dùng windows để hò hát với bạn "
  "t5-vsterm|vscodeterm|dau|inplace|tooi dungf windows ddeer hoaf⌫ hats vowis banj ↩dduwowngf ddepj vui ver |tôi dùng windows để hò hát với bạn ↩đường đẹp vui vẻ "
  "t5-vsswitch|vscodeswitch|dau|inplace|tooi dungf windows ddeer hoaf⌫ hats vowis banj ↩|tôi dùng windows để hò hát với bạn ↩|hoom nay dduwowngf ddepj vui ver |hôm nay đường đẹp vui vẻ "
  "t5-vsterm-apple|vscodeterm|apple|inplace|tooi dungf windows ddeer hoaf⌫ hats vowis banj ↩dduwowngf ddepj vui ver |tôi dùng windows để hò hát với bạn ↩đường đẹp vui vẻ "
  "t6-vsterm-ul|vscodeterm|dau|underline|tooi dungf windows ddeer hoaf⌫ hats vowis banj ↩dduwowngf ddepj vui ver |tôi dùng windows để hò hát với bạn ↩đường đẹp vui vẻ "
  "t6-vsswitch-ul|vscodeswitch|dau|underline|tooi dungf windows ddeer hoaf⌫ hats vowis banj ↩|tôi dùng windows để hò hát với bạn ↩|hoom nay dduwowngf ddepj vui ver |hôm nay đường đẹp vui vẻ "
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
wanted() { # id
  (( $#WANT == 0 )) && return 0
  local w
  for w in $WANT; do [[ $1 == ${~w} ]] && return 0; done
  return 1
}
for w in $WANT; do
  n=0
  for i in $ids; do [[ $i == ${~w} ]] && n=$(( n + 1 )); done
  (( n > 0 )) || log_die 2 "Không có ô \"$w\""
done

OUT="$ROOT/build/terminal-underline/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUT"
{
  print "| ô | phím | mong đợi | được | byte gửi cho shell | D43 | phím 2 (soạn thảo) | mong đợi 2 | được 2 (␡ = U+007F) | mã thoát |"
  print "|---|---|---|---|---|---|---|---|---|---|"
} > "$OUT/summary.md"

FAILED=0
for cell in $CELLS; do
  parts=("${(@s:|:)cell}")
  id=$parts[1] app=$parts[2] src=$parts[3] mode=$parts[4] keys=$parts[5] expect=$parts[6] keys2=${parts[7]:-} expect2=${parts[8]:-}
  wanted "$id" || continue
  dir="$OUT/$id"; mkdir -p "$dir"
  args=(--delay "$DELAY" --keys "$keys" --expect "$expect" --save "$dir")
  [[ -n $keys2 ]] && args+=(--keys2 "$keys2" --expect2 "$expect2")
  [[ $src == apple ]] && args+=(--source "$APPLE_TELEX")
  for m in ${(s:+:)mode}; do
    case $m in
      inplace) ;;
      underline) args+=(--underline) ;;
      shot) args+=(--shot) ;;
      busy) args+=(--busy 300:1000) ;;
      fast) args[2]=30 ;;
      *) log_die 2 "Ô $id: chế độ lạ \"$m\"" ;;
    esac
  done
  log_step "Ô $id: $app, $src, $mode, phím \"$keys\""
  rc=0
  "$TYPING" $args "$app" > "$dir/typing.log" 2>&1 || rc=$?
  got="$(cat "$dir/$app.txt" 2>/dev/null)"
  raw=""
  if [[ -e "$dir/$app.raw" ]]; then
    # "byte Ghostty gửi xuống terminal: …" or "byte xterm.js gửi xuống terminal: …" (VS Code).
    raw="$(grep -oE 'byte [^ ]+ gửi xuống terminal: .*' "$dir/typing.log" | sed -E 's/^byte [^ ]+ gửi xuống terminal: //')"
  elif [[ -e "$dir/xterm.data" ]]; then
    raw="\"$(<"$dir/xterm.data")\""
  fi
  d43="$(grep -o 'D43: .*' "$dir/typing.log" | head -1 | sed 's/^D43: //')"
  # vscodeswitch: the editor's text, U+007F as ␡.
  got2=""; k2col=""; [[ -n $keys2 ]] && k2col="\`$keys2\`"
  if [[ -e "$dir/$app.editor.txt" ]]; then
    got2="$(<"$dir/$app.editor.txt")"; got2="${got2//$'\x7f'/␡}"
  fi
  print -r -- "| $id | \`$keys\` | $expect | ${got:-—} | ${raw:-—} | ${d43:-—} | ${k2col:-—} | ${expect2:-—} | ${got2:-—} | $rc |" >> "$OUT/summary.md"
  case $rc in
    0) log_ok "$id: \"$got\"" ;;
    1) log_warn "$id: \"$got\" (mong đợi \"$expect\")" ;;
    3) tail -5 "$dir/typing.log" >&2; log_error "Dừng ở ô $id: kiểm tra trước khi gõ không đạt (mã 3, lý do ở dòng trên)"; FAILED=3; break ;;
    *) tail -5 "$dir/typing.log" >&2; log_error "Ô $id không có kết quả (mã $rc), sang ô sau"; FAILED=1 ;;
  esac
  grep -h 'Không thấy' "$dir/typing.log" | sed "s/^/$id: /" >&2
done

cat "$OUT/summary.md"
log_detail "kết quả: $OUT"
(( FAILED == 0 )) && log_done
exit $FAILED
