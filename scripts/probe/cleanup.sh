#!/bin/zsh
# Lists, or with --yes removes, the DauProbe variants from this account.
# Side effects: none without --yes (only lists); with --yes: kills processes, deletes data, needs admin password (only for a copy in /Library/Input Methods)
# Lists: DauProbe*.app in ~/Library/Input Methods and /Library/Input Methods, LaunchServices
# registrations of DauProbe*.app, DauProbe entries in com.apple.inputsources ›
# AppleEnabledThirdPartyInputSources, running DauProbe processes.
#
# Usage:
#   scripts/probe/cleanup.sh         list; changes nothing
#   scripts/probe/cleanup.sh --yes   if a DauProbe entry is still in com.apple.inputsources while its bundle is
#                                    installed: stop, change nothing, say how to remove it. Otherwise stop the
#                                    DauProbe processes, `lsregister -u` every registered copy, move the bundles to
#                                    the Trash (a copy in /Library needs sudo), and `lsregister -u` the copies that
#                                    landed in the Trash too (same order and reason as scripts/dev/clean-dau.sh).
#
# It never touches the variants under build/probe.noindex (they are build output, not installed) and never
# changes com.apple.inputsources (macOS lets only System Settings write it): the entries go with "–".
set -u
setopt null_glob

DO=0
case "${1:-}" in
  "") ;;
  --yes) DO=1 ;;
  -h|--help) awk 'NR==1{next} /^#/{sub(/^# ?/,""); print; next} {exit}' "$0"; exit 0 ;;
  *) print -u2 "Tham số không hợp lệ: $1 (không tham số để xem, --yes để xoá)"; exit 2 ;;
esac

LSREGISTER=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister
USER_DIR="$HOME/Library/Input Methods"
SYS_DIR="/Library/Input Methods"
found=0
note() { print -r -- "  $1"; found=1 }

print "Biến thể đã cài:"
bundles=()
for d in "$USER_DIR" "$SYS_DIR"; do
  for b in "$d"/DauProbe*.app; do bundles+=("$b"); note "$b"; done
done

print "Đăng ký LaunchServices (trừ bản dựng trong build/probe.noindex):"
registered=(${(f)"$("$LSREGISTER" -dump 2>/dev/null | grep -E '^path: .*/DauProbe[A-Za-z0-9]+\.app \(0x' | sed -E 's/^path: +//; s/ \(0x[0-9a-f]+\)$//' | grep -v '/build/probe\.noindex/' | sort -u)"})
for r in $registered; do note "$r"; done

print "Mục DauProbe trong com.apple.inputsources › AppleEnabledThirdPartyInputSources:"
entries=$(defaults export com.apple.inputsources - 2>/dev/null | /usr/bin/python3 -I -c '
import plistlib, sys
data = plistlib.loads(sys.stdin.buffer.read() or plistlib.dumps({}))
for e in data.get("AppleEnabledThirdPartyInputSources", []):
    if isinstance(e, dict) and "DauProbe" in str(e.get("Bundle ID", "")) + str(e.get("Input Mode", "")):
        print(e.get("Input Mode") or e.get("Bundle ID"), "(%s)" % e.get("InputSourceKind", "?"))')
entry_lines=(${(f)entries})
for e in $entry_lines; do note "$e"; done

print "Tiến trình DauProbe đang chạy:"
procs=(${(f)"$(pgrep -fl 'Contents/MacOS/DauProbe' 2>/dev/null)"})
for p in $procs; do note "$p"; done

if (( ! found )); then print "\nKhông còn biến thể nào."; exit 0; fi
if (( ! DO )); then
  print "\nChưa xoá gì. Chạy lại với --yes để xoá."
  (( ${#entry_lines} )) && print "Các mục trong com.apple.inputsources không xoá được bằng script: bỏ bằng \"–\" trong System Settings › Keyboard › Input Sources › Edit… TRƯỚC khi chạy --yes."
  exit 0
fi

# Order matters: with the bundle gone System Settings no longer lists the source, so its entry cannot be
# removed with "–" and stays behind (measured 03/11/2026, scripts/dev/clean-dau.sh).
if (( ${#entry_lines} && ${#bundles} )); then
  print -u2 "\nCòn mục DauProbe trong com.apple.inputsources mà bundle còn cài. Chưa xoá gì."
  print -u2 "Làm từng bước:"
  print -u2 "  1. Chọn một bàn phím khác (ví dụ ABC) trên menu nhập liệu nếu một biến thể đang được chọn."
  print -u2 "  2. System Settings › Keyboard › Input Sources › Edit…: chọn từng dòng \"Dấu thử …\", bấm \"–\"."
  print -u2 "  3. Bấm Done, rồi chạy lại: scripts/probe/cleanup.sh --yes"
  exit 1
fi

print "\nĐang xoá…"
unremoved=0
if (( ${#procs} )); then
  pkill -f 'Contents/MacOS/DauProbe' 2>/dev/null
  sleep 1
  still=(${(f)"$(pgrep -fl 'Contents/MacOS/DauProbe' 2>/dev/null)"})
  for p in $still; do print -r -- "  KHÔNG dừng được: $p"; (( unremoved++ )); done
fi
# Unregister before the bundles move: LaunchServices follows a bundle into the Trash.
for r in $registered; do "$LSREGISTER" -u "$r" >/dev/null 2>&1 && print -r -- "  bỏ đăng ký: $r"; done
stamp=$(date +%Y%m%d-%H%M%S)
for b in $bundles; do
  if [[ $b == "$SYS_DIR"/* ]]; then
    target="$HOME/.Trash/${${b:t}%.app} $stamp.app"
    if sudo mv "$b" "$target" && sudo chown -R "$USER" "$target"; then
      print -r -- "  vào Thùng rác (sudo): $b"
    else
      print -r -- "  KHÔNG chuyển được: $b"; (( unremoved++ ))
    fi
  elif osascript -e "tell application \"Finder\" to delete (POSIX file \"$b\" as alias)" >/dev/null 2>&1; then
    print -r -- "  vào Thùng rác: $b"
  else
    print -r -- "  KHÔNG chuyển được vào Thùng rác (Finder từ chối): $b — kéo vào Thùng rác bằng tay."; (( unremoved++ ))
  fi
done
if (( ${#bundles} )); then
  sleep 1
  trashed=(${(f)"$("$LSREGISTER" -dump 2>/dev/null | grep -E "^path: +$HOME/\.Trash/.*DauProbe[A-Za-z0-9 -]*\.app \(0x" | sed -E 's/^path: +//; s/ \(0x[0-9a-f]+\)$//')"})
  for r in $trashed; do "$LSREGISTER" -u "$r" >/dev/null 2>&1 && print -r -- "  bỏ đăng ký (Thùng rác): $r"; done
fi
if (( unremoved )); then print "\nCHƯA XOÁ HẾT ($unremoved mục). Xử lý tay rồi chạy lại để kiểm."; exit 1; fi
print "\nXong. Mục còn trong com.apple.inputsources (nếu có) chỉ bỏ được bằng \"–\"; ID đã dùng chỉ \"mới\" lại sau khi dùng một vòng ID khác."
