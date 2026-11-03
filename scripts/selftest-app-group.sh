#!/usr/bin/env bash
# Self test, without typing, of the settings path from the host app to the input method.
# Side effects: builds, changes input source, changes user settings; with --install also: installs input method, kills processes
# Does a setting saved by the host app reach the input method through the App Group
# suite and the Darwin notification?
#
#   1. Builds Debug (universal) into build/DerivedData.noindex (scheme Dau, which includes
#      the input method). By default the input method already installed in
#      ~/Library/Input Methods is used as it is and the script says so; only with
#      --install is the Debug build installed first (scripts/install-debug.sh --no-build,
#      which also stops the old input method process), so the build is not made twice.
#   2. Makes sure the input method runs. macOS launches it on demand, when a client
#      activates it; if it is not running, the helper reselects the Dấu input source,
#      which must already be enabled (the helper never enables or disables a source, N4),
#      and if that is not enough, `open -g -j` launches the bundle in the background.
#      The input source selected before the test is selected again at the end.
#   3. Waits for the input method's `event=settings-loaded` line: a process that has just
#      been launched may take several seconds before it reads the settings and starts
#      observing (measured 7 s on 30/10/2026), and a change saved before that is not
#      reported as a reload.
#   4. Runs `Dau --set-typing-method vni` (Debug flag, the app's real signature and App
#      Group entitlement; the host app is not sandboxed since D37), waits,
#      and checks the input method's log (subsystem <IM bundle ID>, category settings)
#      for `event=settings-reloaded … typingMethod=vni`. Then the same with telex, which
#      also checks that a new app process reads vni back (`previous=vni`): the value
#      reached disk, not only the first process's cache. The typing method found before
#      the test (`previous=` of the first call) is written back at the end, also when the
#      test fails or is interrupted.
#
# The "Dấu is enabled" check is cross-checked against com.apple.inputsources ›
# AppleEnabledThirdPartyInputSources (input-source.swift): TIS alone has been wrong.
#
# `synchronize=failed` from the app is only reported, not a failure: on macOS 27 the
# App Group suite's synchronize() returns false even when the write goes through
# (measured 30/10/2026: the input method and a new app process both read it back).
#
# Prints PASS or FAIL; exit status 0 only on PASS.
#
# Usage: scripts/selftest-app-group.sh [--install] [--no-build]
#   --install    install the Debug input method before the test (default: use what is installed)
#   --no-build   do not build; use build/DerivedData.noindex as it is (with --install, install
#                that build)
#
# Note: if macOS shows a dialog asking whether "Dấu" may access data from other apps, the
# script cannot answer it. Click "Allow" (Cho phép), then run the script again.
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
DERIVED="$ROOT/build/DerivedData.noindex"
PRODUCTS="$DERIVED/Build/Products/Debug"
APP_BIN="$PRODUCTS/Dau.app/Contents/MacOS/Dau"
IM_APP="$HOME/Library/Input Methods/DauInputMethod.app"
HELPER_SRC="$ROOT/scripts/lib/input-source.swift"
HELPER="$ROOT/build/selftest/input-source"
WAIT_SECONDS=2
LOG=/usr/bin/log            # zsh has a `log` builtin; always use the binary

BUILD=1
INSTALL=0
for arg in "$@"; do
  case "$arg" in
    --no-build) BUILD=0 ;;
    --install) INSTALL=1 ;;
    -h|--help) awk 'NR==1{next} /^#/{sub(/^# ?/,""); print; next} {exit}' "$0"; exit 0 ;;
    *) echo "Tham số không hợp lệ: $arg (dùng --install, --no-build)" >&2; exit 2 ;;
  esac
done

fail() { echo "FAIL: $*"; exit 1; }   # the EXIT trap restores the source and the setting

ORIGINAL_SOURCE=""
restore_source() {
  [[ -n "$ORIGINAL_SOURCE" && -x "$HELPER" ]] || return 0
  local now
  now="$("$HELPER" current 2>/dev/null || true)"
  if [[ "$now" != "$ORIGINAL_SOURCE" ]]; then
    "$HELPER" select "$ORIGINAL_SOURCE" && echo "    đã trả lại nguồn nhập liệu $ORIGINAL_SOURCE"
  fi
  ORIGINAL_SOURCE=""
}

# The typing method the user had (`previous=` of the first --set-typing-method call).
PREVIOUS_METHOD=""
restore_typing_method() {
  [[ -n "$PREVIOUS_METHOD" && -x "$APP_BIN" ]] || return 0
  local method="$PREVIOUS_METHOD"
  PREVIOUS_METHOD=""
  if "$APP_BIN" --set-typing-method "$method" >/dev/null 2>&1; then
    echo "    đã trả lại kiểu gõ $method"
  else
    echo "    CẢNH BÁO: không trả lại được kiểu gõ $method; kiểm tra trong Cài đặt của Dấu" >&2
  fi
}
cleanup() { restore_typing_method; restore_source; }
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

if [[ "$BUILD" == 1 ]]; then
  echo "==> Build Debug universal (Dau, gồm bộ gõ)"
  (cd "$ROOT" && xcodegen generate --quiet) || fail "xcodegen"
  xcodebuild -project "$ROOT/Dau.xcodeproj" -scheme Dau -configuration Debug \
    -destination 'generic/platform=macOS' -derivedDataPath "$DERIVED" -quiet build \
    || fail "build Dau"
fi
[[ -x "$APP_BIN" ]] || fail "không thấy $APP_BIN (chạy không có --no-build)"
if [[ "$INSTALL" == 1 ]]; then
  echo "==> Cài bộ gõ Debug (install-debug.sh --no-build; bản vừa build ở trên)"
  install_log="$("$ROOT/scripts/install-debug.sh" --no-build 2>&1)" || { echo "$install_log"; fail "install-debug.sh"; }
  echo "$install_log" | grep -E 'kiến trúc|chữ ký|đã dừng|không có tiến trình' | sed 's/^ */    /'
fi
[[ -d "$IM_APP" ]] || fail "chưa cài $IM_APP (chạy với --install, hoặc scripts/install-debug.sh)"
commit_of() { local f="$1/Contents/Resources/BuildCommit.txt"; [[ -f "$f" ]] && cat "$f" || echo "không có mã commit"; }
if [[ "$INSTALL" == 1 ]]; then
  echo "==> Bộ gõ thử: bản vừa cài ($(commit_of "$IM_APP"))"
else
  echo "==> Bộ gõ thử: bản ĐÃ CÀI sẵn, không cài lại (commit $(commit_of "$IM_APP"); Dau.app vừa build: $(commit_of "$PRODUCTS/Dau.app")). Muốn thử bản vừa build: thêm --install."
fi

IM_ID="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$IM_APP/Contents/Info.plist")"
SUBSYSTEM="$IM_ID"

echo "==> Helper chọn nguồn nhập liệu"
mkdir -p "$(dirname "$HELPER")"
if [[ ! -x "$HELPER" || "$HELPER_SRC" -nt "$HELPER" ]]; then
  xcrun swiftc -O -o "$HELPER" "$HELPER_SRC" || fail "biên dịch helper"
fi
ORIGINAL_SOURCE="$("$HELPER" current)" || fail "không đọc được nguồn nhập liệu hiện tại"
echo "    nguồn hiện tại: $ORIGINAL_SOURCE"

im_running() { pgrep -f "$IM_APP/Contents/MacOS/" >/dev/null; }

echo "==> Bảo đảm bộ gõ đang chạy"
for _ in 1 2 3 4; do im_running && break; sleep 0.5; done
if ! im_running; then
  # The helper cross-checks TIS with com.apple.inputsources and says on stderr when they
  # disagree (TIS alone has been wrong on macOS 27.2).
  enabled_ids="$("$HELPER" enabled "$IM_ID")"
  DAU_SOURCE="$(echo "$enabled_ids" | grep '\.vi$' | head -1)"
  [[ -n "$DAU_SOURCE" ]] || DAU_SOURCE="$(echo "$enabled_ids" | head -1)"
  if [[ -z "$DAU_SOURCE" ]]; then
    fail "nguồn nhập liệu Dấu chưa được bật (hoặc TIS và com.apple.inputsources không khớp, xem dòng trên). Thêm bằng \"+\" trong Cài đặt hệ thống › Bàn phím › Nguồn đầu vào (xem install-debug.sh), rồi chạy lại."
  fi
  # Measured (macOS 27.0.1): reselecting the already selected Dấu source launched the
  # input method once and did nothing the next time (TIS treats it as no change). The
  # fallback asks LaunchServices to launch the bundle in the background, which is how
  # macOS starts it anyway; no input source is touched.
  echo "    bộ gõ chưa chạy: chọn lại $DAU_SOURCE"
  "$HELPER" select "$DAU_SOURCE" || fail "không chọn được $DAU_SOURCE"
  for _ in $(seq 1 12); do im_running && break; sleep 0.25; done
  if ! im_running; then
    echo "    chọn lại không đủ: mở bộ gõ bằng LaunchServices (open -g -j)"
    open -g -j "$IM_APP" || fail "open $IM_APP"
    for _ in $(seq 1 20); do im_running && break; sleep 0.25; done
  fi
fi
im_running || fail "bộ gõ vẫn chưa chạy sau khi chọn nguồn Dấu"
IM_PID="$(pgrep -f "$IM_APP/Contents/MacOS/" | head -1)"
echo "    bộ gõ đang chạy (pid $IM_PID)"
# The Debug input method starts observing right after its event=settings-loaded line.
loaded=0
for _ in $(seq 1 30); do
  if "$LOG" show --last 10m --style compact --predicate \
      "subsystem == \"$SUBSYSTEM\" AND category == \"settings\" AND processID == $IM_PID" \
      2>/dev/null | grep -q 'event=settings-loaded'; then
    loaded=1; break
  fi
  sleep 0.5
done
[[ "$loaded" == 1 ]] || fail "bộ gõ (pid $IM_PID) chưa nạp cài đặt sau 15 giây"
echo "    bộ gõ đã nạp cài đặt, bắt đầu thử"

# Prints the settings log lines of the input method since $1 ("YYYY-MM-DD HH:MM:SS").
im_settings_log() {
  "$LOG" show --start "$1" --style compact \
    --predicate "subsystem == \"$SUBSYSTEM\" AND category == \"settings\"" 2>/dev/null \
    | grep 'event=' || true
}

# Explains a failure from the system log since $1: App Group refused, cfprefsd rejected.
explain() {
  local why
  why="$("$LOG" show --start "$1" --style compact --predicate \
    'process == "containermanagerd" OR process == "cfprefsd" OR (process == "kernel" AND eventMessage CONTAINS "Group Containers")' \
    2>/dev/null | grep -E 'REJECTED|rejecting write|deny\(1\) file-write-data .*Group Containers' | sed 's/^/      /' | head -6)"
  if [[ -n "$why" ]]; then
    echo "    Nhật ký hệ thống:"
    echo "$why"
  fi
}

PASS=1
VNI_OK=0
for method in vni telex; do
  echo "==> Dau --set-typing-method $method"
  start="$(date '+%Y-%m-%d %H:%M:%S')"
  out="$("$APP_BIN" --set-typing-method "$method" 2>&1)"
  status=$?
  echo "    app: $out"
  [[ $status == 0 ]] || { echo "    app thoát với mã $status"; PASS=0; }
  if [[ "$method" == vni ]]; then
    prev="$(echo "$out" | sed -n 's/.*previous=\([A-Za-z0-9]*\).*/\1/p' | head -1)"
    case "$prev" in
      telex|vni|simpleTelex) PREVIOUS_METHOD="$prev"; echo "    kiểu gõ trước khi thử: $prev (sẽ được trả lại ở cuối)" ;;
      *) echo "    CẢNH BÁO: không đọc được previous= từ app; kiểu gõ trước đó sẽ không được trả lại" ;;
    esac
  fi
  sleep "$WAIT_SECONDS"
  lines="$(im_settings_log "$start")"
  echo "    bộ gõ:"
  if [[ -n "$lines" ]]; then echo "$lines" | sed 's/^.*\] /      /'; else echo "      (không có dòng nào)"; fi
  if [[ "$out" == *"synchronize=failed"* ]]; then
    echo "    ghi chú: synchronize() trả về false (không phải lỗi, xem đầu script)"
  fi
  if [[ "$method" == telex ]]; then
    if [[ "$out" == *"previous=vni "* ]]; then
      echo "    OK: tiến trình app mới đọc lại được vni"
    else
      echo "    LỖI: tiến trình app mới không đọc lại được vni (giá trị không được lưu)"
      PASS=0
    fi
  fi
  if echo "$lines" | grep -q "event=settings-reloaded .*typingMethod=$method"; then
    if [[ "$method" == telex && "$VNI_OK" == 0 ]]; then
      echo "    bộ gõ đọc typingMethod=telex, nhưng telex cũng là mặc định khi không đọc được store: không phải bằng chứng"
      PASS=0
    else
      echo "    OK: bộ gõ đọc được typingMethod=$method"
      [[ "$method" == vni ]] && VNI_OK=1
    fi
  else
    echo "    LỖI: bộ gõ không đọc được typingMethod=$method"
    PASS=0
    explain "$start"
  fi
done

restore_typing_method
restore_source
echo
if [[ "$PASS" == 1 ]]; then
  echo "PASS: app chủ và bộ gõ dùng chung cài đặt qua App Group"
  exit 0
fi
cat <<'EOF'
FAIL: bộ gõ không nhận được cài đặt app chủ vừa lưu.
  - Nếu nhật ký có "REJECTED … should be prefixed by requestor's team ID" hoặc
    "rejecting write": bản ký ad-hoc (không có Team ID) không được dùng App Group trên
    macOS này; cần Team ID (project.yml DEVELOPMENT_TEAM).
  - Nếu macOS hiện hộp thoại hỏi cho "Dấu" truy cập dữ liệu của ứng dụng khác: script
    không bấm được. Bấm "Cho phép" (Allow) rồi chạy lại script.
EOF
exit 1
