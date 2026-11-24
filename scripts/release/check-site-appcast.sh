#!/bin/zsh
# Checks that the appcast the site serves is the one in git, byte for byte, and is never cached for long.
# Side effects: network (one GET of https://dau.codefastlabs.com/appcast.xml; writes only a temp file)
# Sparkle in every installed Dấu reads that URL, and the appcast goes through the site's build
# (site/vercel.json), so after each production deployment this compares what the site serves with
# site/appcast.xml of the commit that was deployed. It also checks the response header
# Cache-Control holds max-age=0 and must-revalidate: Sparkle must always see the newest appcast.
# docs/Releasing.md ("Vercel", "Công bố") and site.yml (job on deployment_status) call it.
#
# Usage: scripts/release/check-site-appcast.sh [<git-ref>]
#   <git-ref>   the commit whose site/appcast.xml is the expected file (default origin/main). site.yml
#               passes the SHA of the deployment.
#   DAU_SITE_URL overrides the site address (default https://dau.codefastlabs.com), for a preview deployment.
# Exit status: 0 the bytes are equal and the header is right; 1 they are not or the download failed;
# 2 bad usage.

set -uo pipefail
source "${${(%):-%x}:A:h:h}/lib/log.sh"
DAU_ROOT=${${(%):-%x}:A:h:h:h}

case ${1-} in
  -h|--help) log_usage "${(%):-%x}"; exit 0 ;;
  -*)        log_die 2 "Tuỳ chọn lạ: $1" ;;
esac
(( $# <= 1 )) || log_die 2 "Chỉ nhận một đối số: <git-ref>."
ref=${1:-origin/main}
url=${DAU_SITE_URL:-https://dau.codefastlabs.com}/appcast.xml

work=$(mktemp -d "${TMPDIR:-/tmp}/dau-site-appcast.XXXXXX")
trap 'command rm -rf "$work"' EXIT

log_step "Appcast trong git ($ref) và trên trang"
git -C "$DAU_ROOT" show "${ref}:site/appcast.xml" > "$work/expected.xml" 2>"$work/git-error" \
  || log_die "Không đọc được site/appcast.xml ở $ref: $(<"$work/git-error")" "Đã fetch chưa? git fetch origin main"

# -f: an HTTP error status is a failure, not a body to compare. -D: the response headers.
curl -fsS --max-time 30 --retry 2 -D "$work/headers" -o "$work/served.xml" "$url" 2>"$work/curl-error" \
  || log_die "Không tải được $url: $(<"$work/curl-error")"

failed=0
if cmp -s "$work/expected.xml" "$work/served.xml"; then
  log_ok "Appcast trên trang giống từng byte site/appcast.xml ở $ref"
else
  log_error "Appcast trên trang khác site/appcast.xml ở $ref (trang $(wc -c < "$work/served.xml" | tr -d ' ') byte, git $(wc -c < "$work/expected.xml" | tr -d ' ') byte)."
  log_hint "Vercel chưa triển khai xong commit này, hoặc bản dựng đã đổi appcast. Xem diff: diff <(git show ${ref}:site/appcast.xml) <(curl -s $url)"
  failed=1
fi

# curl -D keeps every response of a redirect chain; the last block is the one that served the file.
cache_control=${(L)$(awk '/^HTTP\// { v = "" } tolower($1) == "cache-control:" { sub(/^[^:]*:[ \t]*/, ""); sub(/\r$/, ""); v = $0 } END { print v }' "$work/headers")}
max_age_zero='(^|[ ,])max-age=0($|[ ,])'
if [[ $cache_control =~ $max_age_zero && $cache_control == *must-revalidate* ]]; then
  log_ok "Cache-Control: $cache_control"
else
  log_error "Cache-Control là '${cache_control:-(không có)}', cần có max-age=0 và must-revalidate (site/vercel.json)."
  log_hint "Sparkle phải luôn đọc appcast mới; một header cache dài làm bản cập nhật tới chậm."
  failed=1
fi

(( failed == 0 )) || exit 1
log_done "Appcast trên trang đúng"
