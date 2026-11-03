#!/bin/zsh
# UI checks of the real Settings window (docs/UI-CHECKS.md).
# Side effects: builds, takes the screen, kills processes
#
# Usage: scripts/selftest/settings-window/run.sh <output-dir> [Dau.app]
#
# Copies the Debug build of Dau.app, re-signs the copy ad hoc without entitlements
# (the build is not sandboxed since D37; the copy also drops the App Group, as before),
# and runs it with --capture-window for every combination of
# scroll bar style (overlay, legacy "Always", system "Automatic") and scroll offset
# (0, 60 pt). Each run captures the 4 sections in light and dark mode off screen.
# Then it captures the onboarding window (onboarding/, onboarding-no-shortcut/) and the
# uninstall alerts (uninstall/).
# check.swift checks the captures and frames (a)–(h) and writes a summary grid. Both
# scripts are compiled with Reference.swift, which holds every pass value.
# Last, the real window: the Debug app itself is launched normally (no off-screen
# capture code runs; `--settings-window` only keeps the onboarding closed and the
# installed input method untouched), and ax-check.swift reads its frames through the
# Accessibility API on every display and compares them with System Settings (real/),
# opens the add-rule sheet ("+" on Ứng dụng) through accessibility, checks it,
# captures it empty and with a row selected and closes it with Huỷ (nothing is added);
# once more with the "Dấu chưa được bật" banner (real-banner/), and once with the app
# alone in the appearance the system is not in (`--appearance`, Debug only: sets this
# app's appearance; the system appearance is not changed) for the sheet only
# (real-sheet-light/ or real-sheet-dark/). Needs the Accessibility permission of the
# terminal. The window is put back at its starting size.
# A --capture step that fails is named on the screen (with the end of its output) and the
# exit status is 1; the later steps still run. Exit status 0 only if every check passes.
#
# The window is moved off screen but exists for a few seconds per run.
set -euo pipefail
here=${0:A:h}
out=${1:?output dir}
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
# Absolute: the copy is made from it and pgrep matches its full path (a relative argument
# never matched the launched process).
app=${2:-${here:h:h:h}/build/DerivedData.noindex/Build/Products/Debug/Dau.app}
app=${app:A}
[[ -d $app ]] || { echo "Không thấy $app (build Debug trước, hoặc truyền đường dẫn Dau.app)" >&2; exit 2; }
work=$(mktemp -d)
lsregister=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister
# Running the copy registers it with LaunchServices; unregister it before deleting it,
# or Spotlight and "Open With" keep listing a second Dấu.app with a blank icon.
# The copy shares Dấu's bundle ID, so AppKit saves the frames of the windows it moves off
# screen (and the real-window part moves) into Dấu's own preferences; the next normal
# launch then opened onboarding squeezed into a screen corner. Keep the saved frames
# as they were before the run and put them back at the end.
frames_domain=com.codefastlabs.dau
frame_keys=("NSWindow Frame onboarding" "NSWindow Frame settings")
typeset -A saved_frames
for k in $frame_keys; do
  v=$(defaults read $frames_domain "$k" 2>/dev/null) && saved_frames[$k]=$v
done
restore_frames() {
  for k in $frame_keys; do
    if (( ${+saved_frames[$k]} )); then
      defaults write $frames_domain "$k" -string "${saved_frames[$k]}"
    else
      defaults delete $frames_domain "$k" >/dev/null 2>&1
    fi
  done
}
cleanup() {
  [[ -d "$work/Dau.app" ]] && "$lsregister" -u "$work/Dau.app" >/dev/null 2>&1
  rm -rf "$work"
  restore_frames
}
trap cleanup EXIT
mkdir -p "$out"

cp -R "$app" "$work/Dau.app"
cat > "$work/ent.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict><key>com.apple.security.get-task-allow</key><true/></dict></plist>
PLIST
codesign --force --sign - --entitlements "$work/ent.plist" "$work/Dau.app" >/dev/null 2>&1

result=0
# Runs the copy with the given arguments; a failure names the step and shows the end of
# the app's output instead of ending the script silently.
capture() {   # <step name> <Dau arguments…>
  local step=$1 rc=0
  shift
  "$work/Dau.app/Contents/MacOS/Dau" "$@" >"$work/capture.log" 2>&1 || rc=$?
  if (( rc != 0 )); then
    echo "FAIL capture ($step): Dau $* — exit status $rc"
    tail -5 "$work/capture.log" | sed 's/^/    /'
    result=1
  fi
}

for style in WhenScrolling Always Automatic; do
  for scroll in 0 60; do
    dir="$out/$style-$scroll"
    capture "window $style scroll $scroll" --capture-window "$dir" --scroll "$scroll" \
      -AppleShowScrollBars "$style"
  done
done

# The widest window the Settings scene allows (Reference.maxWindowWidth, which check
# (h) verifies against this width): the cards must still span the column
# (docs/UI-CHECKS.md item 1).
capture "window wide" --capture-window "$out/wide" --width 976 \
  -AppleShowScrollBars WhenScrolling

# The onboarding window (steps 1, 2, 2 with Dấu still off, 2 not listed (logout),
# 2 after "Bật Dấu", 3; light and dark), on fixed
# services; once with the real input-source shortcut, once as if none were set.
capture "onboarding" --capture-onboarding "$out/onboarding"
capture "onboarding without shortcut" --capture-onboarding "$out/onboarding-no-shortcut" \
  --shortcut none

# The uninstall alerts (D16, mockup "ConfirmDialogs"): shown as sheets on the Settings
# window, captured, dismissed; nothing is uninstalled.
capture "uninstall alerts" --capture-uninstall "$out/uninstall"

# A multi-file build takes top-level code only from a file named main.swift, so the
# script is copied to that name next to Reference.swift's compile.
build() {   # <script> <output>
  mkdir -p "$work/src-$2"
  cp "$here/$1" "$work/src-$2/main.swift"
  swiftc -swift-version 6 -O -o "$work/$2" "$here/Reference.swift" "$work/src-$2/main.swift"
}
build check.swift check
"$work/check" "$out" || result=1

# The real window (docs/UI-CHECKS.md, "Cửa sổ thật").
build ax-check.swift ax-check
real_window() {   # <output-dir> <ax-check flag or ""> [app arguments…]
  local dir=$1 flag=$2
  shift 2
  local before=$(pgrep -f "$app/Contents/MacOS/Dau" | sort)
  open -n "$app" --args --settings-window "$@"
  local pid=""
  for i in {1..50}; do
    pid=$(comm -13 <(echo "$before") <(pgrep -f "$app/Contents/MacOS/Dau" | sort) | tail -1)
    [[ -n $pid ]] && break
    sleep 0.2
  done
  [[ -z $pid ]] && { echo "FAIL real window: app did not start"; return 1; }
  local rc=0
  "$work/ax-check" "$pid" "$dir" ${flag:+$flag} > "$dir.txt" || rc=1
  tail -3 "$dir.txt"
  kill "$pid" 2>/dev/null
  return $rc
}
# The appearance the system is not in, for the sheet pass of this app only.
if [[ $(defaults read -g AppleInterfaceStyle 2>/dev/null) == Dark ]]; then
  other=light
else
  other=dark
fi
other_dir=real-sheet-$other
mkdir -p "$out/real" "$out/real-banner" "$out/$other_dir"
real_window "$out/real" "" || result=1
real_window "$out/real-banner" --banner --not-enabled || result=1
real_window "$out/$other_dir" --sheet-only --appearance "$other" || result=1
exit $result
