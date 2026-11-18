#!/bin/zsh
# Checks the appcast: it holds the newest published beta; a beta's item is tagged beta; a promoted appcast is the same with that tag removed.
# Side effects: none (reads git and, through gh, GitHub; creates nothing)
# Three checks, by option:
#
# 1. Base (no --beta, no --promoted). The item of a release reaches site/appcast.xml only at the
# "publish" step, after the tag, so the appcast at the tagged commit can lack the previous
# release. The base appcast is therefore the one on origin/main (what Vercel serves), and
# build-release.sh (signed mode) refuses to build when it lacks the newest published beta. A
# stable release adds no item (it is its beta's binary, D7), so the newest published beta is the
# item that must be there. The item is found by its enclosure URL, which holds the tag
# (…/releases/download/<tag>/…).
#
# 2. --beta TAG: the appcast build-release.sh made. The item of TAG is the newest (first) and
# carries <sparkle:channel>beta</sparkle:channel>: an item without it is a stable release every
# channel sees (D7). With --base FILE (the appcast it was made from) also: exactly one item was
# added, every earlier item keeps its version, channel tag and URL, and the build number of the
# new item is not one of the earlier ones.
#
# 3. --promoted TAG --before FILE: the appcast promote-release.sh made from FILE. The item of TAG
# has no channel tag (stable) and the file equals FILE with only that tag removed, byte for byte:
# no item added or changed, EdDSA signatures included (they sign the archive, not the item).
#
# Usage:
#   scripts/release/check-appcast.sh [--appcast FILE] [--latest TAG]
#   scripts/release/check-appcast.sh --beta TAG --appcast FILE [--base FILE]
#   scripts/release/check-appcast.sh --promoted TAG --appcast FILE --before FILE
#     --appcast   check this file instead of site/appcast.xml on origin/main (required by 2 and 3).
#     --latest    the newest published beta tag, instead of asking GitHub (gh release list).
#     --beta      the beta tag whose item must be tagged beta (check 2).
#     --base      the appcast the new one was made from (check 2).
#     --promoted  the beta tag that was promoted to stable (check 3).
#     --before    the appcast before promotion (check 3).
# With no published beta there is nothing to lose: check 1 passes.
# Exit status: 0 passes; 1 fails; 2 bad usage.

set -euo pipefail
source "${${(%):-%x}:A:h:h}/lib/log.sh"
source "${${(%):-%x}:A:h:h}/lib/appcast.sh"
DAU_ROOT=${${(%):-%x}:A:h:h:h}

file="" latest="" beta="" base="" promoted="" before=""
while (( $# )); do
  case $1 in
    --appcast)  file=${2-}; shift 2 || log_die 2 "--appcast cần một đường dẫn" ;;
    --latest)   latest=${2-}; shift 2 || log_die 2 "--latest cần một tag" ;;
    --beta)     beta=${2-}; shift 2 || log_die 2 "--beta cần một tag" ;;
    --base)     base=${2-}; shift 2 || log_die 2 "--base cần một đường dẫn" ;;
    --promoted) promoted=${2-}; shift 2 || log_die 2 "--promoted cần một tag" ;;
    --before)   before=${2-}; shift 2 || log_die 2 "--before cần một đường dẫn" ;;
    -h|--help)  log_usage "${(%):-%x}"; exit 0 ;;
    *)          log_die 2 "Tuỳ chọn lạ: $1" ;;
  esac
done

# --- check 2: a beta's item is tagged beta -----------------------------------------------------
if [[ -n $beta ]]; then
  [[ -z $promoted ]] || log_die 2 "--beta và --promoted không đi cùng nhau."
  [[ -f $file ]] || log_die 2 "--beta cần --appcast FILE có thật."
  summary=(${(f)"$(appcast_summary "$file")"})
  (( ${#summary} )) || log_die 1 "Appcast không có mục nào."
  [[ ${summary[1]#*|*|} == *"/releases/download/$beta/"* ]] \
    || log_die 1 "Mục đầu của appcast không phải của $beta: mục mới phải đứng đầu."
  channel=$(appcast_item_channel "$file" "$beta")
  [[ $channel == beta ]] \
    || log_die 1 "Mục của $beta ghi kênh '$channel', cần <sparkle:channel>beta</sparkle:channel>: thiếu thẻ thì mọi người dùng, kể cả kênh Chính thức, nhận bản beta (D7)."
  log_ok "Mục của $beta mang thẻ kênh beta"
  if [[ -n $base ]]; then
    [[ -f $base ]] || log_die 2 "Không thấy $base."
    old=(${(f)"$(appcast_summary "$base")"})
    (( ${#summary} == ${#old} + 1 )) || log_die 1 "Appcast mới có ${#summary} mục, appcast nền có ${#old}: phải thêm đúng một mục."
    [[ ${(F)summary[2,-1]} == ${(F)old} ]] \
      || log_die 1 "Các mục cũ đã đổi (phiên bản, thẻ kênh hay địa chỉ) so với appcast nền: bản mới chỉ được thêm một mục."
    new_version=${summary[1]%%|*}
    for line in $old; do
      [[ ${line%%|*} != $new_version ]] || log_die 1 "Số build $new_version đã có trong appcast nền: Sparkle coi hai bản cùng số là một (docs/Releasing.md, \"Số build\")."
    done
    log_ok "Chỉ thêm một mục; ${#old} mục cũ giữ nguyên phiên bản, thẻ kênh và địa chỉ"
  fi
  exit 0
fi

# --- check 3: a promoted appcast ---------------------------------------------------------------
if [[ -n $promoted ]]; then
  [[ -f $file && -f $before ]] || log_die 2 "--promoted cần --appcast FILE và --before FILE có thật."
  channel=$(appcast_item_channel "$file" "$promoted")
  [[ $channel == "-" ]] \
    || log_die 1 "Mục của $promoted ghi kênh '$channel': bản chính thức không được mang thẻ kênh (D7)."
  expected=$(appcast_untag "$before" "$promoted") \
    || log_die 1 "Appcast trước quảng bá không có mục beta của $promoted mang thẻ kênh beta."
  if [[ -z $(tail -c1 "$before") ]]; then expected+=$'\n'; fi
  cmp -s "$file" <(print -rn -- "$expected") \
    || log_die 1 "Appcast sau quảng bá khác appcast trước ở chỗ ngoài thẻ kênh của $promoted: không được thêm hay đổi gì khác (D7)."
  log_ok "Appcast quảng bá chỉ khác bản trước ở thẻ kênh của $promoted"
  exit 0
fi

# --- check 1: the base appcast holds the newest published beta ---------------------------------
content=""
if [[ -n $file ]]; then
  [[ -f $file ]] || log_die 2 "Không thấy $file."
  content=$(<"$file")
else
  git -C "$DAU_ROOT" rev-parse --verify --quiet origin/main >/dev/null \
    || log_die 1 "Không thấy origin/main: chạy 'git fetch origin main' rồi thử lại (appcast nền lấy từ đó)."
  content=$(git -C "$DAU_ROOT" show origin/main:site/appcast.xml) \
    || log_die 1 "origin/main không có site/appcast.xml."
fi

if [[ -z $latest ]]; then
  command -v gh >/dev/null || log_die 1 "Cần GitHub CLI để xem các bản đã công bố: brew install gh"
  # Newest first by publication date; drafts are not published.
  list=$(gh release list --exclude-drafts --limit 100 --json tagName,publishedAt \
    --jq 'sort_by(.publishedAt) | reverse | .[].tagName') \
    || log_die 1 "Không đọc được danh sách bản phát hành bằng gh."
  for t in ${(f)list}; do
    [[ $t == v<->.<->.<->-beta.<-> ]] && { latest=$t; break; }
  done
fi
if [[ -z $latest ]]; then
  log_ok "Chưa có bản beta nào được công bố: appcast nền không thiếu gì"
  exit 0
fi
[[ $content == *"/releases/download/$latest/"* ]] \
  || log_die 1 "Appcast nền không có mục của $latest, bản beta mới nhất đã công bố: dựng bản mới sẽ làm mất nó. Chép appcast.xml của bản đó vào site/appcast.xml, đẩy lên main (bước Công bố, docs/Releasing.md) rồi tag lại."
log_ok "Appcast nền có mục của $latest"
