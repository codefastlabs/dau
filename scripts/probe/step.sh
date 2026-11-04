#!/bin/zsh
# Runs one step (P0..P7, P3b) of the "new input source without logging out" experiments on one variant.
# Side effects: installs input method, changes input source, kills processes, needs admin password (P6 only); builds the probe tools first
# Plan: docs/research/M5-INSTALL.md 8.2. Variants come from scripts/probe/make-variants.sh. Run it yourself
# (it copies into the input method folder, registers, enables, and for P3..P5 stops system processes of
# THIS login session); the assistant only uses --dry-run.
#
# Usage:
#   scripts/probe/step.sh [--dry-run] [--log-stream] [--watch] <step> <variant>
#     step     P0 P1 P2 P3 P3b P4 P5 P6 P7
#     variant  DauProbeA1 or just A1 (round letters + number)
#     --dry-run     print the command sequence, run nothing (also builds nothing, checks nothing)
#     --log-stream  run `log stream` (filter of M5-INSTALL.md 7.2 step 3) into build/probe.noindex/logs/<round>-stream.log
#     --watch       run `tis-probe --watch` into logs/<round>-watch.log
#
#   P0  copy; register (one process). Nothing else.
#   P1  copy; one process: register, wait-listed parent, enable parent, wait-listed mode, enable mode.
#   P2  copy; three processes: register; enable parent; enable mode.
#   P3  copy; register; enable parent; quit System Settings; delete IntlDataCache.le*; stop the Keyboard
#       settings extension; reopen Keyboard settings.
#   P3b after P3, same variant (not copied again): enable parent through TisAct.app (an app with a name).
#   P4  stop TextInputMenuAgent, wait 0.5 s; copy; register; enable mode, then parent; snapshot; stop
#       TextInputMenuAgent again; snapshot.
#   P5  copy; register; enable parent; stop TextInputSwitcher, CursorUIViewService, TextInputMenuAgent, 0.5 s apart.
#   P6  sudo copy into /Library/Input Methods (root owned); register from this user; enable parent, mode.
#   P7  like P0, then select the mode; print the status and whether the variant process runs.
# P8 (stopping imklaunchagent / keyboardservicesd) is deliberately not here.
#
# Every command is logged with its time to build/probe.noindex/logs/<round>-steps.log. The variant is
# copied right BEFORE its step, never earlier. After the step, tis-probe runs three times 3 s apart for
# EVERY variant now installed, then the script says what to look at in System Settings.
set -u
zmodload zsh/datetime
setopt null_glob

ROOT="${0:A:h:h:h}"
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
OUT="$ROOT/build/probe.noindex"
BIN="$OUT/bin"
TISACT_APP="$OUT/TisAct.app"
USER_DIR="$HOME/Library/Input Methods"
SYS_DIR="/Library/Input Methods"
PREFIX="com.codefastlabs.dau.inputmethod"
STREAM_PREDICATE='process IN {"imklaunchagent","TextInputMenuAgent","TextInputSwitcher","keyboardservicesd","CursorUIViewService","cfprefsd","KeyboardSettings"} OR eventMessage CONTAINS[c] "inputsource" OR eventMessage CONTAINS[c] "codefastlabs.dau"'

DRY=0 STREAM=0 WATCH=0
args=()
for a in "$@"; do
  case $a in
    --dry-run) DRY=1 ;;
    --log-stream) STREAM=1 ;;
    --watch) WATCH=1 ;;
    -h|--help) awk 'NR==1{next} /^#/{sub(/^# ?/,""); print; next} {exit}' "$0"; exit 0 ;;
    -*) print -u2 "Tham số không hợp lệ: $a"; exit 2 ;;
    *) args+=("$a") ;;
  esac
done
(( ${#args} == 2 )) || { print -u2 "Cần <bước> <biến thể>. Xem --help."; exit 2 }
STEP=${(U)args[1]}; STEP=${STEP/B/b}
[[ $STEP == (P0|P1|P2|P3|P3b|P4|P5|P6|P7) ]] || { print -u2 "Bước không hợp lệ: ${args[1]} (P0 P1 P2 P3 P3b P4 P5 P6 P7)"; exit 2 }
NAME=${args[2]#DauProbe}
[[ $NAME =~ '^([A-Za-z]+)([0-9]+)$' ]] || { print -u2 "Biến thể không hợp lệ: ${args[2]} (ví dụ DauProbeA1 hoặc A1)"; exit 2 }
ROUND=$match[1]
VARIANT="DauProbe$NAME"
PARENT="$PREFIX.$VARIANT"
MODE="$PARENT.vi"
SRC="$OUT/$ROUND/$VARIANT.app"
LOGDIR="$OUT/logs"
STEPLOG="$LOGDIR/$ROUND-steps.log"
PROBELOG="$LOGDIR/$ROUND-probe.jsonl"
TISACT_LOG="$LOGDIR/$ROUND-tisact.log"
if [[ $STEP == P6 ]]; then DEST_DIR=$SYS_DIR; else DEST_DIR=$USER_DIR; fi
DEST="$DEST_DIR/$VARIANT.app"
KBD_CACHE="$(getconf DARWIN_USER_CACHE_DIR)"; KBD_CACHE="${KBD_CACHE%/}/com.apple.Keyboard-Settings.extension"

now() { local s; strftime -s s '%Y-%m-%dT%H:%M:%S' ${EPOCHREALTIME%.*}; printf '%s.%03d%s' $s $(( (EPOCHREALTIME - ${EPOCHREALTIME%.*}) * 1000 )) "$(date +%z)"; }

# run <command…>: print and log with time, run unless --dry-run, log the exit status.
run() {
  if (( DRY )); then print -r -- "\$ ${(j: :)${(q-)@}}"; return 0; fi
  print -r -- "$(now) \$ ${(j: :)${(q-)@}}"
  print -r -- "$(now)	$STEP	$VARIANT	cmd	${(j: :)${(q-)@}}" >> "$STEPLOG"
  "$@"; local rc=$?
  print -r -- "$(now)	$STEP	$VARIANT	exit	$rc" >> "$STEPLOG"
  return $rc
}
# runmust: like run, but stops the step when it fails (the copy).
runmust() { run "$@" || { print -u2 "Lệnh lỗi, dừng bước."; exit 1 } }
say() { print -r -- "$*"; }
tisact() { run "$BIN/tis-act" "$@"; }
snapshot() {
  if (( DRY )); then print -r -- "\$ $BIN/tis-probe   # một dòng JSON, mọi biến thể đang cài"; return 0; fi
  print -r -- "$(now)	$STEP	$VARIANT	probe" >> "$STEPLOG"
  "$BIN/tis-probe" | tee -a "$PROBELOG"
}
copy_variant() {
  if [[ $STEP == P6 ]]; then
    runmust sudo ditto "$SRC" "$DEST"
    runmust sudo chown -R root:wheel "$DEST"
    runmust sudo chmod -R go-w "$DEST"
  else
    runmust ditto "$SRC" "$DEST"
  fi
}

if (( ! DRY )); then
  [[ -d $SRC ]] || { print -u2 "Không thấy $SRC: chạy scripts/probe/make-variants.sh $ROUND trước."; exit 1 }
  if [[ $STEP != P3b && -e $DEST ]]; then
    print -u2 "$DEST đã có. Mỗi biến thể chỉ dùng cho một bước (ID chỉ mới một lần); dùng biến thể khác."; exit 1
  fi
  if [[ $STEP == P3b && ! -e "$USER_DIR/$VARIANT.app" ]]; then
    print -u2 "P3b dùng lại biến thể của P3: $USER_DIR/$VARIANT.app chưa có."; exit 1
  fi
  mkdir -p "$LOGDIR"
  "$ROOT/scripts/probe/build-tools.sh" >/dev/null || { print -u2 "Không dựng được công cụ (scripts/probe/build-tools.sh)."; exit 1 }
fi

BG=()
if (( STREAM )); then
  if (( DRY )); then print -r -- "\$ /usr/bin/log stream --info --debug --style compact --predicate '$STREAM_PREDICATE' > $LOGDIR/$ROUND-stream.log &"
  else
    /usr/bin/log stream --info --debug --style compact --predicate "$STREAM_PREDICATE" > "$LOGDIR/$ROUND-stream.log" 2>&1 &
    BG+=($!)
  fi
fi
if (( WATCH )); then
  if (( DRY )); then print -r -- "\$ $BIN/tis-probe --watch > $LOGDIR/$ROUND-watch.log &"
  else
    "$BIN/tis-probe" --watch > "$LOGDIR/$ROUND-watch.log" 2>&1 &
    BG+=($!)
  fi
fi
cleanup_bg() { for p in $BG; do kill $p 2>/dev/null; done }
trap cleanup_bg EXIT

(( DRY )) && say "# DRY RUN: bước $STEP, biến thể $VARIANT (ID $PARENT), nhật ký $STEPLOG"
(( DRY )) || say "== Bước $STEP, biến thể $VARIANT, $(now)"

case $STEP in
  P0)
    copy_variant
    tisact register "$DEST"
    ;;
  P1)
    copy_variant
    tisact p1 "$DEST"
    ;;
  P2)
    copy_variant
    tisact register "$DEST"
    tisact enable "$PARENT"
    tisact enable "$MODE"
    ;;
  P3)
    copy_variant
    tisact register "$DEST"
    tisact enable "$PARENT"
    run osascript -e 'tell application "System Settings" to quit'
    run sleep 1.5
    run /bin/sh -c "rm -f ${(q)KBD_CACHE}/com.apple.IntlDataCache.le*"
    # Match the extension binaries only: a bare "KeyboardSettings" also matches the
    # log stream started by --log-stream, whose predicate names that process.
    run pgrep -fl 'KeyboardSettings[A-Za-z]*\.appex/Contents/MacOS/'
    run pkill -f 'KeyboardSettings[A-Za-z]*\.appex/Contents/MacOS/'
    run sleep 1
    run open "x-apple.systempreferences:com.apple.Keyboard-Settings.extension"
    run sleep 5
    ;;
  P3b)
    run rm -f "$TISACT_LOG"
    run open -W -n --stdout "$TISACT_LOG" --stderr "$TISACT_LOG" "$TISACT_APP" --args enable "$PARENT"
    run cat "$TISACT_LOG"
    say "P3b: NHÌN System Settings NGAY: có hộp thoại \"Allow “Dấu thử” to enable “Dấu thử ${NAME}”?\" (hoặc câu tương tự) không? Có hiện ở đâu, bấm gì? Ghi cả khi KHÔNG hiện."
    ;;
  P4)
    run pkill -x TextInputMenuAgent
    run sleep 0.5
    copy_variant
    tisact register "$DEST"
    tisact enable "$MODE"
    tisact enable "$PARENT"
    snapshot
    run pkill -x TextInputMenuAgent
    run sleep 2
    snapshot
    ;;
  P5)
    copy_variant
    tisact register "$DEST"
    tisact enable "$PARENT"
    run pkill -x TextInputSwitcher
    run sleep 0.5
    run pkill -x CursorUIViewService
    run sleep 0.5
    run pkill -x TextInputMenuAgent
    ;;
  P6)
    (( DRY )) || say "Sẽ hỏi mật khẩu quản trị ngay bây giờ (sudo): gõ trong Terminal này."
    copy_variant
    tisact register "$DEST"
    tisact enable "$PARENT"
    tisact enable "$MODE"
    ;;
  P7)
    copy_variant
    tisact register "$DEST"
    tisact select "$MODE"
    run sleep 2
    if (( DRY )); then
      print -r -- "\$ pgrep -fl /Contents/MacOS/$VARIANT   # tiến trình $VARIANT có chạy không"
    else
      print -r -- "tiến trình $VARIANT:"; pgrep -fl "/Contents/MacOS/$VARIANT" || print "  KHÔNG chạy"
    fi
    ;;
esac

# --- after every step: three snapshots for every installed variant, then the visual check ---
if (( DRY )); then
  print -r -- "\$ sleep 10   # chờ trước bảng kiểm"
  print -r -- "\$ $BIN/tis-probe   # 3 lần, cách nhau 3 s, mỗi dòng ghi thêm vào $PROBELOG"
else
  say "Chờ 10 s rồi đọc lại bằng tiến trình mới (3 lần, cách 3 s)…"
  sleep 10
  for i in 1 2 3; do
    snapshot
    (( i < 3 )) && sleep 3
  done
fi

installed=()
for d in "$USER_DIR" "$SYS_DIR"; do for b in "$d"/DauProbe*.app; do installed+=("$b"); done; done
(( DRY )) && installed=("$DEST")
say ""
say "Biến thể đang cài (tìm từng tên trong danh sách):"
for b in $installed; do
  n=${${b:t}%.app}; n=${n#DauProbe}
  say "  Dấu thử $n   (${b:h})"
done
[[ -e "$USER_DIR/DauInputMethod.app" ]] && say "  Dấu – Tiếng Việt   (Dấu thật, $USER_DIR)"
say ""
say "Nhìn System Settings › Keyboard › Input Sources › Edit… › '+' › Vietnamese, và menu nhập liệu; ghi HIỆN/KHÔNG cho từng ID"
say "(cả ID cũ, không chỉ ${VARIANT}: một bước sau có thể làm hiện ID đã cài trước đó). Nhật ký: $STEPLOG"
