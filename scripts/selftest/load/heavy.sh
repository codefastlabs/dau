#!/bin/zsh
# Types one text into real apps while the whole Mac is under CPU and memory load, and when it is not (M6 step 2).
# Side effects: builds, takes the screen, changes input source, changes user settings
#
# Usage: scripts/selftest/load/heavy.sh [--delay MS] [--dry-run]
#   --delay MS   pause between keys (default 50, 20 keys a second)
#   --dry-run    print the plan and the estimated duration, run nothing
#
# The question: when the Mac itself is busy (every core taken, memory under pressure),
# does Dấu still type the right text, and do its per-key times grow. load/run.sh asks
# the other question (one app's page is busy, the Mac is not).
#
# Load: one `yes > /dev/null` per core and `memory_pressure -l warn`, started by this
# script and stopped by it (their PIDs only), also on ⌃C. Typing starts RAMP_S after.
# The script refuses to start when the 1-minute load average is already at or above the
# number of cores: the "idle" groups would not be a baseline.
#
# Plan, one call of scripts/selftest/typing/run.sh per group (its safety rules apply),
# every call with --keep-source so the input source is switched once per source, not
# twice per group:
#   1  Dấu          idle   safari chrome vscodefile
#   2  Apple Telex  idle   safari chrome            (one switch to Apple Telex)
#      load on
#   3  Apple Telex  load   safari chrome
#   4  Dấu          load   safari chrome vscodefile (one switch back to Dấu)
#   5  Dấu          load   safari chrome vscodefile
#      load off
#   6  Dấu          idle   safari chrome vscodefile
# Dấu runs idle, load, load, idle so that drift during the run (heat, a process that has
# just started) does not land on one condition. Apple Telex is the control for the text
# only (another Vietnamese input method, same keys, same load); it has no per-key log.
#
# Needs: as load/run.sh (the Debug input method with t_ns in its log, Dấu enabled, the
# apps installed, Accessibility), and Apple's Telex enabled
# (com.apple.inputmethod.VietnameseIM.VietnameseTelex; nothing is enabled here, N4).
#
# Output in build/load/heavy-<time>/: per group <n>-<source>-<load>/ with typing/run.sh's
# files (<app>.txt, <app>.perf.log), its output (typing.log) and, for Dấu,
# perf-report output (<app>.perf.txt); stats.tsv (load average, free memory, memory of
# the input method process before and after each group); summary.tsv, one row per app
# of a group:
#   group source load app text_ok late mismatch resync gap_lt10 lag_p50_us lag_p99_us
#   replace_p50_us replace_p99_us
# ("-" = not in the log). text_ok for Dấu: 1 when the text is the expected one. For Apple
# Telex: "ref" in the idle group (its text is the reference), then 1 when the loaded
# text is the same as its idle text.
#
# Cleanup: the load is stopped; each typing/run.sh call closes what it opened and puts
# back the clipboard and DauPerfLog. The last group leaves Dấu selected; if the source
# at the start was another one, it is selected again and the script says so.
#
# Exit status: 0 when every group ran (wrong texts are results, in the summary); 1 on an
# error; 2 on a bad call; 3/4 as typing/run.sh, which stops the run; 130 on ⌃C.
set -uo pipefail

SELF="${0:A}"
ROOT="${SELF:h:h:h:h}"
source "$ROOT/scripts/lib/log.sh"
source "$ROOT/scripts/lib/swift-tool.sh"
TYPING="$ROOT/scripts/selftest/typing/run.sh"
TEXTS="$ROOT/scripts/selftest/load/run.sh"
REPORT="$ROOT/scripts/perf/perf-report.sh"

DELAY_MS=50
DRY_RUN=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --delay) DELAY_MS="${2:?--delay cần số ms}"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) log_usage "$SELF"; exit 0 ;;
    *) log_die 2 "Tham số không hợp lệ: $1" ;;
  esac
done
[[ "$DELAY_MS" =~ ^[0-9]+$ ]] || log_die 2 "--delay phải là số nguyên ms"

TELEX=com.apple.inputmethod.VietnameseIM.VietnameseTelex
RAMP_S=15
CORES=$(sysctl -n hw.ncpu)
KEYS="$("$TEXTS" --text std --print keys)"
EXPECT="$("$TEXTS" --text std --print expect)"
# group: source load apps…
PLAN=(
  "dau idle safari chrome vscodefile"
  "telex idle safari chrome"
  "telex load safari chrome"
  "dau load safari chrome vscodefile"
  "dau load safari chrome vscodefile"
  "dau idle safari chrome vscodefile"
)
CELL_COUNT=0
for g in $PLAN; do (( CELL_COUNT += ${#${=g}} - 2 )); done
# As load/run.sh: the pause plus ~15 ms per key, ~12 s more per app.
TOTAL_S=$(( CELL_COUNT * (${#KEYS} * (DELAY_MS + 15) / 1000 + 12) + 2 * RAMP_S ))
log_step "Đo dưới tải nặng: ${#PLAN} nhóm, $CELL_COUNT ô, ${#KEYS} phím mỗi ô, nghỉ $DELAY_MS ms giữa hai phím"
log_detail "tải: $CORES tiến trình yes và memory_pressure -l warn, bật ở giữa lượt"
log_detail "ước tính: khoảng $(log_duration $TOTAL_S)"
if (( DRY_RUN )); then
  for g in $PLAN; do log_detail "$g"; done
  exit 0
fi

load_1m() { sysctl -n vm.loadavg | awk '{print $2}'; }
LOAD_NOW="$(load_1m)"
if (( LOAD_NOW >= CORES )); then
  log_error "Máy đang bận: tải trung bình 1 phút là $LOAD_NOW trên $CORES nhân, nhóm \"idle\" không làm mốc được."
  log_hint "Chạy lại khi máy rảnh hơn."
  exit 1
fi

INPUT_SOURCE="$(dau_swift_tool input-source "$ROOT/scripts/lib/input-source.swift")" || exit 1
(( ${${(f)"$("$INPUT_SOURCE" enabled "$TELEX")"}[(Ie)$TELEX]} )) \
  || log_die "Nguồn $TELEX chưa được bật (script không tự bật, N4)."
ORIGINAL_SOURCE="$("$INPUT_SOURCE" current)"

OUT="$ROOT/build/load/heavy-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUT"
SUMMARY="$OUT/summary.tsv"
STATS="$OUT/stats.tsv"
print -r -- $'group\tsource\tload\tapp\ttext_ok\tlate\tmismatch\tresync\tgap_lt10\tlag_p50_us\tlag_p99_us\treplace_p50_us\treplace_p99_us' > "$SUMMARY"
print -r -- $'stage\ttime\tload_1m\tmem_free\tdau_rss_kb' > "$STATS"

LOAD_PIDS=()
start_load() {
  local i
  for i in {1..$CORES}; do yes > /dev/null & LOAD_PIDS+=($!); done
  memory_pressure -l warn > "$OUT/memory_pressure.log" 2>&1 & LOAD_PIDS+=($!)
  log_step "Đã bật tải, chờ $RAMP_S giây"
  # Fixed: the load average and the memory pressure need time to build up.
  sleep $RAMP_S
}
stop_load() {
  (( ${#LOAD_PIDS} )) || return 0
  kill $LOAD_PIDS 2>/dev/null
  LOAD_PIDS=()
  log_step "Đã tắt tải"
}
stats() { # stage
  local pid rss="-"
  pid="$(pgrep -x DauInputMethod | head -1)"
  [[ -n "$pid" ]] && rss="$(ps -o rss= -p $pid | tr -d ' ')"
  print -r -- "$1"$'\t'"$(date +%T)"$'\t'"$(load_1m)"$'\t'"$(memory_pressure -Q 2>/dev/null | tail -1 | sed 's/.*: //')"$'\t'"$rss" >> "$STATS"
}
cleanup() {
  stop_load
  if [[ "$("$INPUT_SOURCE" current 2>/dev/null)" != "$ORIGINAL_SOURCE" ]]; then
    "$INPUT_SOURCE" select "$ORIGINAL_SOURCE" >/dev/null 2>&1 \
      && log_warn "Đã chọn lại nguồn lúc đầu ($ORIGINAL_SOURCE) bằng API" \
      || log_warn "Không chọn lại được nguồn $ORIGINAL_SOURCE"
  fi
  log_step "Tóm tắt ($SUMMARY)"
  column -t -s $'\t' "$SUMMARY"
  column -t -s $'\t' "$STATS"
  log_detail "kết quả: $OUT"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

# As in load/run.sh: value of metric $2 in perf-report output $1 ("-" when absent).
metric() {
  local line
  line="$(grep -E "^  $2 " "$1" 2>/dev/null | head -1)"
  [[ -n "$line" ]] || { print -r -- "-"; return; }
  if [[ -n "${3:-}" ]]; then
    print -r -- "${${line#*$3=}%% *}"
  else
    print -r -- "${${(z)line}[2]}"
  fi
}
sum() {
  local total=0 any=0 v
  for v in "$@"; do [[ $v == - ]] || { (( total += v )); any=1; }; done
  (( any )) && print -r -- $total || print -r -- "-"
}

STATUS=0
index=0
loaded=0
for g in $PLAN; do
  (( index += 1 ))
  parts=(${=g}); src=$parts[1]; load=$parts[2]; apps=(${parts[3,-1]})
  if [[ $load == load && $loaded == 0 ]]; then start_load; loaded=1; fi
  if [[ $load == idle && $loaded == 1 ]]; then
    stop_load; loaded=0
    # Fixed: the same time the load was given to build up, for it to go away.
    sleep $RAMP_S
  fi
  dir="$OUT/$index-$src-$load"
  mkdir -p "$dir"
  args=(--delay $DELAY_MS --keys "$KEYS" --expect "$EXPECT" --save "$dir" --keep-source)
  [[ $src == telex ]] && args+=(--source $TELEX)
  log_step "Nhóm $index/${#PLAN}: $src, $load, ${(j: :)apps}"
  stats "$index-before"
  rc=0
  "$TYPING" $args $apps > "$dir/typing.log" 2>&1 || rc=$?
  stats "$index-after"
  for app in $apps; do
    [[ -f "$dir/$app.txt" ]] || continue
    ok=0; grep -q "^✓ $app đạt" "$dir/typing.log" && ok=1
    row=($index $src $load $app $ok - - - - - - - -)
    if [[ $src != dau ]]; then
      # The control is compared with itself: its idle text is the reference for its
      # loaded text. Dấu's expected text is not the control's (Apple's Telex keeps
      # "mêting" where Dấu restores "meeting", D4).
      ref="$OUT/$src-$app.idle.txt"
      if [[ $load == idle ]]; then
        cp "$dir/$app.txt" "$ref"; ok=ref
        log_ok "$app: chữ lúc rảnh của $src, làm mốc"
      elif [[ -f "$ref" ]] && cmp -s "$dir/$app.txt" "$ref"; then
        ok=1; log_ok "$app: chữ giống lúc rảnh"
      else
        ok=0; log_error "$app: chữ khác lúc rảnh (so $dir/$app.txt với $ref)"
      fi
      row=($index $src $load $app $ok - - - - - - - -)
      print -r -- "${(pj:\t:)row}" >> "$SUMMARY"
      continue
    fi
    if [[ $src == dau ]]; then
      p="$dir/$app.perf.txt"
      # --app matches part of the bundle ID: vscodefile is VS Code.
      "$REPORT" --input "$dir/$app.perf.log" --app ${app%file} > "$p" 2>&1
      if [[ "$(metric "$p" gap_d_ge20ms)" == - ]]; then
        log_error "Nhóm $index, $app: nhật ký không có thời điểm phím (t_ns): bộ gõ đã cài là bản Release."
        log_hint "Cài bản Debug rồi chạy lại."
        STATUS=1
        break 2
      fi
      row=(
        $index $src $load $app $ok
        "$(sum "$(metric "$p" count_late)" "$(metric "$p" count_late_guess)")"
        "$(metric "$p" count_mismatch)"
        "$(sum "$(metric "$p" count_resync)" "$(metric "$p" count_resync_pass)")"
        "$(sum "$(metric "$p" gap_a_lt2ms)" "$(metric "$p" gap_b_2to10ms)")"
        "$(metric "$p" lag_us p50)" "$(metric "$p" lag_us p99)"
        "$(metric "$p" handle_replace_us p50)" "$(metric "$p" handle_replace_us p99)"
      )
    fi
    print -r -- "${(pj:\t:)row}" >> "$SUMMARY"
    if (( ok )); then log_ok "$app: đúng chữ"; else log_error "$app: sai chữ (xem $dir/$app.txt)"; fi
  done
  if (( rc > 1 )); then
    tail -5 "$dir/typing.log" >&2
    log_error "Nhóm $index dừng (mã thoát $rc); nhật ký: $dir/typing.log"
    STATUS=$rc
    break
  fi
  # Fixed, as load/run.sh: typing/run.sh reads the log from a start time in whole seconds.
  sleep 1
done

(( STATUS == 0 )) && log_done
exit $STATUS
