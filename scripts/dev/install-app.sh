#!/bin/zsh
# Builds Dấu.app and installs it into /Applications; the app then replaces the installed input method.
# Side effects: builds; unless --build-only: installs app, installs input method, kills processes, deletes data
# The only install script. Release unless --debug: Release is the build for day-to-day
# typing (no get-task-allow, no per-key log, D8); Debug only while measuring.
#
# 1. Builds scheme Dau (the app with the input method inside it, universal) and checks the
#    build before anything outside the repo is touched: each bundle holds only the icon set
#    its Info.plist names (an earlier build's other set, left by Xcode after DAU_OFFICIAL
#    changed, is removed by one clean rebuild; D25), the app's signature (--deep --strict)
#    and the input method inside it (dau_check_input_method, scripts/lib/build.sh).
#    --build-only stops here.
# 2. Quits a running Dấu.app normally. The new copy is written next to the installed one
#    first (a hidden sibling in /Applications), so a failed copy leaves the installed app
#    as it was; then the installed copy goes to the Trash with /usr/bin/trash (it can be
#    put back; no Finder, so no Automation prompt) and the new one is renamed into place.
#    It is then registered with LaunchServices: ditto alone does not register it, and
#    Spotlight and "Open With" miss an unregistered copy (HostApp, behind the input
#    menu's "Cài đặt Dấu…", also looks in /Applications itself: docs/ARCHITECTURE.md).
# 3. Runs `Dau --reconcile-input-method` from the copy now in /Applications, the owner
#    copy (D37): the app itself replaces the installed input method with the one inside
#    it, as it does at every launch, and stops the old input method process. The script
#    copies no input method. The command's line is printed; its exit status decides:
#      0, 3  the installed input method is the one inside the app: done
#      4     no input method installed: not an error. The first install is the user's
#            click on "Bật Dấu" in the app; the script installs and enables nothing (N4)
#      6     the installed input method's signature is wrong: not replaced; the user
#            clicks "Cài lại" in the app. The script exits 1
#      1, 5, 7, other  error: Dấu.app is in /Applications, the input method is unchanged.
#            The script exits 1
# 4. Opens Dấu.app again if it was running, then prints scripts/dev/dau-version.sh.
#
# Nothing is enabled or selected (N4).
#
# Usage:
#   scripts/dev/install-app.sh               build Release, install
#   scripts/dev/install-app.sh --debug       Debug instead of Release
#   scripts/dev/install-app.sh --build-only  build and check only, touch nothing outside the repo
#   scripts/dev/install-app.sh --no-build    skip xcodegen and xcodebuild: check and install the
#                                            build already in build/DerivedData.noindex (for a
#                                            caller that has just built it, e.g.
#                                            scripts/selftest/app-group.sh)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
source "$ROOT/scripts/lib/log.sh"
source "$ROOT/scripts/lib/wait.sh"
source "$ROOT/scripts/lib/build.sh"
DERIVED="$DAU_DERIVED"
DEST="/Applications/Dau.app"
LSREGISTER=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister

CONFIG=Release
BUILD_ONLY=0
SKIP_BUILD=0
for arg in "$@"; do
  case "$arg" in
    --debug) CONFIG=Debug ;;
    --build-only) BUILD_ONLY=1 ;;
    --no-build) SKIP_BUILD=1 ;;
    -h|--help) log_usage "$0"; exit 0 ;;
    *) log_die 2 "Tham số không hợp lệ: $arg (dùng --debug, --build-only, --no-build hoặc không có tham số)" ;;
  esac
done
if [[ "$SKIP_BUILD" == 1 && "$BUILD_ONLY" == 1 ]]; then
  log_die 2 "--no-build và --build-only không đi cùng nhau."
fi

if [[ "$SKIP_BUILD" == 0 ]]; then
  # dau_build stops before building when the keychain has no usable certificate.
  dau_build Dau "$CONFIG" || exit 1
else
  log_step "--no-build: dùng bản $CONFIG có sẵn trong build/DerivedData.noindex"
fi

APP="$DERIVED/Build/Products/$CONFIG/Dau.app"
EMBEDDED_IM="$APP/Contents/Library/Input Methods/DauInputMethod.app"
[[ -d "$APP" ]] || log_die "Không thấy $APP (bản $CONFIG chưa build)."

# --no-build installs whatever is in build/: say which commit that is, and when it is not
# the working tree's (same rule as scripts/build/stamp-build-commit.sh: "+" = uncommitted
# changes, and then nothing says whether the build holds them).
if [[ "$SKIP_BUILD" == 1 ]]; then
  built_commit="$(cat "$APP/Contents/Resources/BuildCommit.txt" 2>/dev/null || true)"
  tree_commit="$(git -C "$ROOT" rev-parse --short=7 HEAD 2>/dev/null || true)"
  [[ -n "$tree_commit" && -n "$(git -C "$ROOT" status --porcelain --untracked-files=no 2>/dev/null)" ]] && tree_commit+="+"
  log_detail "bản build: ${built_commit:-không có mã commit}; cây làm việc: ${tree_commit:-không rõ}"
  if [[ "$built_commit" != "$tree_commit" ]]; then
    log_warn "Bản $CONFIG trong build/ không phải của cây làm việc hiện tại: --no-build cài bản đã build, không build lại."
  elif [[ "$tree_commit" == *+ ]]; then
    log_warn "Cây làm việc có thay đổi chưa commit: không biết bản đã build có gồm chúng không."
  fi
fi

# D25: a bundle must hold only the icon set its Info.plist names. Xcode's incremental build
# keeps the other set's .icns after DAU_OFFICIAL changes (assetcatalog_output and the
# product bundle are never pruned), and AppKit then showed the standard icon on a
# development build (measured 11/11/2026, docs/PROGRESS.md). Prints the stray files.
stray_icons() { # bundle
  local named
  named=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIconFile' "$1/Contents/Info.plist" 2>/dev/null) || named=""
  local f
  for f in "$1"/Contents/Resources/*.icns(N); do
    [[ ${f:t:r} == ${named%.icns} ]] || print -r -- "${f#$DAU_ROOT/}"
  done
}
stray=("${(@f)$(stray_icons "$APP"; stray_icons "$EMBEDDED_IM")}")
stray=(${stray:#})
if (( ${#stray} )) && [[ "$SKIP_BUILD" == 0 ]]; then
  log_warn "Bản build còn biểu tượng của lần build trước: ${stray[*]}. Xoá đầu ra asset catalog cũ rồi build lại."
  rm -rf "$DERIVED"/Build/Intermediates.noindex/Dau.build/"$CONFIG"/*.build/assetcatalog_output \
         "$DERIVED/Build/Products/$CONFIG/Dau.app" "$DERIVED/Build/Products/$CONFIG/DauInputMethod.app"
  dau_build Dau "$CONFIG" || exit 1
  stray=("${(@f)$(stray_icons "$APP"; stray_icons "$EMBEDDED_IM")}")
  stray=(${stray:#})
fi
(( ${#stray} )) && log_die "Bản build có biểu tượng không đúng tên trong Info.plist: ${stray[*]} (D25): không cài."

log_step "Kiểm tra bản build"
if ! codesign --verify --deep --strict "$APP" 2>/dev/null; then
  log_error "Chữ ký của $APP không hợp lệ: không cài."
  log_hint "Xem chứng chỉ \"Apple Development\" trong Keychain Access (CONTRIBUTING.md)."
  exit 1
fi
log_ok "Dấu.app: chữ ký hợp lệ (--deep --strict)"
dau_check_input_method "$EMBEDDED_IM" "$CONFIG" || log_die "Bộ gõ nằm trong Dấu.app không đạt: không cài."

if [[ "$BUILD_ONLY" == 1 ]]; then
  log_step "--build-only: không cài. Bản build: $APP"
  log_done "Đã build Dấu.app"
  exit 0
fi

BUNDLE_ID=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$APP/Contents/Info.plist")

# Quit a running copy normally (never force quit) and remember to open it again.
was_running=0
if pgrep -f "$DEST/Contents/MacOS/" >/dev/null 2>&1; then
  was_running=1
  log_step "Thoát Dấu.app đang chạy"
  osascript -e "tell application id \"$BUNDLE_ID\" to quit" >/dev/null 2>&1 || true
  app_gone() { ! pgrep -f "$DEST/Contents/MacOS/" >/dev/null 2>&1; }
  wait_until 10 app_gone || true
  if pgrep -f "$DEST/Contents/MacOS/" >/dev/null 2>&1; then
    log_error "Dấu.app chưa thoát sau 10 giây: không cài."
    log_hint "Thoát app rồi chạy lại."
    exit 1
  fi
fi

# Copy first, swap after. The copy's name does not end in .app, so LaunchServices does not
# take it for an app while it is being written.
STAGED="${DEST:h}/.${DEST:t}.new-$$"
old_trashed=0
install_cleanup() {
  rm -rf "$STAGED"
  # Stopped between the Trash and the rename: /Applications has no Dấu.app now.
  if [[ "$old_trashed" == 1 && ! -e "$DEST" ]]; then
    log_error "Dừng giữa chừng: bản cũ đã vào Thùng rác, bản mới chưa vào $DEST."
    log_hint "Chạy lại script để cài, hoặc Put Back bản cũ từ Thùng rác."
  fi
}
trap install_cleanup EXIT
trap 'exit 130' INT TERM HUP
log_step "Chép bản mới cạnh $DEST"
ditto "$APP" "$STAGED"
if [[ -e "$DEST" || -L "$DEST" ]]; then
  log_step "Chuyển bản cũ vào Thùng rác"
  # Set before the move: stopped while trash runs, install_cleanup still sees that
  # /Applications lost its copy (it only speaks when $DEST is gone).
  old_trashed=1
  if ! /usr/bin/trash -s "$DEST"; then
    log_error "Không chuyển được $DEST vào Thùng rác: bản đã cài giữ nguyên."
    log_hint "Kéo $DEST vào Thùng rác bằng tay rồi chạy lại."
    exit 1
  fi
fi
log_step "Đặt bản mới vào $DEST và đăng ký với LaunchServices"
if ! mv "$STAGED" "$DEST"; then
  log_error "Không đổi tên $STAGED thành $DEST."
  exit 1   # install_cleanup says where the old copy is
fi
# Not fatal: the app is in place; only Spotlight and "Open With" may miss it for a while.
if ! "$LSREGISTER" -f "$DEST"; then
  log_warn "lsregister lỗi: Dấu.app đã vào $DEST nhưng LaunchServices có thể chưa biết bản này."
fi

# The app replaces the input method, not the script (D37). The binary is run directly,
# not through `open`, so its line and exit status come back (ReconcileCommand).
RECONCILE=("$DEST/Contents/MacOS/Dau" --reconcile-input-method)
log_step "Bộ gõ: Dấu.app trong /Applications so bộ gõ đã cài với bản nằm trong nó"
reconcile_status=0
reconcile_line="$("${RECONCILE[@]}")" || reconcile_status=$?
[[ -n "$reconcile_line" ]] && log_detail "$reconcile_line"
result=0
case "$reconcile_status" in
  0) log_ok "Bộ gõ đã cài đã là bản nằm trong Dấu.app vừa cài" ;;
  3) log_ok "Bộ gõ đã cài được thay bằng bản nằm trong Dấu.app vừa cài" ;;
  4)
    log_warn "Bộ gõ chưa cài trên tài khoản này: script không cài lần đầu và không bật gì (N4)."
    log_hint "Mở Dấu trong /Applications rồi bấm \"Bật Dấu\"."
    ;;
  6)
    log_error "Bộ gõ đã cài có chữ ký sai hoặc khác Team ID: không thay (D37). Dấu.app đã vào /Applications."
    log_hint "Mở Dấu trong /Applications rồi bấm \"Cài lại\"."
    result=1
    ;;
  *)
    retry="scripts/dev/install-app.sh --no-build"
    [[ "$CONFIG" == Debug ]] && retry+=" --debug"
    log_error "Dấu.app đã vào /Applications, còn bộ gõ đã cài thì CHƯA đổi (lệnh thoát với mã $reconcile_status)."
    log_hint "Chạy lại riêng bước này: ${RECONCILE[*]}" \
      "Hoặc cài lại từ bản đã build: $retry"
    result=1
    ;;
esac

if [[ "$was_running" == 1 ]]; then
  log_step "Mở lại Dấu.app"
  open "$DEST"
fi

log_step "Phiên bản đã cài"
"$ROOT/scripts/dev/dau-version.sh" || true
if [[ "$result" != 0 ]]; then
  log_die "$result" "Đã cài Dấu.app; bộ gõ chưa đổi (xem lỗi ở trên)."
fi
log_done "Đã cài Dấu.app"
