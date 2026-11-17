#!/bin/zsh
# Checks "Thêm dấu cho từ đã gõ" (D20) in Google Docs (Chrome, Safari) and Word for the web (Chrome): a
# sentence that goes back over the space (⌫) to add a tone or a vowel mark to the word just
# typed, with a ⌫ inside an English word, typed at a human pace. Dấu three times per
# document, then the macOS Vietnamese Telex once as the control (same keys, same document).
# Side effects: builds, takes the screen, changes input source, changes user settings
#
# Usage: scripts/selftest/typing/d20-docs.sh [--runs N] [--gdocs URL] [--gdocssafari URL] [--wordweb URL]
#   --gdocs URL     an empty Google Docs document of your own, signed in in Chrome
#   --gdocssafari URL  the same in Safari (signed in in Safari)
#   --wordweb URL   an empty Word for the web document of your own, signed in in Chrome
#   --runs N        Dấu runs per document (default 3)
# At least one document. The links are private: give them on the command line, never commit
# them. Each cell goes through scripts/selftest/typing/run.sh (cells gdocs, gdocssafari, wordweb: its
# safety rules apply, the document is left empty). Both input sources must be enabled
# already (N4). Text read back: build/d20-docs/<time>/ (git-ignored).
set -uo pipefail
ROOT="${0:A:h:h:h:h}"
HERE="${0:A:h}"
source "$ROOT/scripts/lib/log.sh"

APPLE_TELEX=com.apple.inputmethod.VietnameseIM.VietnameseTelex
# Checked offline through the input method's model (ImkField) before it was used.
# ⌫ over the space then o / j / es / ej: D20 on the word before; onlinr⌫e: ⌫ inside a word.
KEYS='Hom ⌫o nay minhf hoc ⌫j tieng ⌫es Viet ⌫ej voiws banj, buooir hojc onlinr⌫e raats vui. '
EXPECT='Hôm nay mình học tiếng Việt với bạn, buổi học online rất vui. '
# A human pace: words in one burst, a stop between words (run.sh, --word-pause).
PACE=(--delay 80 --jitter 30 --word-pause 250)
RUNS=3
typeset -A URLS
while [[ $# -gt 0 ]]; do
  case "$1" in
    --gdocs) URLS[gdocs]="${2:?--gdocs cần đường dẫn}"; shift 2 ;;
    --gdocssafari) URLS[gdocssafari]="${2:?--gdocssafari cần đường dẫn}"; shift 2 ;;
    --wordweb) URLS[wordweb]="${2:?--wordweb cần đường dẫn}"; shift 2 ;;
    --runs) RUNS="${2:?--runs cần số lượt}"; shift 2 ;;
    -h|--help) log_usage "${0:A}"; exit 0 ;;
    *) log_die 2 "Tham số không hợp lệ: $1" ;;
  esac
done
(( ${#URLS} )) || { log_usage "${0:A}"; exit 2; }
[[ "$RUNS" =~ ^[1-9][0-9]*$ ]] || log_die 2 "--runs phải là số nguyên dương"

OUT="$ROOT/build/d20-docs/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUT"
typeset -a SUMMARY
cell() { # app run-label [run.sh options]
  local app="$1" label="$2"; shift 2
  local dir="$OUT/$app-$label" st
  log_step "$app · $label"
  "$HERE/run.sh" "${PACE[@]}" --keys "$KEYS" --expect "$EXPECT" --save "$dir" \
    --doc-url "${URLS[$app]}" "$@" "$app"
  st=$?
  SUMMARY+=("$app $label: $(case $st in 0) print đạt ;; 1) print sai ;; 3|4) print "dừng (mã $st)" ;; *) print "lỗi (mã $st)" ;; esac)")
  return $st
}
for app in gdocs gdocssafari wordweb; do
  [[ -n "${URLS[$app]:-}" ]] || continue
  for i in {1..$RUNS}; do
    cell "$app" "dau-$i"
    (( $? >= 3 )) && { log_error "Dừng cả lượt sau ô $app dau-$i."; break 2; }
  done
  cell "$app" apple --source "$APPLE_TELEX"
  (( $? >= 3 )) && { log_error "Dừng cả lượt sau ô $app apple."; break; }
done
log_step "Tóm tắt"
print -rl -- "${SUMMARY[@]}"
log_detail "chữ đọc lại: $OUT"
