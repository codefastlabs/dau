#!/bin/zsh
# Checks that a release tag may be built or promoted: its commit is on origin/main and the Test workflow passed on it.
# Side effects: none (reads git and, through gh, GitHub; creates nothing)
# Shared by build-release.sh (signed mode) and promote-release.sh, so the same rule runs on CI and
# on a development Mac. Without it a tag on a commit nobody tested, or one that never reached
# main, would ship to everyone through the appcast.
#
# Usage:
#   scripts/release/check-release-gate.sh --tag vX.Y.Z[-beta.N] [--commit SHA]
#     --tag     the release tag. Its commit is the one checked (the tag must exist, unless --commit).
#     --commit  check this commit instead of the tag's: for a build before the tag exists.
# Needs origin/main fetched (git fetch origin main; the release workflow checks out the whole
# history) and, for the Test result, gh logged in (GH_TOKEN on CI, with actions: read).
# Exit status: 0 both checks pass; 1 a check fails; 2 bad usage.

set -euo pipefail
source "${${(%):-%x}:A:h:h}/lib/log.sh"
DAU_ROOT=${${(%):-%x}:A:h:h:h}

tag="" commit=""
while (( $# )); do
  case $1 in
    --tag)     tag=${2-}; shift 2 || log_die 2 "--tag cần một giá trị" ;;
    --commit)  commit=${2-}; shift 2 || log_die 2 "--commit cần một giá trị" ;;
    -h|--help) log_usage "${(%):-%x}"; exit 0 ;;
    *)         log_die 2 "Tuỳ chọn lạ: $1" ;;
  esac
done
[[ -n $tag ]] || log_die 2 "Cần --tag."
if [[ -z $commit ]]; then
  commit=$(git -C "$DAU_ROOT" rev-list -n1 "$tag" 2>/dev/null) || log_die 1 "Không thấy tag $tag trong repo (đã fetch tag chưa?)."
fi
short=${commit[1,9]}

git -C "$DAU_ROOT" rev-parse --verify --quiet origin/main >/dev/null \
  || log_die 1 "Không thấy origin/main: chạy 'git fetch origin main' rồi thử lại."
git -C "$DAU_ROOT" merge-base --is-ancestor "$commit" origin/main \
  || log_die 1 "Commit $short của $tag không nằm trong origin/main: chỉ phát hành commit đã lên main (đã đẩy main chưa? 'git fetch origin main')."
log_ok "Commit $short nằm trong origin/main"

command -v gh >/dev/null || log_die 1 "Cần GitHub CLI để xem kết quả workflow Test: brew install gh"
passed=$(gh run list --workflow test.yml --commit "$commit" --json conclusion --jq 'map(select(.conclusion == "success")) | length') \
  || log_die 1 "Không đọc được kết quả workflow Test của commit $short bằng gh (đã đăng nhập, có quyền xem Actions chưa?)."
[[ $passed == <-> && $passed -gt 0 ]] \
  || log_die 1 "Workflow Test chưa đạt trên commit $short (không có lần chạy thành công): đợi nó xanh hoặc sửa rồi tag lên commit mới."
log_ok "Workflow Test đã đạt trên commit $short"
