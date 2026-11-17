#!/bin/zsh
# Checks a release build of Dấu.app: icon, symbols, Sparkle keys, input method, signature (D7, D25, N2).
# Side effects: none
#
# Usage:
#   scripts/release/check-build.sh APP --feed URL [--archive XCARCHIVE] [--signed]
#     APP        the Dau.app to check (from an archive, an export or a mounted DMG).
#     --feed     the SUFeedURL the build must carry (the official one, D7, or the
#                unreachable one of an unsigned build, scripts/release/build-release.sh).
#     --archive  also check that the archive holds the dSYMs of the app and the input method.
#     --signed   also check the Developer ID signature, Gatekeeper (spctl) and the stapled
#                notarization ticket (stapler validate).
# Env: DAU_SPARKLE_PUBLIC_KEY, when set, must equal the SUPublicEDKey in the build.
# Exit status: 0 every check passed; 1 at least one failed; 2 bad usage.
#
# What is checked (Roadmap, M7): CFBundleIconName of the app and the input method is
# AppIcon, not AppIconDev (D25); both binaries are universal (D1) and stripped (nm: no local
# symbols; an archive strips, a plain build does not); SUFeedURL and SUPublicEDKey are in
# the app, SUEnableSystemProfiling is false (D8), and neither is in the input method;
# Sparkle is linked by the app only (N2); the input method passes dau_check_input_method.

set -uo pipefail
source "${${(%):-%x}:A:h:h}/lib/build.sh"

app="" feed="" archive="" signed=0
while (( $# )); do
  case $1 in
    --feed)    feed=${2-}; shift 2 || log_die 2 "--feed cần một URL" ;;
    --archive) archive=${2-}; shift 2 || log_die 2 "--archive cần một đường dẫn" ;;
    --signed)  signed=1; shift ;;
    -h|--help) log_usage "${(%):-%x}"; exit 0 ;;
    -*)        log_die 2 "Tuỳ chọn lạ: $1" ;;
    *)         [[ -z $app ]] || log_die 2 "Chỉ một APP"; app=$1; shift ;;
  esac
done
[[ -d $app && -n $feed ]] || log_die 2 "Cần APP và --feed (xem --help)."

fails=0
fail() { log_error "$1"; fails=$(( fails + 1 )); }
plist() { /usr/libexec/PlistBuddy -c "Print :$2" "$1/Contents/Info.plist" 2>/dev/null; }

im="$app/Contents/Library/Input Methods/DauInputMethod.app"
app_bin="$app/Contents/MacOS/Dau"
im_bin="$im/Contents/MacOS/DauInputMethod"

log_step "Kiểm bản build: $app"

for b in "$app" "$im"; do
  icon=$(plist "$b" CFBundleIconName)
  if [[ $icon == AppIcon ]]; then log_ok "${b:t}: CFBundleIconName = AppIcon (D25)"
  else fail "${b:t}: CFBundleIconName = '${icon}', cần AppIcon (D25)"; fi
done

for bin in "$app_bin" "$im_bin"; do
  archs=$(lipo -archs "$bin" 2>/dev/null)
  if [[ $archs == *arm64* && $archs == *x86_64* ]]; then log_ok "${bin:t}: universal ($archs)"
  else fail "${bin:t}: không universal ('${archs}', D1)"; fi
  # Local symbols: nm lists each as lowercase t/s/d/b/... A stripped binary keeps only the
  # exported (uppercase) ones, plus indirect/undefined entries. Counted in the shell.
  locals=$(nm -a "$bin" 2>/dev/null | awk 'NF >= 3 && $2 ~ /^[a-z]$/ && $2 != "u"' | wc -l | tr -d ' ')
  if (( locals == 0 )); then log_ok "${bin:t}: đã lược ký hiệu cục bộ (nm)"
  else fail "${bin:t}: còn $locals ký hiệu cục bộ (nm); bản archive phải lược"; fi
done

got_feed=$(plist "$app" SUFeedURL) key=$(plist "$app" SUPublicEDKey)
[[ $got_feed == $feed ]] && log_ok "SUFeedURL = $feed" || fail "SUFeedURL = '${got_feed}', cần $feed"
if [[ -n $key ]]; then log_ok "SUPublicEDKey có mặt"; else fail "SUPublicEDKey trống hoặc thiếu"; fi
if [[ -n ${DAU_SPARKLE_PUBLIC_KEY-} && $key != "$DAU_SPARKLE_PUBLIC_KEY" ]]; then
  fail "SUPublicEDKey khác DAU_SPARKLE_PUBLIC_KEY"
fi
[[ $(plist "$app" SUEnableSystemProfiling) == false ]] && log_ok "SUEnableSystemProfiling = false (D8)" \
  || fail "SUEnableSystemProfiling không phải false (D8)"
if [[ -n $(plist "$im" SUFeedURL)$(plist "$im" SUPublicEDKey) ]]; then fail "Bộ gõ mang khoá Sparkle (N2)"
else log_ok "Bộ gõ không mang khoá Sparkle"; fi

if [[ -d $app/Contents/Frameworks/Sparkle.framework ]]; then log_ok "Sparkle.framework nằm trong app chủ"
else fail "Không thấy Sparkle.framework trong app chủ"; fi
if [[ -d $im/Contents/Frameworks/Sparkle.framework ]] || otool -L "$im_bin" | grep -qi sparkle; then
  fail "Bộ gõ link Sparkle (N2)"
else log_ok "Bộ gõ không link Sparkle (N2)"; fi

codesign --verify --deep --strict "$app" 2>/dev/null && log_ok "Chữ ký của app hợp lệ (--deep --strict)" \
  || fail "Chữ ký của app không hợp lệ"
dau_check_input_method "$im" Release || fails=$(( fails + 1 ))

if [[ -n $archive ]]; then
  for d in Dau DauInputMethod; do
    if [[ -d $archive/dSYMs/$d.app.dSYM ]]; then log_ok "dSYM của $d có trong archive"
    else fail "Archive thiếu dSYM của $d"; fi
  done
fi

if (( signed )); then
  auth=$(codesign -dvv "$app" 2>&1)
  if [[ $auth == *"Authority=Developer ID Application"* ]]; then log_ok "Ký bằng Developer ID Application"
  else fail "Không ký bằng Developer ID Application"; fi
  if [[ $auth == *flags=*runtime* ]]; then log_ok "Hardened runtime bật"; else fail "Hardened runtime tắt"; fi
  if spctl --assess --type execute --verbose=2 "$app" >/dev/null 2>&1; then log_ok "spctl chấp nhận app"
  else fail "spctl từ chối app"; fi
  if xcrun stapler validate "$app" >/dev/null 2>&1; then log_ok "Vé notarize đã đính kèm app (stapler validate)"
  else fail "App chưa có vé notarize (stapler validate)"; fi
fi

if (( fails )); then log_error "$fails điều không đạt."; exit 1; fi
log_ok "Bản build đạt"
