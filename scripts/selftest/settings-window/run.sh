#!/bin/zsh
# UI checks of the Settings window, onboarding and uninstall alerts (docs/UI-CHECKS.md).
# Side effects: builds, takes the screen, kills processes, changes user settings
#
# Usage: scripts/selftest/settings-window/run.sh <output-dir> [Dau.app]
#
# Seven app launches, one after the other; each shows a window on screen for a while
# (do not click while it runs). Needs the Accessibility and Screen Recording permissions
# of the terminal. Changes no system setting: the scroll bar style and the appearance
# are arguments of that one launch (`-AppleShowScrollBars` lands in the app's argument
# domain; `--appearance` is a Debug flag of Dấu), never the global defaults.
#
# In-app captures, on a copy of the Debug app re-signed ad hoc without entitlements (so
# the copy has no App Group and its fake services cannot touch the user's settings):
#   1. --capture-onboarding                    onboarding/
#   2. --capture-onboarding --shortcut none    onboarding-no-shortcut/
#   3. --capture-uninstall                     uninstall/ (alerts laid out, nothing removed)
# The real Debug app, opened as the user opens it (`open -n`), measured from outside by
# ax-check.swift through the Accessibility API; screenshots are `screencapture -l` of the
# Settings window only:
#   4. overlay scroll bars                     real/                  ax-check --geometry
#   5. legacy scroll bars                      legacy/                ax-check --pixels
#   6. --not-enabled                           banner/                ax-check --banner
#   7. the other appearance, legacy bars       legacy-<light|dark>/   ax-check --pixels --sheet-shots
# Then check.swift checks the screenshots' pixels and the in-app captures.
# Tables: <dir>.txt per launch, check.txt. Exit status 0 only if every row is ok.
#
# Before each real launch the saved "NSWindow Frame settings" of com.codefastlabs.dau is
# deleted, so the window opens at the scene's default size (ax-check reads it before it
# moves anything); both saved frames are put back as they were at the end.
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
# The copy and the real app share Dấu's bundle ID, so AppKit saves the frames of the
# windows they show and the checker moves into Dấu's own preferences; a later normal
# launch then opened onboarding squeezed into a screen corner. Keep the saved frames as
# they were before the run and put them back at the end.
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

result=0

# A multi-file build takes top-level code only from a file named main.swift, so the
# script is copied to that name next to Reference.swift's compile.
build() {   # <script> <output>
  mkdir -p "$work/src-$2"
  cp "$here/$1" "$work/src-$2/main.swift"
  swiftc -swift-version 6 -O -o "$work/$2" "$here/Reference.swift" "$work/src-$2/main.swift"
}
build ax-check.swift ax-check
build check.swift check

# --- Launches 1–3: in-app captures ----------------------------------------------------

cp -R "$app" "$work/Dau.app"
cat > "$work/ent.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict><key>com.apple.security.get-task-allow</key><true/></dict></plist>
PLIST
codesign --force --sign - --entitlements "$work/ent.plist" "$work/Dau.app" >/dev/null 2>&1

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

# The onboarding window (steps 1, 2 before "Bật Dấu", 2 waiting for Allow, 2 failed,
# 2 done, 3; light and dark), on fixed services; once with the real
# input-source shortcut, once as if none were set.
capture "onboarding" --capture-onboarding "$out/onboarding"
capture "onboarding without shortcut" --capture-onboarding "$out/onboarding-no-shortcut" \
  --shortcut none
# The uninstall alerts and the "Bỏ Dấu khỏi Nguồn nhập liệu" sheet (D16, mockup
# "ConfirmDialogs", "UninstallRemoveSource"): laid out, captured, dismissed;
# nothing is uninstalled.
capture "uninstall alerts" --capture-uninstall "$out/uninstall"

# --- Launches 4–7: the real window ----------------------------------------------------

if [[ $(defaults read -g AppleInterfaceStyle 2>/dev/null) == Dark ]]; then
  current=dark other=light
else
  current=light other=dark
fi

real_window() {   # <dir name> <appearance> <ax-check modes…> -- <app arguments…>
  local name=$1 look=$2
  shift 2
  local modes=()
  while [[ $1 != -- ]]; do modes+=($1); shift; done
  shift
  local dir="$out/$name"
  mkdir -p "$dir"
  # The window opens at the scene's default size only without a saved frame.
  defaults delete $frames_domain "NSWindow Frame settings" >/dev/null 2>&1 || true
  local before=$(pgrep -f "$app/Contents/MacOS/Dau" | sort)
  # --settings-window goes last: launched as `--settings-window --appearance light`
  # (or any flag-value pair after it) the app opened no window at all, while
  # `--appearance light --settings-window` does (measured on Dấu 03/11/2026). AppKit
  # pairs each dash argument with the next one, so `--settings-window` takes
  # `--appearance` and `light` is left alone; a windowless test app was handed that
  # leftover as a file to open (`application(_:openFiles:)`). The 8 argument sets measured
  # on Dấu fit this; that SwiftUI then opens no window is not measured. Put every app
  # flag that takes a value (`-AppleShowScrollBars`, `--appearance`) before --settings-window.
  open -n "$app" --args "$@" --settings-window
  local pid=""
  for i in {1..50}; do
    pid=$(comm -13 <(echo "$before") <(pgrep -f "$app/Contents/MacOS/Dau" | sort) | tail -1)
    [[ -n $pid ]] && break
    sleep 0.2
  done
  if [[ -z $pid ]]; then
    echo "HARNESS real window ($name): the app did not start; not a UI result" | tee "$dir.txt"
    return 1
  fi
  local rc=0
  "$work/ax-check" "$pid" "$dir" "$look" $modes > "$dir.txt" || rc=1
  echo "$name:"
  tail -3 "$dir.txt" | sed 's/^/    /'
  kill "$pid" 2>/dev/null
  # Let it quit before the next launch deletes the saved frame again.
  for i in {1..25}; do kill -0 "$pid" 2>/dev/null || break; sleep 0.2; done
  return $rc
}

real_window real $current --geometry -- -AppleShowScrollBars WhenScrolling || result=1
real_window legacy $current --pixels -- -AppleShowScrollBars Always || result=1
real_window banner $current --banner -- -AppleShowScrollBars WhenScrolling --not-enabled || result=1
real_window legacy-$other $other --pixels --sheet-shots -- \
  -AppleShowScrollBars Always --appearance $other || result=1

# --- Pixels of the screenshots, in-app captures ----------------------------------------

"$work/check" "$out" overlay:real legacy:legacy legacy:legacy-$other > "$out/check.txt" || result=1
echo "check:"
tail -3 "$out/check.txt" | sed 's/^/    /'
exit $result
