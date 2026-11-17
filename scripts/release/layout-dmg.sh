#!/bin/zsh
# Lays out the window of a read-write Dấu disk image with Finder: size, icon positions, background.
# Side effects: takes the screen
# The only script of the release that opens a Finder window: it mounts the image visibly and
# drives Finder with AppleScript for a few seconds (macOS has no public API for the layout:
# it lives in the image's .DS_Store, written by Finder). Run it on CI
# (scripts/release/build-release.sh --layout), not on the development Mac unless the user
# agreed on the time. It needs the Automation permission of the caller to control Finder.
#
# Usage: scripts/release/layout-dmg.sh RW_DMG
#   RW_DMG  a UDRW image made by build-release.sh: volume "Dấu" holding Dau.app, the
#           Applications link and .background/ with the background image.
# Geometry (docs/canvas/src/DmgWindow.dc.html): content 640×400 pt, so the window bounds are
# 640×428 with the title bar; Dấu icon at (160, 180), Applications at (480, 180), icons 128 pt.
# Exit status: 0 laid out and detached; 1 failed (the image is detached anyway).

set -uo pipefail
source "${${(%):-%x}:A:h:h}/lib/log.sh"

[[ $# == 1 && -f $1 ]] || log_die 2 "Cách dùng: layout-dmg.sh RW_DMG"
dmg=$1
volume="Dấu"

log_step "Gắn ảnh đĩa để Finder sắp xếp cửa sổ"
# Mounted under /Volumes by name: Finder addresses a disk by its name.
hdiutil attach "$dmg" -readwrite -noverify -noautoopen >/dev/null || log_die "Không gắn được $dmg"
trap 'hdiutil detach "/Volumes/$volume" -quiet 2>/dev/null' EXIT
[[ -d /Volumes/$volume ]] || log_die "Không thấy /Volumes/$volume sau khi gắn"

bg=$(ls /Volumes/$volume/.background/ 2>/dev/null | head -1)
if [[ -n $bg ]]; then bg_line="set background picture of viewOptions to file \".background:$bg\""
else bg_line="-- no background image"; log_warn "Không có ảnh nền trong .background: cửa sổ không có nền."; fi

osascript <<OSA
tell application "Finder"
  tell disk "$volume"
    open
    set current view of container window to icon view
    set toolbar visible of container window to false
    set statusbar visible of container window to false
    set the bounds of container window to {200, 120, 840, 548}
    set viewOptions to the icon view options of container window
    set arrangement of viewOptions to not arranged
    set icon size of viewOptions to 128
    set text size of viewOptions to 13
    $bg_line
    set position of item "Dau.app" of container window to {160, 180}
    set position of item "Applications" of container window to {480, 180}
    update without registering applications
    delay 2
    close
  end tell
end tell
OSA
status=$?
# Finder writes .DS_Store a moment after the window closes.
for _ in {1..20}; do [[ -f /Volumes/$volume/.DS_Store ]] && break; sleep 0.5; done
sync
if (( status != 0 )); then log_die "Finder không sắp xếp được cửa sổ (AppleScript thoát $status). Cần quyền Automation cho Finder?"; fi
[[ -f /Volumes/$volume/.DS_Store ]] || log_die "Finder không ghi .DS_Store: bố cục không được lưu."
log_ok "Bố cục đã ghi vào .DS_Store"
hdiutil detach "/Volumes/$volume" -quiet || log_die "Không tháo được /Volumes/$volume"
trap - EXIT
log_done "Đã sắp xếp cửa sổ ảnh đĩa"
