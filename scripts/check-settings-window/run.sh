#!/bin/zsh
# UI checks of the real Settings window (docs/UI-CHECKS.md).
#
# Usage: scripts/check-settings-window/run.sh <output-dir> [Dau.app]
#
# Copies the Debug build of Dau.app, re-signs the copy ad hoc without entitlements
# (the build is not sandboxed since D37; the copy also drops the App Group, as before),
# and runs it with --capture-window for every combination of
# scroll bar style (overlay, legacy "Always", system "Automatic") and scroll offset
# (0, 60 pt). Each run captures the 4 sections in light and dark mode off screen.
# Then it captures the onboarding window (onboarding/, onboarding-no-shortcut/) and the
# uninstall alerts (uninstall/).
# check.swift checks the captures and frames (a)–(h) and writes a summary grid.
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
# terminal. The window is put back at 740 × 560.
# Exit status 0 only if every check passes.
#
# The window is moved off screen but exists for a few seconds per run.
set -euo pipefail
here=${0:A:h}
out=${1:?output dir}
app=${2:-${here:h:h}/build/DerivedData/Build/Products/Debug/Dau.app}
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$out"

cp -R "$app" "$work/Dau.app"
cat > "$work/ent.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict><key>com.apple.security.get-task-allow</key><true/></dict></plist>
PLIST
codesign --force --sign - --entitlements "$work/ent.plist" "$work/Dau.app" >/dev/null 2>&1

for style in WhenScrolling Always Automatic; do
  for scroll in 0 60; do
    dir="$out/$style-$scroll"
    "$work/Dau.app/Contents/MacOS/Dau" --capture-window "$dir" --scroll "$scroll" \
      -AppleShowScrollBars "$style" >/dev/null 2>&1
  done
done

# The widest window the Settings scene allows (sidebar 232 + 744): the cards must
# still span the column (docs/UI-CHECKS.md item 1).
"$work/Dau.app/Contents/MacOS/Dau" --capture-window "$out/wide" --width 976 \
  -AppleShowScrollBars WhenScrolling >/dev/null 2>&1

# The onboarding window (steps 1, 2, 2 with Dấu still off, 2 not listed (logout),
# 2 after "Bật Dấu", 3; light and dark), on fixed
# services; once with the real input-source shortcut, once as if none were set.
"$work/Dau.app/Contents/MacOS/Dau" --capture-onboarding "$out/onboarding" >/dev/null 2>&1
"$work/Dau.app/Contents/MacOS/Dau" --capture-onboarding "$out/onboarding-no-shortcut" \
  --shortcut none >/dev/null 2>&1

# The uninstall alerts (D16, mockup "ConfirmDialogs"): shown as sheets on the Settings
# window, captured, dismissed; nothing is uninstalled.
"$work/Dau.app/Contents/MacOS/Dau" --capture-uninstall "$out/uninstall" >/dev/null 2>&1

swiftc -O -o "$work/check" "$here/check.swift"
result=0
"$work/check" "$out" || result=1

# The real window (docs/UI-CHECKS.md, "Cửa sổ thật").
swiftc -O -o "$work/ax-check" "$here/ax-check.swift"
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
