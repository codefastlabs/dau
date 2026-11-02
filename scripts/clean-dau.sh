#!/bin/zsh
# Removes every trace of Dấu from this user account, so an install test (M5 T4) starts
# from a machine that never had it.
#
# Usage:
#   scripts/clean-dau.sh         list what would be removed; changes nothing
#   scripts/clean-dau.sh --yes   remove exactly what the list shows, then say to log out
#
# Covers the bundle IDs of Dấu (com.codefastlabs.dau…) and of the M0 placeholder
# (com.example.dau…):
#   - running Dấu / input method processes (quit, then ended);
#   - /Applications/Dau.app and ~/Library/Input Methods/DauInputMethod.app (to the Trash
#     through Finder, so they can be taken back);
#   - sandbox containers, App Group containers, preference files, saved state, caches;
#   - Dấu's entries in the input source preferences: com.apple.inputsources
#     › AppleEnabledThirdPartyInputSources (where macOS keeps third-party sources that are
#     enabled) and com.apple.HIToolbox › AppleEnabledInputSources / AppleInputSourceHistory.
#     Only entries whose Bundle ID is Dấu's are removed; every other input source stays;
#   - LaunchServices registrations of any Dau.app / DauInputMethod.app copy;
#   - the global debug defaults keys DauPerfLog and DauDebugForceUnderline.
#
# Run it yourself: it changes input source settings and deletes app data, which the
# assistant does not do on its own. Then log out and back in: macOS keeps a catalog of
# input sources per login session and forgets Dấu only at the next login.
set -u
setopt null_glob

DO=0
case "${1:-}" in
  "") ;;
  --yes) DO=1 ;;
  -h|--help) sed -n '2,24p' "$0"; exit 0 ;;
  *) print -u2 "Tham số không hợp lệ: $1 (không tham số để xem, --yes để xoá)"; exit 2 ;;
esac

ID_PATTERN='^com\.(codefastlabs|example)\.dau'
LIB="$HOME/Library"
LSREGISTER=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister
found=0
note() { print -r -- "  $1"; found=1 }

# --- what is there -----------------------------------------------------------------

print "Tiến trình:"
procs=(${(f)"$(pgrep -fl 'Dau\.app/Contents/MacOS/Dau$|DauInputMethod\.app/Contents/MacOS/DauInputMethod' 2>/dev/null)"})
for p in $procs; do note "$p"; done

print "Ứng dụng và bộ gõ:"
bundles=()
for b in /Applications/Dau.app "/Applications/Dấu.app" "$LIB/Input Methods/DauInputMethod.app"; do
  [[ -e "$b" ]] && { bundles+=("$b"); note "$b"; }
done

print "Dữ liệu của app:"
data=()
for d in "$LIB"/Containers/com.codefastlabs.dau* "$LIB"/Containers/com.example.dau* \
         "$LIB/Group Containers/"*codefastlabs.dau* "$LIB/Group Containers/"*example.dau* \
         "$LIB"/Preferences/com.codefastlabs.dau*.plist "$LIB"/Preferences/com.example.dau*.plist \
         "$LIB/Saved Application State/"com.codefastlabs.dau* "$LIB/Saved Application State/"com.example.dau* \
         "$LIB"/Caches/com.codefastlabs.dau* "$LIB"/HTTPStorages/com.codefastlabs.dau*; do
  data+=("$d"); note "${d#$HOME/}"
done

# Input source preferences: count Dấu's entries per array, without changing anything.
inputsource_entries() { # domain key
  defaults export "$1" - 2>/dev/null | /usr/bin/python3 -I -c '
import plistlib, re, sys
data = plistlib.loads(sys.stdin.buffer.read() or plistlib.dumps({}))
n = sum(1 for e in data.get(sys.argv[1], []) if isinstance(e, dict) and re.match(sys.argv[2], str(e.get("Bundle ID", ""))))
print(n)' "$2" "$ID_PATTERN"
}
print "Nguồn nhập liệu:"
prefs=()
for spec in "com.apple.inputsources AppleEnabledThirdPartyInputSources" \
            "com.apple.HIToolbox AppleEnabledInputSources" \
            "com.apple.HIToolbox AppleInputSourceHistory"; do
  n=$(inputsource_entries ${=spec})
  if [[ -n $n && $n != 0 ]]; then prefs+=("$spec"); note "${spec/ / › }: $n mục của Dấu"; fi
done
selected=$(defaults export com.apple.HIToolbox - 2>/dev/null | /usr/bin/python3 -I -c '
import plistlib, re, sys
data = plistlib.loads(sys.stdin.buffer.read() or plistlib.dumps({}))
print(any(re.match(sys.argv[1], str(e.get("Bundle ID", ""))) for e in data.get("AppleSelectedInputSources", []) if isinstance(e, dict)))' "$ID_PATTERN")
[[ $selected == True ]] && note "Dấu đang là nguồn được chọn: chuyển sang bàn phím khác trước (menu nguồn nhập liệu)."

print "Đăng ký LaunchServices:"
registered=(${(f)"$("$LSREGISTER" -dump 2>/dev/null | grep -E '^path: .*/(Dau|DauInputMethod)\.app \(0x' | sed -E 's/^path: +//; s/ \(0x[0-9a-f]+\)$//')"})
for r in $registered; do note "$r"; done

print "Khoá defaults gỡ lỗi:"
keys=()
for k in DauPerfLog DauDebugForceUnderline; do
  defaults read -g "$k" >/dev/null 2>&1 && { keys+=("$k"); note "-g $k"; }
done

if (( ! found )); then
  print "\nKhông còn gì của Dấu. Nếu vừa gỡ, đăng xuất rồi đăng nhập lại một lần."
  exit 0
fi
if (( ! DO )); then
  print "\nChưa xoá gì. Chạy lại với --yes để xoá đúng danh sách trên."
  exit 0
fi
if [[ $selected == True ]]; then
  print -u2 "\nDấu đang được chọn: chuyển sang bàn phím khác rồi chạy lại."
  exit 1
fi

# --- remove --------------------------------------------------------------------------

print "\nĐang xoá…"
if (( ${#procs} )); then
  osascript -e 'tell application id "com.codefastlabs.dau" to quit' >/dev/null 2>&1
  sleep 1
  pkill -f 'Dau\.app/Contents/MacOS/Dau$' 2>/dev/null
  pkill -f 'DauInputMethod\.app/Contents/MacOS/DauInputMethod' 2>/dev/null
fi
for b in $bundles; do
  if osascript -e "tell application \"Finder\" to delete (POSIX file \"$b\" as alias)" >/dev/null 2>&1; then
    print -r -- "  vào Thùng rác: $b"
  else
    rm -rf -- "$b" && print -r -- "  đã xoá (Finder không chuyển được vào Thùng rác): $b"
  fi
done
for d in $data; do rm -rf -- "$d" && print -r -- "  đã xoá: ${d#$HOME/}"; done
for spec in $prefs; do
  domain=${spec%% *} key=${spec#* }
  tmp=$(mktemp)
  defaults export "$domain" - | /usr/bin/python3 -I -c '
import plistlib, re, sys
data = plistlib.loads(sys.stdin.buffer.read())
key, pattern = sys.argv[1], sys.argv[2]
data[key] = [e for e in data.get(key, []) if not (isinstance(e, dict) and re.match(pattern, str(e.get("Bundle ID", ""))))]
sys.stdout.buffer.write(plistlib.dumps(data))' "$key" "$ID_PATTERN" > "$tmp" && defaults import "$domain" "$tmp" \
    && print -r -- "  đã bỏ các mục của Dấu: $domain › $key"
  rm -f "$tmp"
done
for r in $registered; do "$LSREGISTER" -u "$r" >/dev/null 2>&1 && print -r -- "  bỏ đăng ký: $r"; done
for k in $keys; do defaults delete -g "$k" && print -r -- "  đã xoá khoá: -g $k"; done

print "\nXong. Còn hai việc:"
print "  1. Dọn Thùng rác nếu muốn (Dau.app, DauInputMethod.app vừa được chuyển vào)."
print "  2. Đăng xuất rồi đăng nhập lại: macOS chỉ quên Dấu trong danh sách nguồn nhập liệu ở lần đăng nhập sau."
