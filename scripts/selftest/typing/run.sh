#!/bin/zsh
# Types a sentence into real apps with the Dấu input method and checks the text.
# Side effects: builds, takes the screen, changes input source, changes user settings
# Needs the Accessibility permission for the process running the script
# (System Events keystrokes); the input method must be installed (Debug for the per-key
# timings: a Release build types the same but logs nothing per key, D8), the Dấu input
# source enabled (scripts/dev/install-app.sh, with --debug for a Debug build; the first
# time, "Bật Dấu" in Dấu.app), and the apps installed. Terminal and Ghostty are driven
# through AppleScript too, and Notes for deleting its test note: the Automation
# permission for each, asked by macOS once.
#
# Usage:
#   scripts/selftest/typing/run.sh [options] <app>...
#     app:  safari | chrome | vscode | terminal | edge | firefox | notes | mail | cursor
#           | cursoragents (the prompt box of Cursor's agents window) | vscodefile (VS Code
#           opened on a file, as cursor is) | sublime (Sublime Text) | ghostty (Ghostty)
#           | ghosttyvim (vim in insert mode in a Ghostty window) | xterm (xterm.js in a
#           Chrome page: the terminal of Electron apps such as the Claude desktop app)
#           | tiptap (a TipTap/ProseMirror editor in a Chrome page: the message box of the
#           Claude desktop app and of claude.ai)
#           | all (= the first four)
#     No TextEdit: it autosaves every new document to iCloud Drive, closed or not
#     (docs/Troubleshooting.md); Safari's test page is the AppKit/WebKit reference.
#   --delay MS        pause between keys in ms (default 30). 0 sends the whole string in
#                     one System Events keystroke (about 1 ms per key): a stress test that
#                     Chrome, VS Code and Terminal failed with it
#                     (measured before M6, docs/Compatibility.md 6.2);
#                     120 is close to normal typing.
#   --keys "…"        keys to type (default: the sample sentence below). Four marks are
#                     not typed as characters: ⌫ sends the Delete key; ← the left arrow
#                     key; ↩ the Return key (ghostty and the xterm page only: Return ends
#                     the line, nothing runs; any other app is an error); ⇄ switches the
#                     input source to U.S. (com.apple.keylayout.US, must be enabled) and
#                     back to Dấu with TISSelectInputSource from this script's process,
#                     which IMK does not report to the input method as a deactivation
#                     (docs/Architecture.md, "Đổi nguồn nhập liệu không qua
#                     `activateServer`"). Example (D20): --keys "hoc ⌫j " --expect "học "
#   --expect "…"      expected text (default: what the sample sentence must give). With --keys
#                     and no --expect there is no answer: the text read back is printed, with no
#                     verdict (neither ✓ nor ✗), and the exit status is 0 unless the run stopped.
#   --source ID       type with this input source instead of Dấu (an enabled one, such as
#                     com.apple.inputmethod.VietnameseIM.VietnameseTelex); used by
#                     scripts/research/compare-ims/run.sh. Dấu must still be installed;
#                     the verdict still compares with --expect. Text that comes back as the
#                     keys typed means the source did not take: an invalid cell (status 4).
#                     The source wanted (this one, or Dấu) is switched to only when it is
#                     not the current one, with macOS's own "Select next source in Input
#                     menu" shortcut, and switched back the same way at the end.
#   --keep-source     leave the input source as it is at the end instead of switching
#                     back: for a caller that runs several calls in a row with the same
#                     source and puts the first one back itself (load/heavy.sh), so the
#                     source is switched once per source, not twice per call.
#   --word-pause MS   an extra pause of MS ms after each space, on top of --delay and
#                     --jitter: people type a word in one burst and stop between words.
#                     Example close to everyday typing: --delay 80 --jitter 30 --word-pause 250
#   --jitter MS       each pause is --delay plus a random whole number of ms between -MS
#                     and +MS (never below 0), drawn per key: closer to a human than an
#                     even pace. With --delay 0 the keys still go one by one.
#   --busy MS:PERIOD  browsers only (safari chrome edge firefox; any other app is an
#                     error): the local test page runs a JavaScript loop that blocks the
#                     page's main thread for MS ms every PERIOD ms (MS < PERIOD), from when
#                     the page loads until its tab closes. The app stays responsive to the
#                     window server; only the page (the renderer, which applies the text) is
#                     late. The clean "busy app" condition of M6.
#   --save DIR        also write, per app, to DIR: <app>.txt (the text read back);
#                     <app>.perf.log (the input method's perf and diag log, ReplaceDiag:
#                     positions of each replacement, from the start of that app's run;
#                     `log show --style compact`, numbers and bundle IDs only, D8; lines
#                     of other apps too, if any typed meanwhile), for
#                     `scripts/perf/perf-report.sh --input`. Also: ghostty and ghosttyvim:
#                     <app>.raw (the raw bytes Ghostty sent to the terminal); xterm:
#                     xterm.data (the onData chunks); tiptap: tiptap.events (the
#                     beforeinput events); with --shot: <app>.png.
#   --underline       force underline mode (D13: marked text, committed at the word end)
#                     for each app tested, without touching the user's Dấu settings.
#                     Debug input method only: the script writes the bundle ID into the
#                     global defaults key DauDebugForceUnderline (`defaults write -g`,
#                     the only domain both a shell can write and the sandboxed input
#                     method can read) before the app runs, and deletes the key at exit.
#                     The input method reads it at activation; the report shows
#                     `underline-on` when it took effect. By hand:
#                       defaults write -g DauDebugForceUnderline -array com.google.Chrome
#                       defaults delete -g DauDebugForceUnderline
#   --shot            with --save: a picture of the app's window right after the keys, before
#                     the last word is committed (ghostty, ghosttyvim, xterm), to DIR/<app>.png.
#
# For each app: opens a new, empty window, selects the Dấu input source (which must be
# enabled already; nothing is enabled or disabled, N4), types, reads the text back,
# closes the window without saving, prints the text, a ✓/✗ verdict and the input method's
# counts and timings for that app (scripts/perf/perf-report.sh; the script sets the global
# defaults key DauPerfLog for the run and at exit puts back what was there: the same value
# and type, or deletes the key if it was absent, D8). The input source selected
# before and the clipboard (read through ⌘C in browsers, editors, Notes, Mail) are
# restored; the clipboard is emptied before each ⌘C so a failed copy cannot pass. A new
# document whose first letter the app capitalized by itself counts as a pass (noted).
#
# Edge, Firefox: the same local test page as Safari/Chrome, closed with ⌘W.
# Notes: a new note (⌘N) in the folder shown; it syncs while it exists. The script
# empties it and deletes it through Notes' AppleScript (to Recently Deleted).
# Mail: a new message (⌘N), keys go to the body focused through Accessibility, the To
# field stays empty, Send is never pressed; the body is emptied and the window closed
# with "Don't Save". Apps launched by the script stay running.
#
# Terminal: the keys go to the shell prompt of a new window. The script never presses
# Return; it clears the line with ⌃U before closing the window. Keys must not contain
# a newline.
#
# Sublime Text: `subl -n` opens an empty file of this run in a new window; read with ⌘A ⌘C
# (nothing is saved: an unregistered copy may ask to buy a license on save); before the
# close the buffer is reverted to the empty file on disk (`subl --command revert`), so it is
# clean and ⌘W closes the tab without any save prompt (no dialog, no button label to match);
# Sublime closes the window once its last tab is closed (close_windows_when_empty, on by
# default on macOS). Other windows are not touched.
#
# Ghostty: a new window (Ghostty's AppleScript `new window`, which needs the Automation
# permission for Ghostty once) runs a line editor of its own instead of a shell; the keys
# go there, ⌃D ends the line and the window closes by itself. Two results: the line as
# zsh's line editor ends up with it (the verdict, what a zsh prompt shows), and the raw
# bytes Ghostty wrote to the terminal (printed with ⌫ for DEL, also in DIR/ghostty.raw
# with --save). Details at run_ghostty. A Ghostty launched by the script opens no window
# of its own (--initial-window=false).
#
# Safety: keys and shortcuts (⌘A ⌘C ⌘W ⌃U ⌃D) are only sent while the app under test is
# frontmost (browsers: with the test page in front and the keyboard focus in its text
# field; VS Code: an Untitled editor; Mail: the New Message window; Sublime Text, Ghostty:
# the window titled dau-selftest). If a check fails (another app in front, the focus
# outside the test field, another window, a Cursor Agents box that is not empty, the
# typing command failing), the script stops sending keys and exits with status 3, also
# when that happens during the last app. The last message names the check that failed.
#
# After selecting the Dấu input source the script checks that Dấu is the current source
# (TIS is trusted for the current source only); if not, it stops and exits with status 4.
# The "Dấu is enabled" check is cross-checked against com.apple.inputsources ›
# AppleEnabledThirdPartyInputSources (input-source.swift).
#
# Exit status: 0 if every app gives the expected text (or, with --keys and no --expect,
# the run finished: no verdict); 1 if an app gave other text; 3 the run stopped on a failed
# front/focus/window check; 4 it stopped on the input source (not selected, or without
# effect in the field). Per-key timings are reported only for Dấu, and only when the
# installed input method is a Debug build (a Release one prints a line saying so); D43
# lines only for Dấu. Messages: Vietnamese, through
# scripts/lib/log.sh (the per-app text and verdict go to stdout, stops and warnings to stderr).
set -uo pipefail

SELF="${0:A}"   # $0 inside a function is the function name in zsh
ROOT="${SELF:h:h:h:h}"
source "$ROOT/scripts/lib/log.sh"
source "$ROOT/scripts/lib/wait.sh"
source "$ROOT/scripts/lib/bundle-config.sh"
HERE="$ROOT/scripts/selftest/typing"
source "$ROOT/scripts/lib/xcode.sh"
source "$ROOT/scripts/lib/swift-tool.sh"
dau_developer_dir
LOG=/usr/bin/log

# "carr" comes first: after Vietnamese text, macOS 27.2 autocorrect turns a typed "car"
# into "cả" (D4, known limit), which would hide what Dấu did.
KEYS='windows carr tooi yeeu tieengs Vieetj, Sunrise '
EXPECT='windows car tôi yêu tiếng Việt, Sunrise '
KEYS_GIVEN=0
EXPECT_GIVEN=0
DELAY_MS=30
UNDERLINE=0
SHOT=0
SOURCE_ID=""
SAVE_DIR=""
KEEP_SOURCE=0
JITTER_MS=0
WORD_PAUSE_MS=0
BUSY=""
FORCE_KEY=DauDebugForceUnderline
APPS=()
# Prints the whole leading comment block.
usage() { log_usage "$SELF"; }
while [[ $# -gt 0 ]]; do
  case "$1" in
    --delay) DELAY_MS="${2:?--delay cần số ms}"; shift 2 ;;
    --keys) KEYS="${2?}"; KEYS_GIVEN=1; shift 2 ;;
    --expect) EXPECT="${2?}"; EXPECT_GIVEN=1; shift 2 ;;
    --underline) UNDERLINE=1; shift ;;
    --shot) SHOT=1; shift ;;
    --source) SOURCE_ID="${2:?--source cần ID nguồn}"; shift 2 ;;
    --save) SAVE_DIR="${2:?--save cần thư mục}"; shift 2 ;;
    --keep-source) KEEP_SOURCE=1; shift ;;
    --jitter) JITTER_MS="${2:?--jitter cần số ms}"; shift 2 ;;
    --word-pause) WORD_PAUSE_MS="${2:?--word-pause cần số ms}"; shift 2 ;;
    --busy) BUSY="${2:?--busy cần MS:PERIOD, ví dụ 300:1000}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    all) APPS+=(safari chrome vscode terminal); shift ;;
    safari|chrome|vscode|terminal|edge|firefox|notes|mail|cursor|cursoragents|vscodefile|sublime|ghostty|ghosttyvim|xterm|tiptap) APPS+=("$1"); shift ;;
    *) log_die 2 "Tham số không hợp lệ: $1" ;;
  esac
done
[[ ${#APPS[@]} -gt 0 ]] || { usage; exit 2; }
(( SHOT == 0 )) || [[ -n "$SAVE_DIR" ]] || log_die 2 "--shot cần --save DIR"
# Custom keys without --expect: the default sample's answer says nothing about them, so
# there is no answer to compare with (the text read back is printed, no verdict).
NO_ANSWER=0
(( KEYS_GIVEN && ! EXPECT_GIVEN )) && NO_ANSWER=1
[[ "$JITTER_MS" =~ ^[0-9]+$ ]] || log_die 2 "--jitter phải là số nguyên ms"
[[ "$WORD_PAUSE_MS" =~ ^[0-9]+$ ]] || log_die 2 "--word-pause phải là số nguyên ms"
# --save DIR need not exist yet (compare-ims and load/run.sh create theirs; a call by hand may not).
[[ -z "$SAVE_DIR" ]] || mkdir -p "$SAVE_DIR" || log_die "Không tạo được thư mục $SAVE_DIR"
BUSY_MS=0; BUSY_PERIOD=0
if [[ -n "$BUSY" ]]; then
  [[ "$BUSY" =~ ^[0-9]+:[0-9]+$ ]] || log_die 2 "--busy phải có dạng MS:PERIOD (số nguyên ms), ví dụ 300:1000"
  BUSY_MS=${BUSY%%:*}; BUSY_PERIOD=${BUSY##*:}
  (( BUSY_MS > 0 && BUSY_MS < BUSY_PERIOD )) || log_die 2 "--busy cần 0 < MS < PERIOD"
  for app in "${APPS[@]}"; do
    [[ $app == (safari|chrome|edge|firefox) ]] \
      || log_die 2 "--busy chỉ dùng với trình duyệt (safari chrome edge firefox), không với $app"
  done
fi
# A locked screen (or one asleep behind the lock, e.g. a run started from another device)
# keeps every app from coming to the front: nothing would be typed, and the test pages
# opened would be left behind. Refuse before opening anything.
if ioreg -n Root -d1 -a | grep -A1 CGSSessionScreenIsLocked | grep -q '<true/>'; then
  log_die "Màn hình Mac đang khoá: không mở app, không gõ. Mở khoá rồi chạy lại."
fi
US_SOURCE=com.apple.keylayout.US
if [[ "$KEYS" == *$'\n'*|| "$KEYS" == *$'\r'* ]]; then
  log_die 2 "Phím gõ không được có xuống dòng (không bao giờ nhấn Return trong Terminal)."
fi
if [[ "$KEYS" == *↩* ]]; then
  for app in "${APPS[@]}"; do
    [[ $app == ghostty || $app == xterm ]] || log_die 2 "↩ (Return) chỉ dùng với ghostty và xterm, không với $app"
  done
fi

# --- helpers -------------------------------------------------------------------------
INPUT_SOURCE="$(dau_swift_tool input-source "$ROOT/scripts/lib/input-source.swift")" || exit 1
CLIPBOARD="$(dau_swift_tool clipboard "$HERE/clipboard.swift")" || exit 1

IM_PLIST="$HOME/Library/Input Methods/DauInputMethod.app/Contents/Info.plist"
[[ -f "$IM_PLIST" ]] || log_die "Chưa cài bộ gõ: chạy scripts/dev/install-app.sh, rồi mở Dấu trong /Applications và bấm \"Bật Dấu\"."
IM_ID="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$IM_PLIST")"
# Debug or Release (scripts/lib/bundle-config.sh): only Debug logs per key (D8).
IM_CONFIG="$(bundle_config "${IM_PLIST:h:h}")"
DAU_SOURCE="$("$INPUT_SOURCE" enabled "$IM_ID" | grep '\.vi$' | head -1)"
# The helper cross-checks TIS with com.apple.inputsources and says on stderr when they
# disagree (TIS alone has been wrong on macOS 27.2).
[[ -n "$DAU_SOURCE" ]] || {
  log_error "Nguồn nhập liệu Dấu – Tiếng Việt chưa được bật (hoặc TIS và com.apple.inputsources không khớp, xem dòng trên)."
  log_hint "Mở Dấu trong /Applications rồi bấm \"Bật Dấu\" (không bật được: docs/Compatibility.md mục 4.1)."
  exit 1
}
if [[ -n "$SOURCE_ID" ]]; then
  # Another source in place of Dấu: it must be enabled already (nothing is enabled, N4).
  (( ${${(f)"$("$INPUT_SOURCE" enabled "$SOURCE_ID")"}[(Ie)$SOURCE_ID]} )) \
    || log_die "Nguồn $SOURCE_ID chưa được bật (script không tự bật, N4)."
  DAU_SOURCE="$SOURCE_ID"
fi
if [[ "$KEYS" == *"⇄"* ]] && (( ! ${${(f)"$("$INPUT_SOURCE" enabled "$US_SOURCE")"}[(Ie)$US_SOURCE]} )); then
  log_die "⇄ cần nguồn $US_SOURCE đã bật (script không tự bật, N4)."
fi

WORK="$(mktemp -d)"
# Written when the run must stop: "front" (another app came to the front) or "source"
# (the input source did not become the one selected).
STOP_FILE="$WORK/stop"
# The reason of the stop, in words, for the last message of the run: the check that failed.
STOP_REASON_FILE="$WORK/stop-reason"
stop_run() { # kind (front|source) reason
  echo "$1" > "$STOP_FILE"
  [[ -e "$STOP_REASON_FILE" ]] || print -r -- "$2" > "$STOP_REASON_FILE"
}
# ⇄: U.S., then back to Dấu, from this (unsandboxed) process. AppleScript's `do shell
# script` runs it with /bin/sh. Each select waits (3 s at most) until TIS reports the new
# source as current; if it never does, "source" goes into the stop file and the keys stop.
# The 0.3 s after that stays fixed: the input method learns of the switch through a
# notification this script cannot observe.
SWITCH_CMD="$(printf 'sw() { %q select "$1" >/dev/null || exit 1; i=0; while [ "$(%q current)" != "$1" ]; do i=$((i+1)); if [ $i -ge 30 ]; then echo source > %q; exit 1; fi; sleep 0.1; done; sleep 0.3; }; sw %q; sw %q' \
  "$INPUT_SOURCE" "$INPUT_SOURCE" "$STOP_FILE" "$US_SOURCE" "$DAU_SOURCE")"
ORIGINAL_SOURCE="$("$INPUT_SOURCE" current)"
"$CLIPBOARD" save "$WORK/clipboard.plist" || exit 1
# The per-key log is off unless DauPerfLog is set (D8); turn it on for this run only.
PERF_KEY=DauPerfLog
# Remember the key exactly: absent, or its type and value, so cleanup can put it back.
PERF_TYPE=""; PERF_VALUE=""
if PERF_TYPE="$(defaults read-type -g "$PERF_KEY" 2>/dev/null)"; then
  PERF_TYPE="${PERF_TYPE#Type is }"
  PERF_VALUE="$(defaults read -g "$PERF_KEY")"
  case "$PERF_TYPE" in
    boolean|integer|float|string) ;;
    *) log_error "$PERF_KEY có kiểu $PERF_TYPE: script không khôi phục được kiểu này."
       log_hint "Xoá hoặc đổi tay (defaults delete -g $PERF_KEY) rồi chạy lại."
       exit 1 ;;
  esac
else
  PERF_TYPE=""
fi
restore_perf_key() {
  case "$PERF_TYPE" in
    "") defaults delete -g "$PERF_KEY" >/dev/null 2>&1 ;;
    boolean) defaults write -g "$PERF_KEY" -bool "$([[ "$PERF_VALUE" == 1 ]] && echo true || echo false)" ;;
    integer) defaults write -g "$PERF_KEY" -int "$PERF_VALUE" ;;
    float) defaults write -g "$PERF_KEY" -float "$PERF_VALUE" ;;
    string) defaults write -g "$PERF_KEY" -string "$PERF_VALUE" ;;
  esac
}
defaults write -g "$PERF_KEY" -bool true
cleanup() {
  [[ $UNDERLINE == 1 ]] && defaults delete -g "$FORCE_KEY" >/dev/null 2>&1
  restore_perf_key
  "$CLIPBOARD" restore "$WORK/clipboard.plist" 2>/dev/null || log_warn "Không khôi phục được clipboard"
  if (( ! KEEP_SOURCE )) && [[ "$("$INPUT_SOURCE" current)" != "$ORIGINAL_SOURCE" ]]; then
    cycle_to_source "$ORIGINAL_SOURCE" || true
  fi
  rm -rf "$WORK"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

PAGE="$WORK/dau-selftest.html"
# The window title the guards look for; also the page's <title>.
PAGE_TITLE="Dấu self test"
# The title the page shows only while its text area has the keyboard focus (the page
# sets it). Keys and ⌘A ⌘C are sent only under this title: a window title alone does not
# say where the focus is, and keys sent while the address bar had it went into the
# address bar (and its read-back passed, since ⌘A ⌘C copied the same text from there).
FOCUS_TITLE="$PAGE_TITLE [focus]"
cat > "$PAGE" <<HTML
<!doctype html><meta charset="utf-8"><title>$PAGE_TITLE</title>
<textarea autofocus spellcheck="false" autocomplete="off" style="width:96vw;height:90vh"></textarea>
<script>
var t = document.querySelector("textarea");
function mark() {
  document.title = document.hasFocus() && document.activeElement === t ? "$FOCUS_TITLE" : "$PAGE_TITLE";
}
["focus", "blur"].forEach(function (e) { t.addEventListener(e, mark); window.addEventListener(e, mark); });
setInterval(mark, 200);
mark();
</script>
HTML
if (( BUSY_MS > 0 )); then
  # --busy: block the page's main thread for BUSY_MS of every BUSY_PERIOD ms. A timer, not
  # a loop on keys, so the load does not depend on what is typed.
  cat >> "$PAGE" <<HTML
<script>
setInterval(function () {
  var end = performance.now() + $BUSY_MS;
  while (performance.now() < end) {}
}, $BUSY_PERIOD);
</script>
HTML
fi

[[ "$DELAY_MS" =~ ^[0-9]+$ ]] || log_die 2 "--delay phải là số nguyên ms"

# Selects Dấu and checks it is the current source (TIS is trusted for the current source
# only). Stops the run (status 4) with a message if not. Prints nothing on stdout: it runs
# inside the command substitution that collects an app's text.
is_current_source() { [[ "$("$INPUT_SOURCE" current 2>/dev/null)" == "$1" ]]; }
select_dau() {
  stopped && return 1
  # Already the current source: nothing to switch. The script never selects a source
  # through the API on this path, so what macOS reports is what the system switched to.
  if ! is_current_source "$DAU_SOURCE"; then
    cycle_to_source "$DAU_SOURCE"
  fi
  if wait_until 3 is_current_source "$DAU_SOURCE"; then
    # Fixed: the input method is activated for the focused app after the switch, and
    # nothing outside it shows when that is done.
    sleep 0.3
    return 0
  fi
  local now="$("$INPUT_SOURCE" current 2>/dev/null)"
  log_error "Dừng: sau khi chọn $DAU_SOURCE, nguồn nhập liệu hiện tại là \"${now:-không đọc được}\". nguồn đó chưa được chọn nên không gõ gì."
  log_hint "Kiểm tra Dấu có trong System Settings › Keyboard › \"All Input Sources\"."
  stop_run source "nguồn nhập liệu hiện tại là \"${now:-không đọc được}\", không phải $DAU_SOURCE (sau khi chọn, đợi 3 giây)"
  return 1
}

# Every keystroke goes through a check that the app under test is frontmost (and, for
# browsers, that the test page is the front tab of its focused window), in the same osascript as the keys: if
# the user switches app while the script runs, nothing is typed into their window. A
# failed check stops the whole run (exit 3).
front_guard() { # process [window-title-substring] → AppleScript that errors if not front
  cat <<OSA
  tell application "System Events"
    set fp to name of first process whose frontmost is true
    if fp is not "$1" then error "frontmost is " & fp & ", not $1"
    if "${2:-}" is not "" then
      -- The focused window is the one that receives keys. "front window" can be a
      -- floating helper window instead (an Edge extension's popup).
      try
        set fw to name of (value of attribute "AXFocusedWindow" of process "$1")
      on error
        set fw to name of front window of process "$1"
      end try
      if fw does not contain "${2:-}" then error "front window of $1 is " & fw & ", not the test page"
    end if
  end tell
OSA
}
# The guard alone: status 0 when process $1 is frontmost (with $2 in its focused window's
# title, if given). Sends nothing.
front_ok() { osascript -e "$(front_guard "$1" "${2:-}")" -e 'return' >/dev/null 2>&1; }
# The failed check of front_guard, in words, from its error text: which app was in front,
# whether the focus was outside the test field, or which window had the keys.
guard_reason() { # error-text process title where
  local fw
  if [[ "$1" =~ 'frontmost is (.*), not ' ]]; then
    print -r -- "app ở trước là \"${match[1]}\", không phải $2"
  elif [[ "$1" =~ 'front window of .* is (.*), not the test page' ]]; then
    fw="${match[1]%%[[:space:]]#\(-[0-9]#\)}"
    if [[ "$3" == "$FOCUS_TITLE" && "$fw" == *"$PAGE_TITLE"* ]]; then
      print -r -- "focus không nằm trong ô gõ của trang thử (cửa sổ \"$fw\" của $2 không có [focus]; focus đang ở: ${4:-không đọc được})"
    else
      print -r -- "cửa sổ nhận phím của $2 là \"$fw\", không phải cửa sổ thử \"$3\""
    fi
  else
    print -r -- "kiểm tra trước khi gõ không đạt: ${1%%$'\n'*}"
  fi
}
# Runs AppleScript $3 only if the guard for process $1 (title $2) passes.
# The check alone is retried first (15 s at most): right after `open`, Safari 27 may
# briefly report an untitled front window. Keys are still only sent
# once the check passes.
guarded() {
  local out start=$SECONDS waited where
  # 15 s: on a Mac under heavy load the test page has been seen not to report the focus
  # within 3 s (docs/Progress.md, 10/11/2026). A longer wait that passes is reported, and
  # a failure says where the keyboard focus is, to tell a slow page from a focus elsewhere.
  wait_until -i 0.4 15 front_ok "$1" "$2"
  waited=$(( SECONDS - start ))
  (( waited >= 3 )) && log_warn "$1: chờ $waited giây mới tới kiểm tra cửa sổ và focus"
  if ! out="$(osascript -e "$(front_guard "$1" "$2")" -e "$3" 2>&1)"; then
    where="$(osascript -e "tell application \"System Events\" to tell process \"$1\" to get {role, description} of (value of attribute \"AXFocusedUIElement\")" 2>&1)"
    log_error "Dừng: $out — không gửi phím nào nữa (sau $waited giây; focus của $1 đang ở: ${where:-không đọc được})"
    stop_run front "$(guard_reason "$out" "$1" "${2:-}" "$where")"
    return 1
  fi
  printf '%s' "$out"
}
stopped() { [[ -e "$STOP_FILE" ]]; }

# Switches to source $1 the way the user does: macOS's own "Select next source in Input
# menu" shortcut, read from the user's settings (symbolic hot key 61), pressed until
# macOS reports the wanted source. The system then switches the source for the focused
# field itself; a source selected from this script's process (TISSelectInputSource) is
# reported as current, and shown in the menu bar, while the field keeps the old input
# method (docs/Progress.md, 10/11/2026). Only called when the wanted source is not the
# current one. Shortcut off or unreadable: falls back to the API, and says so.
cycle_to_source() { # source-id
  local json key mods using="" n
  json="$(plutil -extract AppleSymbolicHotKeys.61 json -o - "$HOME/Library/Preferences/com.apple.symbolichotkeys.plist" 2>/dev/null)"
  if [[ "$json" == *'"enabled":true'* && "$json" =~ '"parameters":\[[0-9]+,([0-9]+),([0-9]+)\]' ]]; then
    key=$match[1]; mods=$match[2]
    (( mods & 131072 )) && using+="shift down, "
    (( mods & 262144 )) && using+="control down, "
    (( mods & 524288 )) && using+="option down, "
    (( mods & 1048576 )) && using+="command down, "
    using="${using%, }"
    for n in 1 2 3 4 5 6 7 8 9 10; do
      osascript -e "tell application \"System Events\" to key code $key using {$using}" >/dev/null 2>&1
      # Fixed: the switch, and the system's source switcher going away, are not readable.
      sleep 0.5
      is_current_source "$1" && return 0
    done
    log_warn "Phím tắt chuyển nguồn của macOS không đưa tới $1 sau 10 lần nhấn: chọn bằng API"
  else
    log_warn "Không đọc được phím tắt \"Select next source in Input menu\" (hoặc đang tắt): chọn nguồn bằng API"
  fi
  "$INPUT_SOURCE" select "$1" >&2 || true
}


type_keys() { # process [window-title-substring]
  stopped && return 1
  # Safari has been seen to take the focus back to its address field after the page
  # reported it (busy Mac, 12/11/2026): put it back once more right before typing.
  [[ "${2:-}" == "$FOCUS_TITLE" ]] && focus_test_field "$1"
  # The delay goes in as whole milliseconds: coercing "0.030" to a real follows the
  # user's locale (Vietnamese uses a decimal comma, so it became 30 seconds).
  guarded "$1" "${2:-}" 'return' >/dev/null || return 1
  if ! osascript - "$KEYS" "$DELAY_MS" "$1" "$SWITCH_CMD" "$JITTER_MS" "$WORD_PAUSE_MS" 2>"$WORK/osa.err" <<'OSA'
on run argv
  set s to item 1 of argv
  set dms to (item 2 of argv) as integer
  set d to dms / 1000
  set p to item 3 of argv
  set sw to item 4 of argv
  set j to (item 5 of argv) as integer
  set wp to (item 6 of argv) as integer
  tell application "System Events"
    if (name of first process whose frontmost is true) is not p then error "frontmost changed"
    if d = 0 and j = 0 and s does not contain "⌫" and s does not contain "←" and s does not contain "↩" and s does not contain "⇄" then
      keystroke s
    else
      set i to 0
      repeat with c in characters of s
        -- Re-check now and then; not every key, so the delay stays close to d.
        set i to i + 1
        if i mod 8 = 0 then
          if (name of first process whose frontmost is true) is not p then error "frontmost changed"
        end if
        if (c as text) is "⌫" then
          key code 51
        else if (c as text) is "←" then
          key code 123
        else if (c as text) is "↩" then
          key code 36
        else if (c as text) is "⇄" then
          tell current application to do shell script sw
          if (name of first process whose frontmost is true) is not p then error "frontmost changed"
        else
          keystroke (c as text)
        end if
        -- Fixed on purpose: the pace the user asked for (--delay, --jitter), between keys.
        if j > 0 then
          -- random number is a scripting addition: run it here, not in System Events.
          tell current application to set r to random number from (0 - j) to j
          set pms to dms + r
          if pms > 0 then delay pms / 1000
        else if d > 0 then
          delay d
        end if
        -- --word-pause: a person stops after a word, not inside it.
        if wp > 0 and (c as text) is " " then delay wp / 1000
      end repeat
    end if
  end tell
end run
OSA
  then
    if [[ "$(cat "$STOP_FILE" 2>/dev/null)" == source ]]; then
      log_error "Dừng: sau ⇄, nguồn nhập liệu không thành nguồn vừa chọn trong 3 giây; không gõ tiếp."
      stop_run source "sau ⇄, nguồn nhập liệu không thành nguồn vừa chọn trong 3 giây"
    else
      local oerr; oerr="$(<"$WORK/osa.err")"
      if [[ "$oerr" == *"frontmost changed"* ]]; then
        log_error "Dừng: app đang thử không còn ở trước giữa lúc gõ."
        stop_run front "app đang thử không còn ở trước giữa lúc gõ"
      else
        log_error "Dừng: lệnh gõ phím lỗi giữa chừng: ${oerr:-không có thông báo}"
        stop_run front "lệnh gõ phím (osascript) lỗi giữa chừng: ${oerr%%$'\n'*}"
      fi
    fi
    return 1
  fi
  # Fixed: apps that apply text asynchronously (browsers, Electron) may still be
  # catching up with the last keys, and their text can only be read through ⌘A ⌘C,
  # which changes the selection; no state to poll for that is common to every app.
  # The source in effect right after the last key. The check in select_dau is from before
  # the keys: with macOS's "Automatically switch to a document's input source" on, the
  # focused document may have its own source.
  local after="$("$INPUT_SOURCE" current 2>/dev/null)"
  [[ "$after" == "$DAU_SOURCE" ]] || log_warn "Nguồn nhập liệu ngay sau khi gõ là \"$after\", không phải $DAU_SOURCE"
  sleep 0.8
}

# ⌘A ⌘C in the focused text field of process $1 (front tab title $2), then the plain
# text of the clipboard.
copy_all() {
  stopped && return 1
  # Empty the clipboard first so a failed copy cannot return an earlier run's text.
  printf '' | pbcopy
  # The 0.2 s between ⌘A and ⌘C stays fixed: the selection is not read anywhere.
  guarded "$1" "${2:-}" 'tell application "System Events"
    keystroke "a" using {command down}
    delay 0.2
    keystroke "c" using {command down}
  end tell' >/dev/null || return 1
  # The copy lands on the clipboard emptied above. No text after 3 s: the copy failed or
  # the field is empty, and the comparison reports it.
  wait_until 3 clipboard_has_text
  "$CLIPBOARD" text
}
clipboard_has_text() { [[ -n "$("$CLIPBOARD" text 2>/dev/null)" ]]; }

# --- one function per app; each prints the text typed ---------------------------------
# Safari and Chrome are driven with `open` and System Events keystrokes only: scripting
# them directly needs a separate Automation permission per browser.
# Names of the windows of process $1 (System Events; the window name is the tab title).
window_names() {
  osascript -e 'on run argv' -e 'tell application "System Events" to get name of every window of process (item 1 of argv)' \
    -e 'end run' "$1" 2>/dev/null
}
# Closes the test page's tab with ⌘W (the browser is frontmost), then checks no window of
# process $1 still shows it; tries again a few times.
close_test_tab() {
  for _ in 1 2 3; do
    # Only when the browser is frontmost with the test page in front.
    guarded "$1" "$PAGE_TITLE" 'tell application "System Events" to keystroke "w" using {command down}' \
      >/dev/null || break
    wait_until 3 test_page_closed "$1" && return 0
  done
  log_warn "Còn tab \"$PAGE_TITLE\" trong $1, đóng tay giúp"
}

test_page_closed() { [[ "$(window_names "$1")" != *"$PAGE_TITLE"* ]]; }

# Opens the test page in browser $1 (app name) and waits until process $2 is frontmost
# with the page in its focused window (the title comes from the loaded page). Not there in
# time: type_keys's guard reports it and stops the run.
open_test_page() { open_test_page_of "$PAGE" "$1" "$2"; }
open_test_page_of() { # page file, browser app name, process
  local file="$1"; shift
  open -a "$1" "$file"
  wait_until -i 0.3 5 front_ok "$2" "$PAGE_TITLE" && return 0
  # `open -a` on a running Safari has been seen to load the page without bringing Safari
  # to the front (another browser stayed frontmost for 15 s, 11/11/2026); `activate`
  # then did (docs/Progress.md, 11/11/2026). Only the app being tested is activated.
  osascript -e "tell application \"$1\" to activate" >/dev/null 2>&1
  wait_until -i 0.3 10 front_ok "$2" "$PAGE_TITLE"
}

# Puts the keyboard focus in the test page's text field of browser process $1 when the
# page does not report it (title without "[focus]"): Safari has been seen to open the
# page with the focus in its address field (docs/Progress.md, 10/11/2026), and the
# page's autofocus does not take it back. When the focus is in Safari's address field
# (confirmed through Accessibility), sends Tab to reach the page's first field; otherwise
# clicks the middle of the browser's focused window. Tries up to three times. Acts only while the browser is frontmost with the test page in that window: the
# text field fills the page (96vw × 90vh) so that the middle of the window is inside
# it. A first version looked for the page's AXTextArea through Accessibility and did
# not click in Safari (why was not kept). A click, not a script in the page: it needs
# no browser setting.
# Whether it worked is not judged here: type_keys's guard still checks the title.
focus_test_field() { # process
  stopped && return 1
  wait_until -i 0.3 2 front_ok "$1" "$FOCUS_TITLE" && return 0
  log_warn "$1: ô nhập của trang thử chưa có focus, bấm vào ô"
  # Under a busy Mac one click has been seen not to move the focus out of Safari's
  # address field within 15 s (heavy.sh, 12/11/2026): click again, up to three times.
  local err try
  for try in 1 2 3; do
    # Focus in Safari's address field ("smart search field"): clicks have been seen not to
    # take it out under load (12/11/2026); Tab moves it to the page's first field. Sent only
    # when that field is confirmed to hold the focus, never into a page's text field.
    err="$(osascript -e "$(front_guard "$1" "$PAGE_TITLE")" -e "
    tell application \"System Events\" to tell process \"$1\"
      try
        if description of (value of attribute \"AXFocusedUIElement\") is \"smart search field\" then
          key code 48
          return
        end if
      end try
      set w to value of attribute \"AXFocusedWindow\"
      set {x, y} to position of w
      set {sw, sh} to size of w
      click at {x + sw / 2, y + sh / 2}
    end tell" 2>&1 >/dev/null)" || log_warn "$1: không bấm được vào ô nhập của trang thử: $err"
    wait_until -i 0.3 5 front_ok "$1" "$FOCUS_TITLE" && return 0
    (( try < 3 )) && log_warn "$1: vẫn chưa có focus, bấm lại (lần $((try + 1)))"
  done
  return 0
}

run_safari() {
  open_test_page Safari Safari
  select_dau; focus_test_field Safari; type_keys Safari "$FOCUS_TITLE"
  copy_all Safari "$FOCUS_TITLE"
  close_test_tab Safari
}

run_chrome() {
  open_test_page "Google Chrome" "Google Chrome"
  select_dau; focus_test_field "Google Chrome"; type_keys "Google Chrome" "$FOCUS_TITLE"
  copy_all "Google Chrome" "$FOCUS_TITLE"
  close_test_tab "Google Chrome"
}

run_edge() {
  open_test_page "Microsoft Edge" "Microsoft Edge"
  select_dau; focus_test_field "Microsoft Edge"; type_keys "Microsoft Edge" "$FOCUS_TITLE"
  copy_all "Microsoft Edge" "$FOCUS_TITLE"
  close_test_tab "Microsoft Edge"
}

run_firefox() {
  open_test_page Firefox firefox
  select_dau; focus_test_field firefox; type_keys firefox "$FOCUS_TITLE"
  copy_all firefox "$FOCUS_TITLE"
  close_test_tab firefox
}

# Notes: a new note (⌘N) in the folder shown; read with ⌘A ⌘C, then emptied and deleted
# through Notes' AppleScript (it goes to Recently Deleted). Notes keeps an empty note
# while it is selected, so emptying alone left one behind after each run (11/11/2026).
# The note syncs while it exists. When the selected note is already empty, ⌘N selects
# it again instead of making another, so the note to type in is "the selected note once
# it is empty", new or reused.
notes_selected_empty_id() {
  osascript -e 'tell application "Notes"' -e 'set s to selection' \
    -e 'if (count of s) is 1 and plaintext of item 1 of s is "" then return id of item 1 of s' \
    -e 'end tell' 2>/dev/null
}
notes_empty_selected() { [[ -n "$(notes_selected_empty_id)" ]]; }
run_notes() {
  open -a Notes
  wait_until -i 0.3 15 front_ok Notes
  guarded Notes "" 'tell application "System Events" to keystroke "n" using {command down}' \
    >/dev/null || return 0
  local note=""
  wait_until -i 0.2 5 notes_empty_selected && note="$(notes_selected_empty_id)"
  [[ -n "$note" ]] || log_warn "Không đọc được ghi chú mới (quyền Automation cho Notes?): sẽ không xoá được nó"
  select_dau; type_keys Notes
  copy_all Notes
  # The delay between the keys stays fixed: pacing, nothing read in between.
  guarded Notes "" 'tell application "System Events"
    keystroke "a" using {command down}
    delay 0.1
    key code 51
  end tell' >/dev/null
  # Only the note this run created, and only once it is empty.
  [[ -n "$note" ]] || return 0
  osascript - "$note" <<'OSA' >/dev/null 2>&1 || log_warn "Không xoá được ghi chú thử trong Notes: xoá tay"
on run argv
  tell application "Notes"
    set n to note id (item 1 of argv)
    if plaintext of n is "" then delete n
  end tell
end run
OSA
}

# Mail: a new message (⌘N); the keys go to the body (focused through Accessibility), the
# To field stays empty and Send is never pressed. Read with ⌘A ⌘C, emptied, closed with
# ⌘W; if Mail asks to save the draft, "Don't Save"/"Delete" is chosen.
MAIL_COMPOSE="New Message"
MAIL_BODY='UI element 1 of scroll area 1 of group 1 of group 1 of front window'
mail_body_focused() {
  [[ "$(osascript -e "tell application \"System Events\" to tell process \"Mail\" to get value of attribute \"AXFocused\" of $MAIL_BODY" 2>/dev/null)" == true ]]
}
run_mail() {
  open -a Mail
  wait_until -i 0.3 15 front_ok Mail
  guarded Mail "" 'tell application "System Events" to keystroke "n" using {command down}' \
    >/dev/null || return 0
  wait_until -i 0.3 10 front_ok Mail "$MAIL_COMPOSE"
  guarded Mail "$MAIL_COMPOSE" "tell application \"System Events\" to tell process \"Mail\"
    set value of attribute \"AXFocused\" of $MAIL_BODY to true
  end tell" >/dev/null || return 0
  # Not focused in time: the keys go wherever Mail put the focus, and the comparison
  # reports it.
  wait_until 3 mail_body_focused
  select_dau; type_keys Mail "$MAIL_COMPOSE"
  copy_all Mail "$MAIL_COMPOSE"
  discard_front_document Mail "$MAIL_COMPOSE"
}

# Status 0 when process $1 has no window titled with $2 left without a sheet: the window
# closed, or it asks whether to save.
document_closed_or_asking() {
  [[ "$(osascript - "$1" "$2" <<'OSA' 2>/dev/null
on run argv
  tell application "System Events" to tell process (item 1 of argv)
    repeat with w in windows
      if name of w contains (item 2 of argv) and (count of sheets of w) = 0 then return "open"
    end repeat
  end tell
  return "done"
end run
OSA
)" == done ]]
}

# Empties the focused text (⌘A ⌫), closes the front window (⌘W) of process $1 whose
# title contains $2, and answers a save prompt with the button that discards.
discard_front_document() {
  # The short delays between the keys stay fixed: pacing, nothing read in between.
  guarded "$1" "$2" 'tell application "System Events"
    keystroke "a" using {command down}
    delay 0.1
    key code 51
    delay 0.3
    keystroke "w" using {command down}
  end tell' >/dev/null || return 0
  # Until the window is gone or shows its save sheet; the step below says which.
  wait_until 5 document_closed_or_asking "$1" "$2"
  osascript - "$1" "$2" <<'OSA' >/dev/null 2>&1 || log_warn "Còn cửa sổ \"$2\" của $1, đóng tay giúp (không lưu)"
on run argv
  set p to item 1 of argv
  set t to item 2 of argv
  tell application "System Events" to tell process p
    repeat with w in windows
      if name of w contains t then
        if (count of sheets of w) = 0 then error "window still open"
        set done to false
        repeat with b in buttons of sheet 1 of w
          if name of b is in {"Don't Save", "Don’t Save", "Delete", "Delete Draft", "Revert Changes"} then
            click b
            set done to true
            exit repeat
          end if
        end repeat
        if not done then error "no discard button"
      end if
    end repeat
  end tell
end run
OSA
}

run_vscode() {
  open -a "Visual Studio Code"
  osascript -e 'tell application "Visual Studio Code" to activate' >/dev/null
  wait_until -i 0.3 15 front_ok Code
  guarded Code "" 'tell application "System Events" to keystroke "n" using {command down}' \
    >/dev/null || return 0
  # Not there in time: type_keys's guard reports it and stops the run.
  wait_until -i 0.3 10 front_ok Code Untitled
  select_dau; type_keys Code Untitled
  copy_all Code Untitled
  # Empty the untitled editor so ⌘W closes it without asking to save. The delays between
  # the keys stay fixed: pacing, nothing read in between.
  guarded Code Untitled 'tell application "System Events"
    keystroke "a" using {command down}
    delay 0.1
    key code 51
    delay 0.2
    keystroke "w" using {command down}
  end tell' >/dev/null
}

# An editor built on VS Code, opened on an empty file of this run: $1 the process name,
# $2 its command-line tool. The file's name is the window title the guard asks for. After
# the text is read back the file is emptied and saved (it is this run's own file), so
# closing the window asks nothing.
file_editor() {
  local proc="$1" cli="$2" file="$WORK/dau-selftest.txt"
  : > "$file"
  "$cli" --new-window "$file" >/dev/null 2>&1
  osascript -e "tell application \"System Events\" to set frontmost of process \"$proc\" to true" >/dev/null 2>&1
  # Not there in time: type_keys's guard reports it and stops the run.
  # The new window can open behind another window of the app (Cursor keeps its agents
  # window focused): raise it until it is the focused one.
  local i
  for i in {1..40}; do
    osascript -e "tell application \"System Events\" to tell process \"$proc\" to perform action \"AXRaise\" of (first window whose name contains \"dau-selftest\")" >/dev/null 2>&1
    front_ok "$proc" dau-selftest && break
    # The first call after a while can bring the app up without opening the file: ask again.
    (( i % 10 == 0 )) && "$cli" "$file" >/dev/null 2>&1
    sleep 0.5
  done
  select_dau; type_keys "$proc" dau-selftest
  copy_all "$proc" dau-selftest
  guarded "$proc" dau-selftest 'tell application "System Events"
    keystroke "a" using {command down}
    delay 0.1
    key code 51
    delay 0.2
    keystroke "s" using {command down}
    delay 0.5
  end tell' >/dev/null
  osascript -e "tell application \"System Events\" to tell process \"$proc\" to click (first button of (first window whose name contains \"dau-selftest\") whose subrole is \"AXCloseButton\")" >/dev/null 2>&1
}

# Cursor's editor. ⌘N in Cursor opens a new agent, not an untitled file, hence the file.
run_cursor() { file_editor Cursor /Applications/Cursor.app/Contents/Resources/app/bin/cursor; }
# VS Code opened the same way as Cursor: the control for that way of opening an editor.
run_vscodefile() { file_editor Code "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"; }

# The prompt box of Cursor's "Cursor Agents" window. ⌘N starts a new agent with an empty
# prompt; a prompt that is not empty (the user's draft) stops the run before anything is
# typed. Return is never sent: nothing goes to an agent. The prompt is emptied at the end.
run_cursoragents() {
  open -a Cursor
  osascript -e 'tell application "System Events" to tell process "Cursor"
    set frontmost to true
    perform action "AXRaise" of (first window whose name is "Cursor Agents")
  end tell' >/dev/null 2>&1
  wait_until -i 0.3 15 front_ok Cursor "Cursor Agents"
  guarded Cursor "Cursor Agents" 'tell application "System Events" to keystroke "n" using {command down}' \
    >/dev/null || return 0
  sleep 0.5
  local draft
  draft="$(copy_all Cursor "Cursor Agents")"
  if [[ -n "$draft" ]]; then
    log_error "Dừng: ô nhập của Cursor Agents không trống — không gõ gì"
    stop_run front "ô nhập của Cursor Agents không trống"
    return 0
  fi
  select_dau; type_keys Cursor "Cursor Agents"
  copy_all Cursor "Cursor Agents"
  guarded Cursor "Cursor Agents" 'tell application "System Events"
    keystroke "a" using {command down}
    delay 0.1
    key code 51
  end tell' >/dev/null
}

# Sets $win to Terminal's front window, if it has one.
terminal_front_window() {
  win="$(osascript -e 'tell application "Terminal" to if (count of windows) > 0 then return id of front window' 2>/dev/null)"
  [[ -n "$win" ]]
}
# The non-blank text of Terminal window $1 (empty while the shell has printed nothing).
terminal_text() {
  local text
  text="$(osascript -e "tell application \"Terminal\" to get contents of selected tab of window id $1" 2>/dev/null)"
  [[ "$text" == *[^[:space:]]* ]] && print -r -- "$text"
}

run_terminal() {
  # Remember the window used here: it is the only one read and closed. When Terminal is
  # not running, launching it opens its startup window, and `do script ""` would open a
  # second one that is the only one closed, leaving the startup window behind. So a
  # Terminal launched here types into its startup window instead.
  local running
  win=""
  running="$(osascript -e 'application "Terminal" is running')"
  if [[ "$running" == false ]]; then
    osascript -e 'tell application "Terminal" to activate' >/dev/null || return 0
    wait_until 5 terminal_front_window
  fi
  # Already running, or set to open no window at launch: a new window of our own.
  [[ -n "$win" ]] || win="$(osascript -e 'tell application "Terminal"' -e 'activate' -e 'do script ""' \
    -e 'return id of front window' -e 'end tell')" || return 0
  # Wait for the shell prompt: keys sent before the shell is ready (a slow zsh theme
  # takes ~3 s) are lost and never reach the input method. Ready: the window shows some
  # text and it stays the same on 3 reads (a theme may redraw its prompt). Not settled in
  # time: typing goes on and the comparison reports lost keys.
  wait_settled 8 3 terminal_text "$win" >/dev/null
  select_dau; type_keys Terminal
  # The keys sit after the prompt on its last line, or on its last rows when they wrap
  # (long --keys): print the last non-blank rows joined, the caller compares by suffix.
  # Under 60 characters, one row as before; longer, enough rows for the text plus a prompt
  # of up to one row at the 80 columns of a new window of the default profile.
  local rows=1
  (( ${#EXPECT} < 60 )) || rows=$(( 2 + ${#EXPECT} / 80 ))
  osascript -e "tell application \"Terminal\" to get contents of selected tab of window id $win" \
    | grep -v '^[[:space:]]*$' | tail -$rows | tr -d '\n'
  # ⌃U clears the line; never Return. Then close that window (only the shell runs in it).
  guarded Terminal "" 'tell application "System Events" to keystroke "u" using {control down}' >/dev/null
  # Fixed: lets the shell take ⌃U before its window closes; nothing read in between.
  sleep 0.2
  osascript -e "tell application \"Terminal\" to close window id $win" >/dev/null 2>&1
}

# Sublime Text (System Events process "sublime_text"): an empty file of this run in a new
# window of its own (`subl -n`), so ⌘W and the save prompt only ever concern this file.
# Read with ⌘A ⌘C, not by saving and reading the file back: an unregistered copy may ask
# to buy a license after a save, a dialog the script must not answer for the user.
SUBLIME_PROC=sublime_text
SUBLIME_CLI="/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl"
SELFTEST_TITLE=dau-selftest
# Status 0 when this run's Sublime window is the focused one; if not, raises it (it can
# open behind another window of the app).
sublime_front() {
  front_ok "$SUBLIME_PROC" "$SELFTEST_TITLE" && return 0
  osascript -e "tell application \"System Events\" to tell process \"$SUBLIME_PROC\"
    set frontmost to true
    perform action \"AXRaise\" of (first window whose name contains \"$SELFTEST_TITLE\")
  end tell" >/dev/null 2>&1
  return 1
}
sublime_closed() { [[ "$(window_names "$SUBLIME_PROC")" != *"$SELFTEST_TITLE"* ]]; }
run_sublime() {
  local file="$WORK/$SELFTEST_TITLE.txt"
  : > "$file"
  "$SUBLIME_CLI" -n "$file" >/dev/null 2>&1
  # Not there in time: type_keys's guard reports it and stops the run.
  wait_until -i 0.5 15 sublime_front
  select_dau; type_keys "$SUBLIME_PROC" "$SELFTEST_TITLE"
  copy_all "$SUBLIME_PROC" "$SELFTEST_TITLE"
  # Why revert and not answer the prompt: the typed text makes the buffer dirty, and ⌘W on a
  # dirty buffer opens a save dialog whose button has to be found by its English label and
  # that has been left open twice. Reverting to the empty file on disk makes the buffer clean,
  # so ⌘W never asks. `subl --command` acts on the focused window, so it runs only while
  # this run's window is the focused one (front_ok checks its title); otherwise nothing runs
  # and the user's windows are never touched.
  front_ok "$SUBLIME_PROC" "$SELFTEST_TITLE" && "$SUBLIME_CLI" --background --command revert >/dev/null 2>&1
  sleep 0.5
  # ⌘W on this tab (the guard checks its title). Its window closes with its last tab
  # (close_windows_when_empty, on by default on macOS).
  guarded "$SUBLIME_PROC" "$SELFTEST_TITLE" \
    'tell application "System Events" to keystroke "w" using {command down}' >/dev/null || return 0
  wait_until 5 sublime_closed
  sublime_closed || log_warn "Còn tab \"$SELFTEST_TITLE\" của Sublime Text (có thể còn hộp thoại lưu), đóng tay giúp (Don't Save)"
}

# Ghostty (System Events process "ghostty"). Its AppleScript cannot read a window's text,
# so the new window runs a small line editor of this run's own (the cell below) in place
# of the user's shell, through the `command` of a Ghostty surface configuration. The cell:
# - puts Ghostty's terminal in raw mode and copies every byte Ghostty writes to it, as is,
#   to the raw file (tee): DEL bytes, text sent again after a replacement, everything;
# - passes the same bytes, through a terminal of its own (script(1)), to zsh's line editor
#   (`vared` in `zsh -f`: emacs keys, none of the user's configuration). There ⌫ (DEL)
#   deletes one character, as at a zsh prompt, and the line it ends with is the result
#   compared with --expect: what a zsh prompt would hold. ⌃D is bound to accept the line,
#   so no Return is needed (keys ending with ↩ show whether Ghostty passes Return on: the
#   raw bytes then hold <0d>). Ghostty drops most keys that commit marked text (Return, ⌃C…,
#   docs/research/TerminalAndUnderline.md), so with --underline and keys that do not
#   end a word, the first ⌃D may only commit it: run_ghostty sends a second one;
# - sets the window title to dau-selftest just before the line editor reads its first
#   key: the guard waits for that title, so no key is sent before the editor is ready.
# Not used: the terminal's own line mode (`cat` in canonical mode), whose erase is not a
# zsh prompt's line editor and takes one byte unless iutf8 is set; and a named pipe in
# place of the pipe into script(1), which macOS's script refuses as its input.
# The cell ends after ⌃D; Ghostty then closes the window (wait-after-command is off by default).
GHOSTTY_PROC=ghostty
GHOSTTY_RAW="$WORK/ghostty.raw"
GHOSTTY_LINE="$WORK/ghostty.line"
GHOSTTY_CELL="$WORK/ghostty-cell.zsh"
# The cell, a zsh script: $1 raw bytes file, $2 line file, $3 window title.
ghostty_cell() {
  cat <<'CELL'
# Runs in the Ghostty window opened by scripts/selftest/typing/run.sh (run_ghostty).
export LC_ALL=en_US.UTF-8
size=(${=$(stty size </dev/tty 2>/dev/null)})
stty raw -echo </dev/tty
/usr/bin/script -q /dev/null /bin/zsh -f -c '
  (( $1 > 0 )) && stty rows $1 cols $2 2>/dev/null
  zmodload zsh/zle
  bindkey -e
  bindkey "^D" accept-line
  print -n "\e]2;$4\a"
  line=
  vared -p "dau> " line
  print -rn -- "$line" > $3
' zsh "${size[1]:-0}" "${size[2]:-0}" "$2" "$3" < <(exec /usr/bin/tee "$1" </dev/tty)
/usr/bin/pkill -P $$ -x tee
exit 0
CELL
}
# The command line Ghostty runs (with arguments, Ghostty runs it through /bin/sh -c).
ghostty_command() { print -r -- "/bin/zsh -f ${(qq)GHOSTTY_CELL} ${(qq)GHOSTTY_RAW} ${(qq)GHOSTTY_LINE} ${(qq)SELFTEST_TITLE}"; }
# A new Ghostty window running command $1; prints the window's id. The app ID is written
# out: AppleScript needs it at compile time to know Ghostty's terms.
ghostty_new_window() {
  osascript - "$1" <<'OSA'
on run argv
  tell application id "com.mitchellh.ghostty"
    activate
    set cfg to new surface configuration
    set command of cfg to (item 1 of argv)
    set w to new window with configuration cfg
    return id of w
  end tell
end run
OSA
}
ghostty_running() { [[ "$(osascript -e "application id \"$(bundle_id ghostty)\" is running" 2>/dev/null)" == true ]]; }
ghostty_window_gone() { # window id
  [[ ", $(osascript -e 'tell application id "com.mitchellh.ghostty" to get id of every window' 2>/dev/null), " != *", $1, "* ]]
}
# Status 0 when this run's Ghostty window is the focused one with the cell's title; if
# not, brings that window to the front.
ghostty_front() { # window id
  front_ok "$GHOSTTY_PROC" "$SELFTEST_TITLE" && return 0
  osascript -e "tell application id \"com.mitchellh.ghostty\" to activate window (first window whose id is \"$1\")" >/dev/null 2>&1
  return 1
}
# ⌃D: the cell's line editor accepts the line.
ghostty_end_line() {
  guarded "$GHOSTTY_PROC" "$SELFTEST_TITLE" \
    'tell application "System Events" to keystroke "d" using {control down}' >/dev/null
}
# Closes Ghostty window $1 when the cell did not end. Ghostty asks before closing a window
# whose program still runs: "Close" is clicked in that sheet of this window only.
ghostty_close() { # window id
  osascript -e "tell application id \"com.mitchellh.ghostty\" to close window (first window whose id is \"$1\")" >/dev/null 2>&1
  wait_until 3 ghostty_window_gone "$1" && return 0
  osascript - "$GHOSTTY_PROC" "$SELFTEST_TITLE" <<'OSA' >/dev/null 2>&1
on run argv
  tell application "System Events" to tell process (item 1 of argv)
    repeat with w in windows
      if name of w contains (item 2 of argv) and (count of sheets of w) > 0 then
        repeat with b in buttons of sheet 1 of w
          if name of b is "Close" then
            click b
            return
          end if
        end repeat
      end if
    end repeat
  end tell
end run
OSA
  wait_until 3 ghostty_window_gone "$1" || log_warn "Còn cửa sổ Ghostty \"$SELFTEST_TITLE\", đóng tay giúp"
}
run_ghosttyvim() { run_ghostty vim; }
run_ghostty() { # [vim]
  local win mode="${1:-}"
  rm -f "$GHOSTTY_RAW" "$GHOSTTY_LINE"
  if [[ $mode == vim ]]; then ghostty_vim_cell; else ghostty_cell; fi > "$GHOSTTY_CELL"
  # Not running: launch it without the window it opens at launch, so that only this run's
  # window is opened (and closed). It stays running afterwards, as other apps do.
  if ! ghostty_running; then
    open -a Ghostty --args --initial-window=false
    wait_until 10 ghostty_running
  fi
  if ! win="$(ghostty_new_window "$(ghostty_command)" 2>&1)" || [[ -z "$win" ]]; then
    log_error "Không mở được cửa sổ Ghostty: ${win:-không rõ lý do}"
    log_hint "Cần quyền Automation cho Ghostty (System Settings › Privacy & Security › Automation) và macos-applescript chưa tắt trong cấu hình Ghostty."
    return 0
  fi
  # Not there in time: type_keys's guard reports it and stops the run.
  wait_until -i 0.3 15 ghostty_front "$win"
  select_dau
  if [[ $mode == vim ]]; then
    # vim writes the buffer once typing pauses; then the window is closed with vim running.
    if type_keys "$GHOSTTY_PROC" "$SELFTEST_TITLE"; then
      shot_window "$GHOSTTY_PROC" ghosttyvim
      wait_until 4 test -s "$GHOSTTY_LINE" || log_warn "Ghostty (vim): vim chưa ghi tệp sau 4 giây"
    fi
    ghostty_close "$win"
    [[ -e "$GHOSTTY_LINE" ]] && print -r -- "$(<"$GHOSTTY_LINE")"
    return 0
  fi
  # Keys ending with ↩: if Ghostty passed Return on, the line editor has ended already and
  # the window is closing, so no ⌃D (its guard would find no window and stop the run).
  type_keys "$GHOSTTY_PROC" "$SELFTEST_TITLE" && shot_window "$GHOSTTY_PROC" ghostty
  if ! stopped \
      && { [[ "$KEYS" == *↩* ]] && wait_until 2 test -e "$GHOSTTY_LINE" || ghostty_end_line; }; then
    if ! wait_until 2 test -e "$GHOSTTY_LINE" && ! stopped; then
      log_warn "Ghostty: dòng chưa kết thúc 2 giây sau ⌃D (⌃D chỉ chốt chữ gạch chân?), gửi lại ⌃D"
      ghostty_end_line && wait_until 3 test -e "$GHOSTTY_LINE"
    fi
  fi
  wait_until 5 ghostty_window_gone "$win" || ghostty_close "$win"
  [[ -e "$GHOSTTY_LINE" ]] && print -r -- "$(<"$GHOSTTY_LINE")"
  return 0
}
# The bytes of file $1 for reading: DEL as ⌫, ⌃D as ⌃D, ESC as ⎋, other control bytes as
# <hex>, text as is.
visible_bytes() {
  local LC_ALL=en_US.UTF-8 s c out=""
  s="$(cat -- "$1"; print -n x)"; s="${s%x}"
  for c in "${(@s::)s}"; do
    case "$c" in
      $'\x7f') out+="⌫" ;;
      $'\x04') out+="⌃D" ;;
      $'\e') out+="⎋" ;;
      [[:cntrl:]]) out+="<$(printf '%02x' "'$c")>" ;;
      *) out+="$c" ;;
    esac
  done
  print -r -- "$out"
}

# Ghostty with vim (ghosttyvim): the same window, but the cell runs vim in insert mode
# (no user configuration; Backspace over everything, as defaults.vim sets it) in place of
# the line editor. vim writes the buffer to the line file whenever typing pauses 300 ms
# (CursorHoldI), so the text is there without a key to save; the window is then closed
# ("Close" in Ghostty's sheet). Raw bytes are teed as for ghostty. Underline keys that do
# not end a word are never committed here: use it with in-place typing.
ghostty_vim_cell() {
  cat <<'CELL'
# Runs in the Ghostty window opened by scripts/selftest/typing/run.sh (run_ghostty vim).
export LC_ALL=en_US.UTF-8
stty raw -echo </dev/tty
# vim sets the window title itself once it reads keys: the guard waits for that title, so
# no key reaches the terminal while it is still in line mode (which erases bytes, not
# characters).
/usr/bin/script -q /dev/null /usr/bin/vim -u NONE -N -n -i NONE --cmd "set encoding=utf-8" \
  -c "set backspace=indent,eol,start updatetime=300 title titlestring=${3// /\\ }" \
  -c "au CursorHoldI * silent write! ${(q)2}" -c startinsert < <(exec /usr/bin/tee "$1" </dev/tty)
CELL
}

# --shot: a picture of the focused window of process $1 to SAVE_DIR/$2.png, taken right
# after the keys (before a word end commits marked text), to see how marked text is drawn.
shot_window() { # process name
  (( SHOT )) || return 0
  local b
  b="$(osascript -e "tell application \"System Events\" to tell process \"$1\" to get {position, size} of (value of attribute \"AXFocusedWindow\")" 2>/dev/null)"
  b="${b//[[:space:]]/}"
  [[ "$b" =~ '^-?[0-9]+,-?[0-9]+,[0-9]+,[0-9]+$' ]] || { log_warn "$1: không đọc được khung cửa sổ, không chụp"; return 0; }
  /usr/sbin/screencapture -x -R"$b" "$SAVE_DIR/$2.png" || log_warn "$1: chụp cửa sổ không được"
}

# xterm: the terminal of Electron apps such as the Claude desktop app (xterm.js in a
# Chromium page), rebuilt as a local page in Chrome: xterm.js 5.5.0 from jsDelivr (needs
# the network) and, in place of a shell, a line editor in the page: DEL erases one
# character, other data is appended, as a shell prompt does. Read back with ⌘C, which the
# page answers with that line and, on a second line, every chunk xterm.js sent to the
# "shell" (onData), so what the input method's calls became is visible. The focus title
# is set only while xterm.js's own text area has the focus.
XTERM_PAGE="$WORK/dau-xterm.html"
cat > "$XTERM_PAGE" <<HTML
<!doctype html><meta charset="utf-8"><title>$PAGE_TITLE</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@xterm/xterm@5.5.0/css/xterm.css">
<script src="https://cdn.jsdelivr.net/npm/@xterm/xterm@5.5.0/lib/xterm.js"></script>
<div id="t" style="width:96vw;height:90vh"></div>
<script>
var term = new Terminal({ fontSize: 18 });
term.open(document.getElementById("t"));
term.focus();
var line = [], chunks = [];
function show(s) {
  return s.replace(/[\x00-\x1f\x7f]/g, function (c) { return c === "\x7f" ? "⌫" : "<" + c.charCodeAt(0).toString(16).padStart(2, "0") + ">"; });
}
term.onData(function (d) {
  chunks.push(show(d));
  for (var c of d) {
    if (c === "\x7f") { if (line.length) { line.pop(); term.write("\b \b"); } }
    else if (c === "\r") { line.push("↩"); term.write("\r\n"); }
    else if (c >= " ") { line.push(c); term.write(c); }
  }
});
window.addEventListener("copy", function (e) {
  e.clipboardData.setData("text/plain", line.join("") + "\n" + chunks.join(" | "));
  e.preventDefault(); e.stopImmediatePropagation();
}, true);
function mark() {
  document.title = document.hasFocus() && document.activeElement === term.textarea ? "$FOCUS_TITLE" : "$PAGE_TITLE";
}
["focus", "blur"].forEach(function (e) { window.addEventListener(e, mark, true); });
setInterval(mark, 200);
mark();
</script>
HTML
# Prints the line; the onData chunks go to SAVE_DIR/xterm.data (with --save) and stderr.
run_xterm() {
  local got
  open -a "Google Chrome" "$XTERM_PAGE"
  wait_until -i 0.3 15 front_ok "Google Chrome" "$PAGE_TITLE"
  select_dau; focus_test_field "Google Chrome"; type_keys "Google Chrome" "$FOCUS_TITLE"
  shot_window "Google Chrome" xterm
  got="$(copy_all "Google Chrome" "$FOCUS_TITLE")"
  close_test_tab "Google Chrome"
  log_detail "xterm.js gửi cho shell: \"${got#*$'\n'}\"" >&2
  [[ -n "$SAVE_DIR" ]] && print -r -- "${got#*$'\n'}" > "$SAVE_DIR/xterm.data"
  print -r -- "${got%%$'\n'*}"
}

# tiptap: the message box of the Claude desktop app and of claude.ai (a TipTap/ProseMirror
# contenteditable, which handles beforeinput and composition itself), rebuilt as a local
# page in Chrome: TipTap 2.26.1 (core + starter-kit, pinned) from jsDelivr as ES modules
# (needs the network), in a div.tiptap.ProseMirror like the real one. Read back with ⌘C,
# which the page answers with the editor's text (editor.getText(), not the HTML; a no-break
# space, which a browser may put for a typed space, counts as a space) and, on a second
# line, the inputType of every beforeinput the editor received ("insertText",
# "insertReplacementText", "deleteContentBackward"…, with the data for the replacing
# ones), so what the input method's calls became is visible. The focus title is set only
# while the editor itself has the focus. Return is never typed (↩ is an error here).
TIPTAP_PAGE="$WORK/dau-tiptap.html"
cat > "$TIPTAP_PAGE" <<HTML
<!doctype html><meta charset="utf-8"><title>$PAGE_TITLE</title>
<style>
  body { margin: 8px; font: 18px -apple-system, sans-serif; }
  #e { width: 96vw; height: 80vh; border: 1px solid #888; padding: 8px; overflow: auto; }
  .ProseMirror { outline: none; min-height: 100%; }
</style>
<div id="e"></div>
<script type="module">
import { Editor } from "https://cdn.jsdelivr.net/npm/@tiptap/core@2.26.1/+esm";
import StarterKit from "https://cdn.jsdelivr.net/npm/@tiptap/starter-kit@2.26.1/+esm";
var editor = new Editor({
  element: document.getElementById("e"),
  extensions: [StarterKit],
  content: "<p></p>",
  autofocus: "end",
  editorProps: { attributes: { spellcheck: "false", autocomplete: "off", autocorrect: "off" } }
});
var dom = editor.view.dom, events = [];
dom.addEventListener("beforeinput", function (e) {
  events.push(e.inputType + (e.data && e.inputType !== "insertText" ? "(" + e.data + ")" : ""));
}, true);
window.addEventListener("copy", function (e) {
  var text = editor.getText().replace(/\u00a0/g, " ");
  e.clipboardData.setData("text/plain", text + "\n" + events.join(" | "));
  e.preventDefault(); e.stopImmediatePropagation();
}, true);
function mark() {
  document.title = document.hasFocus() && dom.contains(document.activeElement) ? "$FOCUS_TITLE" : "$PAGE_TITLE";
}
["focus", "blur"].forEach(function (e) { window.addEventListener(e, mark, true); });
setInterval(mark, 200);
mark();
window.dauEditor = editor;
</script>
HTML
# Prints the editor's text; the beforeinput types go to SAVE_DIR/tiptap.events (with
# --save) and stderr.
run_tiptap() {
  local got
  open_test_page_of "$TIPTAP_PAGE" "Google Chrome" "Google Chrome"
  select_dau; focus_test_field "Google Chrome"; type_keys "Google Chrome" "$FOCUS_TITLE"
  got="$(copy_all "Google Chrome" "$FOCUS_TITLE")"
  close_test_tab "Google Chrome"
  log_detail "beforeinput của editor: \"${got#*$'\n'}\"" >&2
  [[ -n "$SAVE_DIR" ]] && print -r -- "${got#*$'\n'}" > "$SAVE_DIR/tiptap.events"
  print -r -- "${got%%$'\n'*}"
}

# --- run -------------------------------------------------------------------------------
trim_right() { sed -e 's/[[:space:]]*$//'; }
EXPECT_TRIMMED="$(printf '%s' "$EXPECT" | trim_right)"
FAILED=0
log_step "Script sẽ mở: ${APPS[*]}"
log_detail "mỗi app một cửa sổ/tab mới, đóng lại sau khi đọc chữ; app nào chưa chạy thì vẫn để chạy"
if (( NO_ANSWER )); then
  log_detail "phím: \"$KEYS\"   mong đợi: không có đáp án (--keys không kèm --expect): chỉ in chữ đọc lại, không so   nghỉ giữa phím: ${DELAY_MS} ms"
else
  log_detail "phím: \"$KEYS\"   mong đợi: \"$EXPECT\"   nghỉ giữa phím: ${DELAY_MS} ms"
fi
DAU_RUN=1
[[ -z "$SOURCE_ID" ]] || DAU_RUN=0   # a run of another input method: Dấu's own logs say nothing about it
bundle_id() {
  case "$1" in
    safari) echo com.apple.Safari ;;
    chrome) echo com.google.Chrome ;; vscode) echo com.microsoft.VSCode ;;
    terminal) echo com.apple.Terminal ;;
    edge) echo com.microsoft.edgemac ;; firefox) echo org.mozilla.firefox ;;
    notes) echo com.apple.Notes ;; mail) echo com.apple.mail ;;
    cursor|cursoragents) echo com.todesktop.230313mzl4w4u92 ;;
    vscodefile) echo com.microsoft.VSCode ;;
    sublime) echo com.sublimetext.4 ;; ghostty|ghosttyvim) echo com.mitchellh.ghostty ;;
    xterm|tiptap) echo com.google.Chrome ;;
  esac
}
[[ $UNDERLINE == 1 ]] && log_detail "chế độ gạch chân (D13) ép bằng $FORCE_KEY cho từng app"
(( JITTER_MS > 0 )) && log_detail "nghỉ giữa phím dao động ±${JITTER_MS} ms"
(( BUSY_MS > 0 )) && log_detail "trang thử chặn luồng chính ${BUSY_MS} ms mỗi ${BUSY_PERIOD} ms (--busy)"
for app in "${APPS[@]}"; do
  if stopped; then break; fi
  if [[ $UNDERLINE == 1 ]]; then
    defaults write -g "$FORCE_KEY" -array "$(bundle_id "$app")"
  fi
  start="$(date '+%Y-%m-%d %H:%M:%S')"
  got="$("run_$app")"
  # Fixed: the input method's perf lines reach the log store asynchronously, and how many
  # to expect is not known, so there is nothing to wait for.
  sleep 0.3
  if stopped; then
    # Another app came to the front, or Dấu could not be selected: no verdict for this app.
    log_error "Dừng $app: không có kết quả (xem thông báo dừng ở trên)."
    break
  fi
  [[ -n "$SAVE_DIR" ]] && print -r -- "$got" > "$SAVE_DIR/$app.txt"
  got_trimmed="$(printf '%s' "$got" | trim_right)"
  if [[ "$app" == terminal ]]; then
    ok=0; [[ "$got_trimmed" == *"$EXPECT_TRIMMED" ]] && ok=1
    # A long text wraps over several rows; if Terminal drops the space where a row
    # breaks, compare again without whitespace (said in the output).
    if [[ $ok == 0 && ${#EXPECT_TRIMMED} -ge 60 && "${got_trimmed//[[:space:]]/}" == *"${EXPECT_TRIMMED//[[:space:]]/}" ]]; then
      ok=1; log_detail "(khớp khi bỏ khoảng trắng: Terminal ngắt dòng dài, không tính lỗi)"
    fi
  else
    ok=0; [[ "$got_trimmed" == "$EXPECT_TRIMMED" ]] && ok=1
    # TextEdit, Notes, Pages… capitalize the first word of a new document by themselves
    # (macOS "Capitalize words automatically") when keys come slowly enough: not the
    # input method's doing.
    if [[ $ok == 0 ]]; then
      # (U) on the first character needs a UTF-8 locale, whatever the caller's is.
      () { local LC_ALL=en_US.UTF-8; capitalized="${(U)EXPECT_TRIMMED[1]}${EXPECT_TRIMMED[2,-1]}" }
      [[ "$got_trimmed" == "$capitalized" ]] && { ok=1; log_detail "(chữ đầu viết hoa do app tự viết hoa, không tính lỗi)"; }
    fi
  fi
  # A control source that did not take: the text is the keys as typed. Not a result.
  if (( ! NO_ANSWER )) && [[ -n "$SOURCE_ID" && "$got_trimmed" == "$(printf '%s' "$KEYS" | trim_right)" && "$KEYS" != "$EXPECT" ]]; then
    log_error "Ô không hợp lệ: $app ra nguyên chuỗi phím, $SOURCE_ID không có tác dụng trong ô gõ"
    stop_run source "$app ra nguyên chuỗi phím: $SOURCE_ID không có tác dụng trong ô gõ"; break
  fi
  if (( NO_ANSWER )); then log_detail "$app: không có đáp án, chữ đọc lại: \"$got_trimmed\""
  elif [[ $ok == 1 ]]; then log_ok "$app đạt: \"$got_trimmed\""; else log_error "$app sai: \"$got_trimmed\""; FAILED=1; fi
  # Ghostty: the bytes it sent to the terminal, before the line editor applied ⌫ (DEL).
  if [[ "$app" == ghostty* && -e "$GHOSTTY_RAW" ]]; then
    log_detail "byte Ghostty gửi xuống terminal: \"$(visible_bytes "$GHOSTTY_RAW")\""
    [[ -n "$SAVE_DIR" ]] && cp "$GHOSTTY_RAW" "$SAVE_DIR/$app.raw"
  fi
  "$LOG" show --start "$start" --style compact \
    --predicate "subsystem == \"$IM_ID\" AND (category == \"perf\" OR category == \"diag\")" > "$WORK/perf.log" 2>/dev/null
  [[ -n "$SAVE_DIR" ]] && cp "$WORK/perf.log" "$SAVE_DIR/$app.perf.log"
  case "$app" in
    safari) filter=Safari ;; chrome|xterm|tiptap) filter=Chrome ;;
    vscode) filter=VSCode ;; terminal) filter=Terminal ;;
    *) filter="$(bundle_id "$app")" ;;
  esac
  # Timings come from the per-key log of a Debug Dấu (D8): a Release build and another input
  # method write none, so say that in one line instead of reporting "no measurements".
  if (( ! DAU_RUN )); then
    :   # another input method: nothing of Dấu's to report
  elif [[ "$IM_CONFIG" == Release ]]; then
    log_detail "bộ gõ bản Release không ghi nhật ký từng phím (D8): không có số đo thời gian"
  else
    "$ROOT/scripts/perf/perf-report.sh" --input "$WORK/perf.log" --app "$filter" \
      | grep -E 'count_|gap_|lag_us|handle_replace_us|selectedRange_us|insertText_us|attributedSubstring_us|event_' || true
  fi
  settings_log="$("$LOG" show --start "$start" --style compact \
      --predicate "subsystem == \"$IM_ID\" AND category == \"settings\"" 2>/dev/null)"
  if [[ $UNDERLINE == 1 ]] && (( DAU_RUN )); then
    if [[ "$settings_log" == *"event=underline-on app=$(bundle_id "$app")"* ]]; then
      log_detail "underline-on"
    elif [[ "$IM_CONFIG" == Release ]]; then
      log_warn "Không thấy underline-on: bộ gõ bản Release không đọc khoá $FORCE_KEY (chỉ bản Debug)"
    else
      log_warn "Không thấy underline-on trong nhật ký của bộ gõ (cấu hình bộ gõ: $IM_CONFIG)"
    fi
  elif [[ $UNDERLINE == 1 ]]; then
    log_warn "--underline chỉ có tác dụng với Dấu: $SOURCE_ID không đọc khoá $FORCE_KEY"
  fi
  # D43: whether the input method took this field for one that ignores the replacement
  # range, and how it sends (logged once per activation, also by Release builds; only
  # Debug builds add the app's bundle ID, D8, so a line without one counts for the app
  # this window of the log belongs to).
  if (( DAU_RUN )); then
    ignored="$(print -r -- "$settings_log" | grep -E "event=range-ignored mode=[a-z-]*( app=$(bundle_id "$app"))?\$" | grep -o "event=range-ignored mode=[a-z-]*" | head -1)"
    if [[ -n "$ignored" ]]; then
      log_detail "D43: nhận ra ô bỏ qua vùng thay chữ, ${${ignored#*mode=}%% *}"
    elif [[ -s "$WORK/perf.log" ]] && grep -q "name=range-ignore-refuted" "$WORK/perf.log"; then
      # Debug only (PerfLog): the position looked like such a field, but the app gave back
      # the text Dấu typed (D43, "Bằng chứng dương").
      log_detail "D43: vị trí giống ô bỏ qua vùng thay chữ nhưng app trả đúng chữ đã gõ, không nhận ra"
    else
      log_detail "D43: không nhận ra ô bỏ qua vùng thay chữ"
    fi
  fi
done
if stopped; then
  # Not overwritten by an earlier failure: the run did not finish.
  stop_why="$(cat "$STOP_REASON_FILE" 2>/dev/null)"
  if [[ "$(cat "$STOP_FILE")" == source ]]; then
    log_error "Đã dừng: ${stop_why:-nguồn nhập liệu không được chọn, hoặc không có tác dụng trong ô gõ} (mã thoát 4)."; FAILED=4
  else
    log_error "Đã dừng: ${stop_why:-kiểm tra trước khi gõ không đạt (không có lý do ghi lại)} (mã thoát 3)."; FAILED=3
  fi
fi
if [[ $FAILED == 0 ]] && (( NO_ANSWER )); then log_detail "Đã gõ xong; không có đáp án (--keys không kèm --expect), nên không có kết quả đạt hay sai."; log_done
elif [[ $FAILED == 0 ]]; then log_ok "Mọi app cho đúng chữ mong đợi"; log_done; elif (( FAILED == 1 )); then log_error "Có app cho chữ khác chữ mong đợi (mã thoát 1)"
else log_error "Lượt chạy đã dừng, chưa đủ kết quả (mã thoát $FAILED)"; fi
exit $FAILED
