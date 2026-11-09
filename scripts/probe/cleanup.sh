#!/bin/zsh
# Lists, or with --yes removes, the DauProbe variants and the leftovers of the probe test apps from this account.
# Side effects: none without --yes or --trash (only lists); with --yes: kills processes, deletes data, needs admin password (only for a copy in /Library/Input Methods); with --trash: deletes data (permanently, from the Trash)
# Lists: DauProbe*.app in ~/Library/Input Methods and /Library/Input Methods, LaunchServices
# registrations of DauProbe*.app, DauProbe entries in com.apple.inputsources ›
# AppleEnabledThirdPartyInputSources, running DauProbe processes; the folders macOS made for the
# sandboxed probe apps (DauProbe variants and the local.probe.* test apps of round E, M5-INSTALL.md
# 8.1b): containers in ~/Library/Containers, ~/Library/Application Scripts, the per-app cache folders
# in $(getconf DARWIN_USER_CACHE_DIR); and the probe copies in the Trash.
#
# Usage:
#   scripts/probe/cleanup.sh         list; changes nothing
#   scripts/probe/cleanup.sh --yes   if a DauProbe entry is still in com.apple.inputsources while its bundle is
#                                    installed: stop, change nothing, say how to remove it. Otherwise stop the
#                                    DauProbe processes, `lsregister -u` every registered copy, move the bundles to
#                                    the Trash (a copy in /Library needs sudo), and `lsregister -u` the copies that
#                                    landed in the Trash too (same order and reason as scripts/dev/clean-dau.sh).
#                                    Then remove the probe apps' folders: Application Scripts and cache folders are
#                                    deleted; a container is deleted when the terminal has Full Disk Access, otherwise
#                                    sent to the Trash through Finder; if both fail it says how to remove it by hand.
#   scripts/probe/cleanup.sh --trash delete for good, from the Trash, only DauProbe*.app, DauInputMethod*.app
#                                    and local.probe.* / com.codefastlabs.dau.inputmethod.DauProbe* (containers moved
#                                    there by --yes); nothing else in the Trash. The Trash is readable only with Full
#                                    Disk Access for the terminal; without it the script says so and stops.
#
# It never touches the variants under build/probe.noindex (they are build output, not installed) and never
# changes com.apple.inputsources (macOS lets only System Settings write it): the entries go with "–".
set -u
setopt null_glob
source "${0:A:h:h}/lib/log.sh"

DO=0
TRASH=0
case "${1:-}" in
  "") ;;
  --yes) DO=1 ;;
  --trash) TRASH=1 ;;
  -h|--help) awk 'NR==1{next} /^#/{sub(/^# ?/,""); print; next} {exit}' "$0"; exit 0 ;;
  *) log_die 2 "Tham số không hợp lệ: $1 (không tham số để xem, --yes để xoá, --trash để xoá hẳn khỏi Thùng rác)" ;;
esac

# Names macOS gives the folders of a sandboxed app: its bundle ID.
PROBE_IDS=('local.probe.*' 'com.codefastlabs.dau.inputmethod.DauProbe*' 'com.codefastlabs.dau.probe.*')
CACHE_ROOT=$(getconf DARWIN_USER_CACHE_DIR)
probe_folders() { # $1: parent folder; prints matching subfolders
  local id d
  for id in $PROBE_IDS; do for d in "$1"/${~id}(N/); do print -r -- "$d"; done; done
}

if (( TRASH )); then
  log_step "Bản thử trong Thùng rác"
  if ! ls "$HOME/.Trash" >/dev/null 2>&1; then
    log_error "Không đọc được Thùng rác: Terminal cần quyền Full Disk Access (System Settings › Privacy & Security › Full Disk Access)."
    log_hint "Hoặc mở Thùng rác trong Finder, chọn các mục tên DauProbe…, DauInputMethod…, local.probe.… và chọn Delete Immediately."
    exit 1
  fi
  items=()
  for p in "$HOME/.Trash"/DauProbe*.app(N) "$HOME/.Trash"/DauInputMethod*.app(N) "$HOME/.Trash"/local.probe.*(N) "$HOME/.Trash"/com.codefastlabs.dau.inputmethod.DauProbe*(N); do
    items+=("$p"); log_detail "$p"
  done
  (( ${#items} )) || { log_detail "(không có)"; exit 0 }
  log_ask "Xoá hẳn ${#items} mục này, không lấy lại được? Gõ yes:"
  read -r answer
  [[ $answer == yes ]] || { log_detail "Không xoá gì."; exit 0 }
  LSREG=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister
  left=0
  for p in $items; do
    [[ $p == *.app ]] && "$LSREG" -u "$p" >/dev/null 2>&1
    if rm -rf -- "$p"; then log_detail "đã xoá: ${p:t}"; else log_error "KHÔNG xoá được: ${p:t}"; (( left++ )); fi
  done
  (( left )) && { log_hint "Còn $left mục: xoá trong Finder (Delete Immediately)."; exit 1 }
  log_done
  exit 0
fi

LSREGISTER=/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister
USER_DIR="$HOME/Library/Input Methods"
SYS_DIR="/Library/Input Methods"
found=0
note() { log_detail "$1"; found=1 }

log_step "Biến thể đã cài"
bundles=()
for d in "$USER_DIR" "$SYS_DIR"; do
  for b in "$d"/DauProbe*.app; do bundles+=("$b"); note "$b"; done
done

log_step "Đăng ký LaunchServices (trừ bản dựng trong build/probe.noindex)"
registered=(${(f)"$("$LSREGISTER" -dump 2>/dev/null | grep -E '^path: .*/DauProbe[A-Za-z0-9]+\.app \(0x' | sed -E 's/^path: +//; s/ \(0x[0-9a-f]+\)$//' | grep -v '/build/probe\.noindex/' | sort -u)"})
for r in $registered; do note "$r"; done

log_step "Mục DauProbe trong com.apple.inputsources › AppleEnabledThirdPartyInputSources"
entries=$(defaults export com.apple.inputsources - 2>/dev/null | /usr/bin/python3 -I -c '
import plistlib, sys
data = plistlib.loads(sys.stdin.buffer.read() or plistlib.dumps({}))
for e in data.get("AppleEnabledThirdPartyInputSources", []):
    if isinstance(e, dict) and "DauProbe" in str(e.get("Bundle ID", "")) + str(e.get("Input Mode", "")):
        print(e.get("Input Mode") or e.get("Bundle ID"), "(%s)" % e.get("InputSourceKind", "?"))')
entry_lines=(${(f)entries})
for e in $entry_lines; do note "$e"; done

log_step "Tiến trình DauProbe đang chạy"
procs=(${(f)"$(pgrep -fl 'Contents/MacOS/DauProbe' 2>/dev/null)"})
for p in $procs; do note "$p"; done

log_step "Thư mục macOS tạo cho app thử có sandbox"
containers=(${(f)"$(probe_folders "$HOME/Library/Containers")"})
scripts_dirs=(${(f)"$(probe_folders "$HOME/Library/Application Scripts")"})
cache_dirs=(${(f)"$([[ -n $CACHE_ROOT ]] && probe_folders "${CACHE_ROOT%/}")"})
for d in $containers $scripts_dirs $cache_dirs; do note "$d"; done

log_step "Bản thử trong Thùng rác (xoá hẳn bằng --trash)"
if ls "$HOME/.Trash" >/dev/null 2>&1; then
  for p in "$HOME/.Trash"/DauProbe*.app(N) "$HOME/.Trash"/DauInputMethod*.app(N) "$HOME/.Trash"/local.probe.*(N) "$HOME/.Trash"/com.codefastlabs.dau.inputmethod.DauProbe*(N); do log_detail "$p"; done
else
  log_detail "(không đọc được Thùng rác khi Terminal chưa có Full Disk Access)"
fi

if (( ! found )); then log_ok "Không còn biến thể hay thư mục nào của app thử."; exit 0; fi
if (( ! DO )); then
  log_ok "Chưa xoá gì. Chạy lại với --yes để xoá."
  (( ${#entry_lines} )) && log_warn "Các mục trong com.apple.inputsources không xoá được bằng script: bỏ bằng \"–\" trong System Settings › Keyboard › Input Sources › Edit… TRƯỚC khi chạy --yes."
  exit 0
fi

# Order matters: with the bundle gone System Settings no longer lists the source, so its entry cannot be
# removed with "–" and stays behind (measured 03/11/2026, scripts/dev/clean-dau.sh).
if (( ${#entry_lines} && ${#bundles} )); then
  log_error "Còn mục DauProbe trong com.apple.inputsources mà bundle còn cài. Chưa xoá gì."
  log_hint "Làm từng bước:"
  log_hint "1. Chọn một bàn phím khác (ví dụ U.S.) trên menu nhập liệu nếu một biến thể đang được chọn."
  log_hint "2. System Settings › Keyboard › Input Sources › Edit…: chọn từng dòng \"Dấu thử …\", bấm \"–\"."
  log_hint "3. Bấm Done, rồi chạy lại: scripts/probe/cleanup.sh --yes"
  exit 1
fi

log_step "Đang xoá…"
unremoved=0
if (( ${#procs} )); then
  pkill -f 'Contents/MacOS/DauProbe' 2>/dev/null
  sleep 1
  still=(${(f)"$(pgrep -fl 'Contents/MacOS/DauProbe' 2>/dev/null)"})
  for p in $still; do log_error "KHÔNG dừng được: $p"; (( unremoved++ )); done
fi
# Unregister before the bundles move: LaunchServices follows a bundle into the Trash.
for r in $registered; do "$LSREGISTER" -u "$r" >/dev/null 2>&1 && log_detail "bỏ đăng ký: $r"; done
stamp=$(date +%Y%m%d-%H%M%S)
for b in $bundles; do
  if [[ $b == "$SYS_DIR"/* ]]; then
    target="$HOME/.Trash/${${b:t}%.app} $stamp.app"
    if sudo mv "$b" "$target" && sudo chown -R "$USER" "$target"; then
      log_detail "vào Thùng rác (sudo): $b"
    else
      log_error "KHÔNG chuyển được: $b"; (( unremoved++ ))
    fi
  elif osascript -e "tell application \"Finder\" to delete (POSIX file \"$b\" as alias)" >/dev/null 2>&1; then
    log_detail "vào Thùng rác: $b"
  else
    log_error "KHÔNG chuyển được vào Thùng rác (Finder từ chối): $b — kéo vào Thùng rác bằng tay."; (( unremoved++ ))
  fi
done
if (( ${#bundles} )); then
  sleep 1
  trashed=(${(f)"$("$LSREGISTER" -dump 2>/dev/null | grep -E "^path: +$HOME/\.Trash/.*DauProbe[A-Za-z0-9 -]*\.app \(0x" | sed -E 's/^path: +//; s/ \(0x[0-9a-f]+\)$//')"})
  for r in $trashed; do "$LSREGISTER" -u "$r" >/dev/null 2>&1 && log_detail "bỏ đăng ký (Thùng rác): $r"; done
fi
# Folders of the sandboxed probe apps. Caches and Application Scripts are plain folders; a container's
# metadata is protected, so the container goes to the Trash through Finder (the user's own action).
for d in $scripts_dirs $cache_dirs; do
  if rm -rf -- "$d"; then log_detail "đã xoá: $d"; else log_error "KHÔNG xoá được: $d"; (( unremoved++ )); fi
done
# macOS protects other apps' containers (App Data): a shell deletes one only with Full Disk Access, and
# Finder driven by AppleScript gets -5000 because it cannot ask for confirmation (measured 04/11/2026).
container_left=0
for d in $containers; do
  if rm -rf -- "$d" 2>/dev/null && [[ ! -e $d ]]; then
    log_detail "đã xoá: $d"
  elif osascript -e "tell application \"Finder\" to delete (POSIX file \"$d\" as alias)" >/dev/null 2>&1; then
    log_detail "vào Thùng rác: $d"
  else
    log_error "KHÔNG xoá được: $d"; (( unremoved++ )); (( container_left++ ))
  fi
done
if (( container_left )); then
  log_warn "macOS bảo vệ container của app khác. Chọn một trong hai:"
  log_hint "- Cấp Full Disk Access cho ứng dụng terminal (System Settings › Privacy & Security › Full Disk Access),"
  log_hint "  mở lại terminal, chạy lại: scripts/probe/cleanup.sh --yes"
  log_hint "- Hoặc kéo các thư mục trên vào Thùng rác trong Finder (open ~/Library/Containers); macOS có thể hỏi mật khẩu."
fi
if (( unremoved )); then log_error "CHƯA XOÁ HẾT ($unremoved mục)."; log_hint "Xử lý tay rồi chạy lại để kiểm."; exit 1; fi
log_hint "Mục còn trong com.apple.inputsources (nếu có) chỉ bỏ được bằng \"–\"; ID đã dùng chỉ \"mới\" lại sau khi dùng một vòng ID khác."
log_done
