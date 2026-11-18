#!/bin/zsh
# Checks that the appcast to build on holds the newest published beta, so a new release does not drop its item.
# Side effects: none (reads git and, through gh, GitHub; creates nothing)
# The item of a release reaches site/appcast.xml only at the "publish" step, after the tag, so the
# appcast at the tagged commit can lack the previous release. The base appcast is therefore the
# one on origin/main (what Vercel serves), and build-release.sh (signed mode) refuses to build
# when it lacks the newest published beta. A stable release adds no item (it is its beta's
# binary, D7), so the newest published beta is the item that must be there. The item is found by
# its enclosure URL, which holds the tag (…/releases/download/<tag>/…).
#
# Usage:
#   scripts/release/check-appcast.sh [--appcast FILE] [--latest TAG]
#     --appcast  check this file instead of site/appcast.xml on origin/main.
#     --latest   the newest published beta tag, instead of asking GitHub (gh release list).
# With no published beta there is nothing to lose: passes.
# Exit status: 0 passes; 1 fails; 2 bad usage.

set -euo pipefail
source "${${(%):-%x}:A:h:h}/lib/log.sh"
DAU_ROOT=${${(%):-%x}:A:h:h:h}

file="" latest=""
while (( $# )); do
  case $1 in
    --appcast) file=${2-}; shift 2 || log_die 2 "--appcast cần một đường dẫn" ;;
    --latest)  latest=${2-}; shift 2 || log_die 2 "--latest cần một tag" ;;
    -h|--help) log_usage "${(%):-%x}"; exit 0 ;;
    *)         log_die 2 "Tuỳ chọn lạ: $1" ;;
  esac
done

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
