#!/bin/zsh
# Types lines into the user's own Ghostty window (their real shell and configuration) and records what the shell's line editor ended with.
# Side effects: takes the screen, changes input source
#
# Usage: scripts/research/terminal-underline/real-shell.sh <source-id> <label> <keys-line>...
#   source-id  input source to type with (Dấu: com.codefastlabs.dau.inputmethod.Dau.vi;
#              Apple's Telex: com.apple.inputmethod.VietnameseIM.VietnameseTelex), switched
#              to with macOS's "Select next source in Input menu" shortcut once Ghostty is
#              in front, as the user does (typing/run.sh, cycle_to_source)
#   label      prefix of each recorded line (dau, apple)
#   keys-line  keys of one line, typed 120 ms apart; ⌫ sends Delete
#
# Needs a Ghostty window at an idle zsh prompt. Each line: pastes ` print -r -- "<label>|`
# (pasted text does not go through the input method), types the keys, pastes
# `" >> <out>` and presses Return, so <out> holds exactly the line zsh accepted (DEL
# already applied by zle). The leading space keeps it out of the history when
# hist_ignore_space is set (oh-my-zsh sets it). Bringing Ghostty to the front is an
# activation of the input method, as when the user switches to it.
# Output: build/terminal-underline/real-shell.txt (appended). The clipboard is put back
# at the end. Exit status: 0 done; 3 Ghostty left the front (stopped); 4 the source did
# not switch.
# Measured with it: docs/research/TerminalAndUnderline.md, section 1.
set -uo pipefail
ROOT="${0:A:h:h:h:h}"
source $ROOT/scripts/lib/log.sh
source $ROOT/scripts/lib/swift-tool.sh
CLIP="$(dau_swift_tool clipboard $ROOT/scripts/selftest/typing/clipboard.swift)" || exit 1
SRC="$(dau_swift_tool input-source $ROOT/scripts/lib/input-source.swift)" || exit 1

OUT=$ROOT/build/terminal-underline/real-shell.txt; mkdir -p ${OUT:h}
WANT=$1 LABEL=$2; shift 2
SAVED=$(mktemp -t dau-clip)
$CLIP save $SAVED
trap '$CLIP restore $SAVED 2>/dev/null' EXIT

front() { osascript -e 'tell application "System Events" to get name of first process whose frontmost is true'; }
paste_text() { # text
  print -rn -- "$1" | pbcopy
  [[ "$(front)" == ghostty ]] || { log_error "Ghostty không ở trước, dừng"; exit 3; }
  osascript -e 'tell application "System Events" to keystroke "v" using command down'
  sleep 0.4
}
cycle_to() { # id
  local json key mods using="" n
  json="$(plutil -extract AppleSymbolicHotKeys.61 json -o - $HOME/Library/Preferences/com.apple.symbolichotkeys.plist)"
  [[ "$json" =~ '"parameters":\[[0-9]+,([0-9]+),([0-9]+)\]' ]] || { log_error "không đọc được phím tắt chuyển nguồn"; exit 3; }
  key=$match[1]; mods=$match[2]
  (( mods & 131072 )) && using+="shift down, "
  (( mods & 262144 )) && using+="control down, "
  (( mods & 524288 )) && using+="option down, "
  (( mods & 1048576 )) && using+="command down, "
  using="${using%, }"
  for n in {1..6}; do
    [[ "$($SRC current)" == $1 ]] && return 0
    osascript -e "tell application \"System Events\" to key code $key using {$using}"
    sleep 0.6
  done
  [[ "$($SRC current)" == $1 ]] || { log_error "không chuyển được sang $1"; exit 4; }
}

osascript -e 'tell application "Ghostty" to activate'
sleep 1
[[ "$(front)" == ghostty ]] || { log_error "Ghostty không ở trước, dừng"; exit 3; }
cycle_to $WANT
log_detail "nguồn: $($SRC current)"
for keys in "$@"; do
  paste_text " print -r -- \"$LABEL|"
  osascript - "$keys" <<'OSA' || { log_error "dừng giữa chừng"; exit 3; }
on run argv
  tell application "System Events"
    repeat with c in characters of (item 1 of argv)
      if (name of first process whose frontmost is true) is not "ghostty" then error "front"
      if (c as text) is "⌫" then
        key code 51
      else
        keystroke (c as text)
      end if
      delay 0.12
    end repeat
  end tell
end run
OSA
  sleep 0.5
  paste_text "\" >> '$OUT'"
  osascript -e 'tell application "System Events" to key code 36'
  sleep 0.8
done
log_ok "xong $LABEL"
