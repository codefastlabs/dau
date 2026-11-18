#!/bin/zsh
# Promotes the last beta of a version to its stable release: a draft GitHub release for vX.Y.Z with the beta's DMG and dSYMs (D7).
# Side effects: builds (downloads the beta's assets into build/); unless --dry-run also: changes GitHub (creates a draft release)
# The stable release is the binary of the last beta, unchanged and not rebuilt (like an Apple
# release candidate): same DMG, same signature, same stapled notarization ticket, same
# CFBundleVersion. Only the file name changes (Dau-X.Y.Z-beta.N.dmg -> Dau-X.Y.Z.dmg), which
# the DMG signature and the ticket do not cover (they are over the contents, checked below
# with codesign, stapler and spctl on the renamed file). The appcast is not touched: the
# beta's item is already there for everyone (one channel, D7) with the same sparkle:version.
#
# Usage:
#   scripts/release/promote-release.sh --tag vX.Y.Z [--dry-run] [--out DIR]
#     --tag      the stable tag. It must exist and point at the commit of a vX.Y.Z-beta.N tag
#                whose GitHub release is published; the beta with the largest N on that commit is
#                used. Anything else is refused: to change something after the last beta, make
#                another beta (build-release.sh).
#     --dry-run  download and check, create nothing on GitHub.
#     --out      download directory (default build/promote; wiped first, must be inside build/).
# Before anything it runs check-release-gate.sh: the commit must be on origin/main and have passed the
# Test workflow. Needs the GitHub CLI (gh), logged in (GH_TOKEN on CI), and the tags and origin/main fetched.
# The draft is not a pre-release; publishing it and the Homebrew cask: docs/Releasing.md.
# Exit status: 0 done; 1 a check failed; 2 bad usage.

set -euo pipefail
source "${${(%):-%x}:A:h:h}/lib/build.sh"

tag=${GITHUB_REF_NAME-} dry=0 out=$DAU_ROOT/build/promote
while (( $# )); do
  case $1 in
    --tag)     tag=${2-}; shift 2 || log_die 2 "--tag cần một giá trị" ;;
    --dry-run) dry=1; shift ;;
    --out)     out=${2-}; shift 2 || log_die 2 "--out cần một đường dẫn" ;;
    -h|--help) log_usage "${(%):-%x}"; exit 0 ;;
    *)         log_die 2 "Tuỳ chọn lạ: $1" ;;
  esac
done
[[ $tag == v<->.<->.<-> ]] || log_die 2 "Cần --tag vX.Y.Z (bản chính thức); nhận '${tag}'. Bản beta dựng bằng build-release.sh."
out=${out:A}
[[ $out == $DAU_ROOT/build/?* ]] || log_die 2 "--out phải nằm trong build/ của repo (thư mục này bị xoá trước khi tải)."
command -v gh >/dev/null || log_die "Cần GitHub CLI: brew install gh"

version=${tag#v}
commit=$(git -C "$DAU_ROOT" rev-list -n1 "$tag" 2>/dev/null) || log_die "Không thấy tag $tag trong repo (đã fetch tag chưa?)."

# --- find the beta ---------------------------------------------------------------
betas=(${(f)"$(git -C "$DAU_ROOT" tag --points-at "$commit" -l "v$version-beta.*")"})
(( ${#betas} )) || log_die "Tag $tag trỏ vào commit ${commit[1,9]}, nơi không có tag v$version-beta.N nào. Bản chính thức phải đúng commit của beta cuối; cần sửa gì thì phát thêm một beta (D7)."
beta=${${(On)betas}[1]}   # largest N
"$DAU_ROOT/scripts/release/check-release-gate.sh" --tag "$tag" || exit 1
log_step "Quảng bá $beta thành $tag (commit ${commit[1,9]})"
(( ${#betas} == 1 )) || log_warn "Commit có nhiều tag beta (${(j:, :)betas}); dùng $beta."

gh release view "$tag" >/dev/null 2>&1 && log_die "Bản phát hành $tag đã có trên GitHub."
state=$(gh release view "$beta" --json isDraft,isPrerelease --jq '"\(.isDraft) \(.isPrerelease)"' 2>/dev/null) \
  || log_die "$beta chưa có bản phát hành trên GitHub."
[[ ${state%% *} == false ]] || log_die "Bản phát hành $beta vẫn là bản nháp: công bố nó trước (item của nó phải đã nằm trong appcast)."
[[ ${state##* } == true ]] || log_warn "Bản phát hành $beta không đánh dấu pre-release."

# --- download, rename --------------------------------------------------------------
rm -rf "$out"; mkdir -p "$out"
gh release download "$beta" --dir "$out" --pattern "Dau-*.dmg" --pattern "Dau-*.dSYMs.zip"
src_dmg=(${out}/Dau-*.dmg(N)) src_dsyms=(${out}/Dau-*.dSYMs.zip(N))
(( ${#src_dmg} == 1 && ${#src_dsyms} == 1 )) || log_die "$beta cần đúng một DMG và một dSYM; có ${#src_dmg} và ${#src_dsyms}."
[[ $src_dmg[1] != *-unsigned.dmg ]] || log_die "${src_dmg[1]:t} là bản không ký, không quảng bá."
dmg=$out/Dau-$version.dmg dsyms=$out/Dau-$version.dSYMs.zip
mv "$src_dmg[1]" "$dmg"; mv "$src_dsyms[1]" "$dsyms"
log_ok "Đã tải ${beta} và đổi tên: ${dmg:t}, ${dsyms:t}"

# --- check: the renamed file is still the signed, notarized beta ---------------------
codesign --verify --strict "$dmg" || log_die "Chữ ký DMG không hợp lệ."
xcrun stapler validate "$dmg" >/dev/null || log_die "DMG chưa có vé notarize."
spctl --assess --type open --context context:primary-signature --verbose=2 "$dmg" || log_die "spctl từ chối DMG."
mnt=$(mktemp -d "${TMPDIR:-/tmp}/dau-mnt.XXXXXX")
detach() { hdiutil detach "$mnt" -quiet 2>/dev/null || hdiutil detach "$mnt" -force -quiet 2>/dev/null || true; rmdir "$mnt" 2>/dev/null || true; }
trap detach EXIT
hdiutil attach "$dmg" -nobrowse -readonly -mountpoint "$mnt" >/dev/null 2>&1 || log_die "Không mở được DMG."
shown=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$mnt/Dau.app/Contents/Info.plist")
[[ $shown == $version ]] || log_die "Dau.app trong DMG hiển thị '$shown', cần '$version'."
log_ok "Chữ ký, vé notarize và spctl đạt; Dau.app hiển thị $shown"
detach; trap - EXIT

# --- draft release ---------------------------------------------------------------------
if (( dry )); then
  log_done "Chạy thử xong: chưa tạo gì trên GitHub (${out#$DAU_ROOT/})"
  exit 0
fi
gh release create "$tag" --verify-tag --draft --title "Dấu $version" --generate-notes "$dmg" "$dsyms"
log_done "Đã tạo bản nháp $tag từ $beta. Appcast không đổi; công bố theo docs/Releasing.md"
