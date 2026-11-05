#!/usr/bin/env bash
# Builds the input method and installs it for the current user.
# Side effects: builds; unless --build-only: installs input method, kills processes
# Universal, Debug unless --release, into ~/Library/Input Methods; then it stops the old
# input method process so macOS loads the new one on the next key press.
#
# It does NOT register or enable the input source: that is the user's action in
# System Settings (N4). The steps are printed at the end.
#
# Usage:
#   scripts/dev/install-debug.sh               build, install, stop the old process
#   scripts/dev/install-debug.sh --build-only  build and check only, touch nothing outside the repo
#   scripts/dev/install-debug.sh --no-build    skip xcodegen and xcodebuild: check and install the
#                                          build already in build/DerivedData.noindex (for a
#                                          caller that has just built it, e.g. scripts/selftest/app-group.sh)
#   scripts/dev/install-debug.sh --release     Release instead of Debug: for day-to-day typing
#                                          (no get-task-allow, no per-key log, D8)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
DERIVED="$ROOT/build/DerivedData.noindex"
PROCESS_NAME="DauInputMethod"            # CFBundleExecutable of the input method
BUNDLE_NAME="$PROCESS_NAME.app"
DEST_DIR="$HOME/Library/Input Methods"

BUILD_ONLY=0
SKIP_BUILD=0
CONFIG=Debug
for arg in "$@"; do
  case "$arg" in
    --build-only) BUILD_ONLY=1 ;;
    --no-build) SKIP_BUILD=1 ;;
    # Day-to-day typing: Release has no get-task-allow (no debugger can attach) and no
    # per-key log or debug defaults keys (D8). Debug only while testing.
    --release) CONFIG=Release ;;
    -h|--help) awk 'NR==1{next} /^#/{sub(/^# ?/,""); print; next} {exit}' "$0"; exit 0 ;;
    *) echo "Tham số không hợp lệ: $arg (dùng --release, --build-only, --no-build hoặc không có tham số)" >&2; exit 2 ;;
  esac
done

if [[ "$SKIP_BUILD" == 1 && "$BUILD_ONLY" == 1 ]]; then
  echo "--no-build và --build-only không đi cùng nhau." >&2
  exit 2
fi
if [[ "$SKIP_BUILD" == 0 ]]; then
  if ! command -v xcodegen >/dev/null 2>&1; then
    echo "Cần XcodeGen: brew install xcodegen" >&2
    exit 1
  fi

  echo "==> Sinh Dau.xcodeproj"
  (cd "$ROOT" && xcodegen generate --quiet)

  echo "==> Build $CONFIG universal (scheme DauInputMethod)"
  xcodebuild \
    -project "$ROOT/Dau.xcodeproj" \
    -scheme DauInputMethod \
    -configuration "$CONFIG" \
    -destination 'generic/platform=macOS' \
    -derivedDataPath "$DERIVED" \
    -quiet \
    build
else
  echo "==> --no-build: dùng bản build có sẵn trong build/DerivedData.noindex"
fi

BUILT="$DERIVED/Build/Products/$CONFIG/$BUNDLE_NAME"
if [[ ! -d "$BUILT" ]]; then
  echo "Không tìm thấy $BUILT sau khi build." >&2
  exit 1
fi

echo "==> Kiểm tra bản build"
ARCHS="$(lipo -archs "$BUILT/Contents/MacOS/$PROCESS_NAME")"
echo "    kiến trúc: $ARCHS"
if [[ "$ARCHS" != *arm64* || "$ARCHS" != *x86_64* ]]; then
  echo "Bản build không phải universal (D1)." >&2
  exit 1
fi
codesign --verify --strict "$BUILT"
if codesign -d --entitlements - --xml "$BUILT" 2>/dev/null | grep -q "com.apple.security.network"; then
  echo "Bộ gõ có quyền mạng — trái N2. Dừng." >&2
  exit 1
fi
echo "    chữ ký hợp lệ, không có quyền mạng (N2)"
if [[ "$CONFIG" == Release ]] && codesign -d --entitlements - --xml "$BUILT" 2>/dev/null | grep -q "get-task-allow"; then
  echo "Bản Release còn get-task-allow (cho phép gắn debugger). Dừng." >&2
  exit 1
fi

if [[ "$BUILD_ONLY" == 1 ]]; then
  echo "==> --build-only: không cài. Bản build: $BUILT"
  exit 0
fi

echo "==> Cài vào $DEST_DIR"
mkdir -p "$DEST_DIR"
rm -rf "${DEST_DIR:?}/$BUNDLE_NAME"
ditto "$BUILT" "$DEST_DIR/$BUNDLE_NAME"
# ditto keeps the build's dates; a new date makes Finder drop the icon it cached for
# this path (an older build had no app icon).
touch "$DEST_DIR/$BUNDLE_NAME"

echo "==> Dừng tiến trình bộ gõ cũ (nếu đang chạy)"
if killall "$PROCESS_NAME" 2>/dev/null; then
  echo "    đã dừng $PROCESS_NAME; macOS sẽ chạy bản mới ở lần gõ tiếp theo"
else
  echo "    không có tiến trình $PROCESS_NAME đang chạy"
fi

echo
echo "Đã cài bản $CONFIG của Dấu. Các bước còn lại do bạn làm trên máy:"
cat <<'EOF'

  1. Dấu đã bật từ trước trên máy này: không phải làm gì thêm. Chuyển nguồn đầu vào ra
     rồi vào lại Dấu để macOS chạy bản vừa cài.
  2. Lần đầu trên máy này: bật bằng app chủ (build scheme Dau, mở Dau.app, bấm "Bật Dấu",
     rồi Allow trong hộp thoại của macOS). App xoá bộ đệm danh sách nguồn đầu vào trước
     khi đăng ký, nên không cần đăng xuất (D37). Thêm tay bằng "+" trong System Settings
     có thể không thấy Dấu, vì danh sách đó đọc bộ đệm cũ.
  3. Bật không được: làm theo màn "Chưa bật được" của app (tự thêm bằng "+"; đăng xuất
     một lần là đường lui, D37). Một ứng dụng vẫn không chọn được Dấu: đăng xuất rồi đăng
     nhập lại một lần.
  4. Dấu chỉ có "Dấu – Tiếng Việt" (D2); gõ tiếng Anh bằng U.S. sẵn có của macOS. Còn
     "Dấu – Tiếng Anh" từ bản cũ thì bỏ nó bằng "–".
  5. Chọn "Dấu – Tiếng Việt" trên menu nguồn đầu vào ở thanh menu, hoặc bằng phím tắt
     chuyển nguồn đầu vào của macOS.
  6. Tắt các bộ gõ tiếng Việt khác đang chạy (OpenKey, EVKey, GoTiengViet…) trước khi thử.
EOF
if [[ "$CONFIG" == Debug ]]; then
  cat <<'EOF'
  7. Gõ thử theo docs/COMPATIBILITY.md mục 4. Muốn lấy số đo: bật nhật ký từng phím bằng
     `defaults write -g DauPerfLog -bool true`, gõ, chạy scripts/perf/perf-report.sh, rồi tắt
     bằng `defaults delete -g DauPerfLog` (nhật ký có giờ và app của từng phím, D8).
EOF
else
  echo "  7. Gõ thử theo docs/COMPATIBILITY.md mục 4. Bản Release không ghi nhật ký từng phím (D8)."
fi
cat <<'EOF'

Gỡ bản thử: xoá ~/Library/Input Methods/DauInputMethod.app, bỏ "Dấu" bằng "–" trong System Settings › Keyboard › "All Input Sources" (trước khi xoá),
rồi đăng xuất.
EOF
