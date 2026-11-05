#!/usr/bin/env bash
# Builds Dấu.app (the host app: Settings, onboarding) and installs it into /Applications.
# Side effects: builds, installs app, kills processes, deletes data
# Release unless --debug. The installed copy goes to the Trash through Finder (it can be
# put back), the new one is copied with ditto and registered with LaunchServices:
# ditto alone does not register it, and then the input menu's "Cài đặt Dấu…" finds no
# readable copy and opens nothing (measured 05/11/2026; HostApp now also scans
# /Applications, but other system lists such as Spotlight and "Open With" still need the
# registration). A running Dấu.app is quit normally first and opened again at the end.
#
# The input method is a separate step (scripts/dev/install-input-method.sh); --with-input-method
# runs it with the same configuration first. Nothing is enabled or selected (N4).
#
# Usage:
#   scripts/dev/install-app.sh                      build Release, install the app
#   scripts/dev/install-app.sh --debug              Debug instead of Release
#   scripts/dev/install-app.sh --with-input-method  also build and install the input method
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=../lib/build.sh
source "$ROOT/scripts/lib/build.sh"
DERIVED="$DAU_DERIVED"
DEST="/Applications/Dau.app"
LSREGISTER=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister

CONFIG=Release
WITH_IM=0
for arg in "$@"; do
  case "$arg" in
    --debug) CONFIG=Debug ;;
    --with-input-method) WITH_IM=1 ;;
    -h|--help) awk 'NR==1{next} /^#/{sub(/^# ?/,""); print; next} {exit}' "$0"; exit 0 ;;
    *) echo "Tham số không hợp lệ: $arg (dùng --debug, --with-input-method hoặc không có tham số)" >&2; exit 2 ;;
  esac
done

# Before the input method step too, so a missing certificate stops before anything is built.
dau_require_signing_identity || exit 1

if [[ "$WITH_IM" == 1 ]]; then
  im_args=()
  [[ "$CONFIG" == Release ]] && im_args+=(--release)
  "$ROOT/scripts/dev/install-input-method.sh" ${im_args[@]+"${im_args[@]}"}
fi

dau_build Dau "$CONFIG" || exit 1

APP="$DERIVED/Build/Products/$CONFIG/Dau.app"
[[ -d "$APP" ]] || { echo "Không thấy $APP sau khi build." >&2; exit 1; }
if ! codesign --verify --deep --strict "$APP" 2>/dev/null; then
  echo "Chữ ký của $APP không hợp lệ: không cài. Xem chứng chỉ \"Apple Development\" trong Keychain Access (CONTRIBUTING.md)." >&2
  exit 1
fi
BUNDLE_ID=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$APP/Contents/Info.plist")

# Quit a running copy normally (never force quit) and remember to open it again.
was_running=0
if pgrep -f "$DEST/Contents/MacOS/" >/dev/null 2>&1; then
  was_running=1
  echo "==> Thoát Dấu.app đang chạy"
  osascript -e "tell application id \"$BUNDLE_ID\" to quit" >/dev/null 2>&1 || true
  for _ in {1..50}; do
    pgrep -f "$DEST/Contents/MacOS/" >/dev/null 2>&1 || break
    sleep 0.2
  done
  if pgrep -f "$DEST/Contents/MacOS/" >/dev/null 2>&1; then
    echo "Dấu.app chưa thoát sau 10 giây: không cài. Thoát app rồi chạy lại." >&2
    exit 1
  fi
fi

if [[ -e "$DEST" ]]; then
  echo "==> Chuyển bản cũ vào Thùng rác"
  osascript -e "tell application \"Finder\" to delete POSIX file \"$DEST\"" >/dev/null
fi
echo "==> Chép vào $DEST và đăng ký với LaunchServices"
ditto "$APP" "$DEST"
"$LSREGISTER" -f "$DEST"

if [[ "$was_running" == 1 ]]; then
  echo "==> Mở lại Dấu.app"
  open "$DEST"
fi

echo
"$ROOT/scripts/dev/dau-version.sh"
