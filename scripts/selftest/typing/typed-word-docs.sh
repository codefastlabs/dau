#!/bin/zsh
# Checks "Thêm dấu cho từ đã gõ" (D20) in Google Docs (Chrome, Safari) and Word for the web (Chrome): a
# sentence that goes back over the space (⌫) to add a tone or a vowel mark to the word just
# typed, with a ⌫ inside an English word, typed at a human pace. Dấu three times per
# document, then the macOS Vietnamese Telex once as the control (same keys, same document).
# Side effects: builds, takes the screen, changes input source, changes user settings
#
# Usage: scripts/selftest/typing/typed-word-docs.sh [--runs N] [gdocs] [gdocssafari] [wordweb]
#   gdocs           Google Docs in Chrome
#   gdocssafari     Google Docs in Safari
#   wordweb         Word for the web in Chrome
#   --runs N        Dấu runs per document (default 3)
# No cell named: all three. Each cell creates one new document in the account signed in in its
# browser (docs.new, word.new) and every run of the cell types into it; the document stays in
# that account (its link is printed at the end, to delete by hand). Each run goes through
# scripts/selftest/typing/run.sh (its safety rules apply, the document is left empty). Both
# input sources must be enabled already (N4). Text read back and the documents' links:
# build/typed-word-docs/<time>/ (git-ignored).
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
typeset -a APPS
while [[ $# -gt 0 ]]; do
  case "$1" in
    gdocs|gdocssafari|wordweb) APPS+=("$1"); shift ;;
    --runs) RUNS="${2:?--runs cần số lượt}"; shift 2 ;;
    -h|--help) log_usage "${0:A}"; exit 0 ;;
    *) log_die 2 "Tham số không hợp lệ: $1" ;;
  esac
done
(( ${#APPS} )) || APPS=(gdocs gdocssafari wordweb)
[[ "$RUNS" =~ ^[1-9][0-9]*$ ]] || log_die 2 "--runs phải là số nguyên dương"

OUT="$ROOT/build/typed-word-docs/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUT"
typeset -a SUMMARY
cell() { # app run-label [run.sh options]
  local app="$1" label="$2"; shift 2
  local dir="$OUT/$app-$label" st
  log_step "$app · $label"
  "$HERE/run.sh" "${PACE[@]}" --keys "$KEYS" --expect "$EXPECT" --save "$dir" \
    --doc-file "$OUT/$app.url" "$@" "$app"
  st=$?
  SUMMARY+=("$app $label: $(case $st in 0) print đạt ;; 1) print sai ;; 3|4) print "dừng (mã $st)" ;; *) print "lỗi (mã $st)" ;; esac)")
  return $st
}
for app in "${APPS[@]}"; do
  for i in {1..$RUNS}; do
    cell "$app" "dau-$i"
    (( $? >= 3 )) && { log_error "Dừng cả lượt sau ô $app dau-$i."; break 2; }
  done
  cell "$app" apple --source "$APPLE_TELEX"
  (( $? >= 3 )) && { log_error "Dừng cả lượt sau ô $app apple."; break; }
done
log_step "Tóm tắt"
print -rl -- "${SUMMARY[@]}"
for app in "${APPS[@]}"; do
  [[ -s "$OUT/$app.url" ]] && log_detail "tài liệu $app (xoá tay khi không cần): $(<"$OUT/$app.url")"
done
log_detail "chữ đọc lại: $OUT"
