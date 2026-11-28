#!/bin/zsh
# Builds a beta of the official Dấu release: archive, signature, DMG, appcast (D6, D7); with Developer ID also export, notarize, staple.
# Side effects: builds; with --layout: takes the screen
# One path from source to DMG, the same on CI and on a development Mac. Without the signing
# secrets it still runs to the DMG ("unsigned" build) and says which steps it skipped.
# The release signs with one identity at a time (D6): the Personal Team's Apple Development
# certificate (not notarized) until the notary variables below are set, then Developer ID.
#
# A stable tag (vX.Y.Z) is NOT built: the stable release is the binary of the last beta,
# unchanged and not rebuilt (D7), so it has no build to run and nothing to sign. This script
# refuses it and points to promote-release.sh, which copies the beta's assets. Anything to fix
# after the last beta is a new beta, on a new commit.
#
# Signed mode refuses to start (before the long build) unless, in order: the tagged commit is
# HEAD, is on origin/main and passed the Test workflow (check-release-gate.sh); the tag has no
# release yet, draft or published (a published tag is never built again; after a failed run,
# delete the draft and the tag and tag a new commit); and the appcast on origin/main holds the
# newest published beta (check-appcast.sh), and the build number is not one already in it (Sparkle
# treats two builds with one number as one: a hotfix from an older branch needs --build-number in
# the gap, docs/Releasing.md "Số build"). The base appcast is that file, not the one at the
# tagged commit: an item reaches site/appcast.xml only after the tag, at the publish step.
#
# Usage:
#   scripts/release/build-release.sh [--tag vX.Y.Z-beta.N] [--build-number N] [--unsigned] [--layout] [--out DIR]
#     --tag           the beta tag; sets the displayed version, the same for every beta of a version
#                     and for its stable release: v0.1.0-beta.1 is "0.1.0" (MARKETING_VERSION, always
#                     three integers). The "beta N" lives only outside the binary (tag, GitHub
#                     release title) (D7). Default: $GITHUB_REF_NAME when it looks like a tag, else
#                     the version in project.yml.
#     --build-number  CFBundleVersion, the number Sparkle compares. Default: ten times the number
#                     of commits in HEAD (git rev-list --count). It grows with history and is the
#                     same on every machine. One number per build, so a new beta needs a new commit:
#                     the script refuses a beta tag on a commit that already has another beta tag.
#     --unsigned      do not sign as an official build even when the secrets are there.
#     --layout        lay the DMG window out with Finder (layout-dmg.sh, takes the screen): CI only.
#     --out           output directory (default build/release; wiped first, must be inside build/).
#
# Mode, from the variables below (an empty variable counts as unset):
#   unsigned          none is set (or --unsigned).
#   signed, Personal  the first three are set, no notary variable: Apple Development certificate of the
#                     team, taken from the archive, DMG signed, not notarized (D6).
#   signed, Developer ID  all six are set: exported with Developer ID, notarized and stapled.
# Any other set is an error, so a mistyped secret never ships a build signed differently from the plan.
#   DAU_TEAM_ID                 Team ID of the signing certificate
#   DAU_SPARKLE_PUBLIC_KEY      public EdDSA key (from Sparkle's generate_keys), goes into Info.plist
#   DAU_SPARKLE_PRIVATE_KEY     private EdDSA key, base64 as exported by `generate_keys -x`; read from the
#                               environment and passed to generate_appcast on stdin: never written to disk or logged
#   DAU_NOTARY_KEY              App Store Connect API key (the .p8 text)
#   DAU_NOTARY_KEY_ID           its key ID
#   DAU_NOTARY_ISSUER_ID        its issuer ID
# The certificate with its private key (Apple Development, or Developer ID Application for the
# Developer ID mode) must be in a keychain on the search list (the CI workflow imports it from
# DAU_SIGNING_P12). The Apple Development one is matched on the Organizational Unit of its subject.
# The notary key is written to a 0600 file in $TMPDIR for notarytool, which only takes a path,
# and deleted when the script ends.
#
# Unsigned mode builds the app AS A DEVELOPMENT BUILD (D7, D25, D24): DAU_OFFICIAL=NO, so the
# development icon, no SUFeedURL and no SUPublicEDKey (Sparkle does not start), and ad hoc
# signing. It is for checking the pipeline, not for giving to users. With no Team ID the App
# Group is refused, so the input method and the app cannot share settings: it does not run
# like a real build. The DMG is named *-dev-unsigned.dmg and no appcast is made.
# Skipped there: signature, notarize, staple, DMG signature, appcast.
# Signed Personal mode skips only the export, notarize and staple.
#
# Output in --out: Dau-<version>.dmg (signed) or Dau-<version>-dev-unsigned.dmg,
# Dau-<version>.dSYMs.zip, Checksums.json (origin/main's site/src/data/Checksums.json, "{}" when absent, plus
# "<sparkle:version>": "<SHA-256 of the DMG>"; made in both modes, published like the appcast), appcast/appcast.xml
# (signed only: the site/appcast.xml of origin/main with this release added as a NEW item tagged
# <sparkle:channel>beta</sparkle:channel> (generate_appcast --channel beta; D7: an item without the tag
# is a stable release every channel sees); publishing it is a
# separate act, docs/Releasing.md), release-notes.md (signed only: release-notes-template.md, without
# the Gatekeeper part when notarized), summary.txt; with $GITHUB_OUTPUT set also dmg, dsyms,
# checksums, appcast, notes, display (X.Y.Z), label ("X.Y.Z beta N") and signed.
# Exit status: 0 done; 1 a step or a check failed; 2 bad usage.

set -euo pipefail
source "${${(%):-%x}:A:h:h}/lib/build.sh"
source "${${(%):-%x}:A:h:h}/lib/appcast.sh"
source "${${(%):-%x}:A:h:h}/lib/checksums.sh"

# hdiutil still works but prints a "deprecated, use diskutil image" warning on every call
# (macOS 27); other lines, including errors, pass through. Revisit if Apple removes it.
hdiutil() { command hdiutil "$@" 2> >(grep -v 'is deprecated' >&2); }

official_feed="https://dau.codefastlabs.com/appcast.xml"
download_base="https://github.com/codefastlabs/dau/releases/download"

tag=${GITHUB_REF_NAME-} build_number="" force_unsigned=0 layout=0 out=$DAU_ROOT/build/release
while (( $# )); do
  case $1 in
    --tag)          tag=${2-}; shift 2 || log_die 2 "--tag cần một giá trị" ;;
    --build-number) build_number=${2-}; shift 2 || log_die 2 "--build-number cần một số" ;;
    --unsigned)     force_unsigned=1; shift ;;
    --layout)       layout=1; shift ;;
    --out)          out=${2-}; shift 2 || log_die 2 "--out cần một đường dẫn" ;;
    -h|--help)      log_usage "${(%):-%x}"; exit 0 ;;
    *)              log_die 2 "Tuỳ chọn lạ: $1" ;;
  esac
done
# The output directory is wiped: only a folder under build/ of this repo is allowed.
out=${out:A}
[[ $out == $DAU_ROOT/build/?* ]] || log_die 2 "--out phải nằm trong build/ của repo (thư mục này bị xoá trước khi build)."

# --- version -----------------------------------------------------------------
display="" label="" file_version="dev"
if [[ $tag == v<->.<->.<->-beta.<-> ]]; then
  display=${${tag#v}%%-*}                 # X.Y.Z for every beta and the stable (D7)
  label="$display beta ${tag##*.}"        # for the GitHub release title, never in the binary
  file_version=${tag#v}
  # One number per build: a second beta on the same commit would get the same CFBundleVersion.
  tag_commit=$(git -C "$DAU_ROOT" rev-list -n1 "$tag" 2>/dev/null || git -C "$DAU_ROOT" rev-parse HEAD)
  others=(${(f)"$(git -C "$DAU_ROOT" tag --points-at "$tag_commit" -l 'v*-beta.*' | grep -vx -- "$tag" || true)"})
  (( ${#others} == 0 )) || log_die 2 "Commit ${tag_commit[1,9]} đã có tag beta khác (${(j:, :)others}): mỗi beta cần một commit mới để có số build riêng (D7)."
elif [[ $tag == v<->.<->.<-> ]]; then
  log_die 2 "Tag $tag là bản chính thức: bản chính thức là tệp nhị phân của beta cuối, giữ nguyên, không dựng lại (D7). Dùng scripts/release/promote-release.sh --tag $tag. Cần sửa gì thì phát thêm một beta."
elif [[ -n $tag && $tag == v* ]]; then
  log_die 2 "Tag '$tag' không đúng dạng vX.Y.Z-beta.N (D7)."
fi
[[ -n $build_number ]] || build_number=$(( $(git -C "$DAU_ROOT" rev-list --count HEAD) * 10 ))
[[ $build_number == <-> ]] || log_die 2 "--build-number phải là số nguyên."
version_args=(CURRENT_PROJECT_VERSION=$build_number)
[[ -n $display ]] && version_args+=("MARKETING_VERSION=$display")

# --- mode --------------------------------------------------------------------
core_vars=(DAU_TEAM_ID DAU_SPARKLE_PUBLIC_KEY DAU_SPARKLE_PRIVATE_KEY)
notary_vars=(DAU_NOTARY_KEY DAU_NOTARY_KEY_ID DAU_NOTARY_ISSUER_ID)
set_core=() missing_core=() set_notary=() missing_notary=()
for v in $core_vars; do if [[ -n ${(P)v-} ]]; then set_core+=$v; else missing_core+=$v; fi; done
for v in $notary_vars; do if [[ -n ${(P)v-} ]]; then set_notary+=$v; else missing_notary+=$v; fi; done
signed=0 developer_id=0
if (( ! force_unsigned && ${#set_core} + ${#set_notary} > 0 )); then
  (( ${#missing_core} == 0 )) || log_die "Có ${(j:, :)set_core} ${(j:, :)set_notary} nhưng thiếu ${(j:, :)missing_core}: cấu hình dở dang. Đặt đủ hoặc dùng --unsigned."
  (( ${#set_notary} == 0 || ${#missing_notary} == 0 )) \
    || log_die "Có ${(j:, :)set_notary} nhưng thiếu ${(j:, :)missing_notary}: notarize cần đủ ba biến. Đặt đủ, bỏ cả ba (ký Personal Team, không notarize) hoặc dùng --unsigned."
  signed=1
  (( ${#set_notary} )) && developer_id=1
fi
if (( signed )) && [[ -z $display ]]; then
  log_die 2 "Bản ký cần --tag vX.Y.Z-beta.N: tag đặt số phiên bản và địa chỉ tải trong appcast."
fi
# --- gates (signed mode only: an unsigned build only checks the pipeline) ----------------------
# B1 the tagged commit is on origin/main and the Test workflow passed on it; B2 a published tag is
# never built again; A1 the appcast on origin/main holds the newest published beta, so the new
# item does not replace it. All before the long build, so a refusal costs nothing.
base_appcast=""
trap '[[ -z $base_appcast ]] || command rm -f "$base_appcast"' EXIT
if (( signed )); then
  log_step "Kiểm điều kiện phát hành"
  [[ $tag_commit == $(git -C "$DAU_ROOT" rev-parse HEAD) ]] \
    || log_die "Tag $tag không trỏ vào HEAD (${tag_commit[1,9]}): bản ký chỉ dựng đúng commit được tag."
  "$DAU_ROOT/scripts/release/check-release-gate.sh" --tag "$tag" --commit "$tag_commit" || exit 1
  command -v gh >/dev/null || log_die "Cần GitHub CLI để kiểm bản phát hành đã có: brew install gh"
  existing=$(gh release view "$tag" --json isDraft --jq .isDraft 2>&1) || existing=${existing:-error}
  case $existing in
    false) log_die "Tag $tag đã có bản phát hành đã công bố: không bao giờ dựng lại một tag đã công bố. Cần sửa gì thì phát beta mới trên commit mới (docs/Releasing.md, \"Khi một bản bị hỏng\")." ;;
    true)  log_die "Tag $tag đã có bản nháp: xoá bản nháp và tag, rồi tag lại lên một commit mới (docs/Releasing.md, \"Phát hành một tag\")." ;;
    *"release not found"*) ;;
    *)     log_die "Không đọc được bản phát hành $tag bằng gh: $existing" ;;
  esac
  "$DAU_ROOT/scripts/release/check-appcast.sh" || exit 1
  base_appcast=$(mktemp "${TMPDIR:-/tmp}/dau-appcast.XXXXXX")
  git -C "$DAU_ROOT" show origin/main:site/appcast.xml > "$base_appcast"
  # A build number already in the appcast would make Sparkle treat two builds as one (a hotfix
  # from an older branch has a default number equal to a beta already out; docs/Releasing.md, "Số build").
  if appcast_has_version "$base_appcast" "$build_number"; then
    log_die "Số build $build_number đã có trong appcast nền (origin/main): Sparkle coi hai bản cùng số là một." \
      "Dùng --build-number với số nằm trong khoảng trống chưa dùng giữa hai mốc (docs/Releasing.md, \"Số build\")."
  fi
fi
signing_id=""
if (( developer_id )); then
  # find-identity lists a revoked certificate too (CSSMERR_*): drop those, match the Team ID.
  signing_id=$(security find-identity -v -p codesigning | grep "Developer ID Application" | grep "($DAU_TEAM_ID)" | grep -v CSSMERR | head -1 | awk '{print $2}') || true
  [[ -n $signing_id ]] || log_die "Không thấy chứng chỉ \"Developer ID Application\" của Team $DAU_TEAM_ID (còn hạn) trong keychain."
elif (( signed )); then
  signing_id=$(dau_team_signing_identity "$DAU_TEAM_ID") \
    || log_die "Không thấy chứng chỉ \"Apple Development\" của Team $DAU_TEAM_ID (còn hạn, chưa bị thu hồi) trong keychain."
fi

skipped=()
log_step "Phát hành Dấu ${display:-(phiên bản trong project.yml)}, số build $build_number"
if (( developer_id )); then log_detail "chế độ: ký Developer ID (Team $DAU_TEAM_ID), notarize, appcast"
elif (( signed )); then log_detail "chế độ: ký Apple Development của Personal Team $DAU_TEAM_ID, không notarize, appcast"
else log_warn "Chế độ KHÔNG KÝ: dựng như bản phát triển (D7), để kiểm quy trình; không phát cho người dùng, không lên appcast."; fi

# --- archive -----------------------------------------------------------------
rm -rf "$out"; mkdir -p "$out"
derived=$out/DerivedData archive=$out/Dau.xcarchive
command -v xcodegen >/dev/null || log_die "Cần XcodeGen: brew install xcodegen"
log_step "Sinh Dau.xcodeproj"
(cd "$DAU_ROOT" && xcodegen generate --quiet)

if (( signed )); then
  official=YES
  # The archive is signed with the exact identity (SHA-1): two certificates can share a name.
  sign_args=(CODE_SIGN_STYLE=Manual "CODE_SIGN_IDENTITY=$signing_id" DEVELOPMENT_TEAM=$DAU_TEAM_ID OTHER_CODE_SIGN_FLAGS=--timestamp)
  sparkle_args=(DAU_SPARKLE_PUBLIC_KEY=$DAU_SPARKLE_PUBLIC_KEY DAU_SPARKLE_FEED_URL=$official_feed)
else
  # A development build (D7): no feed and no key, so project.yml leaves them out of Info.plist.
  official=NO
  sign_args=(CODE_SIGN_STYLE=Manual CODE_SIGN_IDENTITY=- DEVELOPMENT_TEAM=)
  sparkle_args=()
fi
log_step "Archive Release universal (DAU_OFFICIAL=$official)"
xcodebuild archive \
  -project "$DAU_ROOT/Dau.xcodeproj" -scheme Dau -configuration Release \
  -destination 'generic/platform=macOS' -archivePath "$archive" -derivedDataPath "$derived" \
  -quiet DAU_OFFICIAL=$official $sparkle_args \
  $version_args $sign_args

app=$archive/Products/Applications/Dau.app
[[ -d $app ]] || log_die "Archive không có Dau.app."

# --- export (Developer ID) ---------------------------------------------------
# The Personal Team build is taken from the archive: Xcode already signed it with the Apple
# Development identity, and -exportArchive has no method for that certificate that keeps it.
if (( developer_id )); then
  log_step "Xuất bản ký Developer ID"
  cat > "$out/ExportOptions.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>method</key><string>developer-id</string>
<key>teamID</key><string>$DAU_TEAM_ID</string>
<key>signingStyle</key><string>manual</string>
<key>signingCertificate</key><string>Developer ID Application</string>
</dict></plist>
PLIST
  xcodebuild -exportArchive -archivePath "$archive" -exportPath "$out/export" \
    -exportOptionsPlist "$out/ExportOptions.plist" -quiet
  app=$out/export/Dau.app
  [[ -d $app ]] || log_die "Xuất archive không ra Dau.app."
else
  (( signed )) && skipped+=("xuất Developer ID (app lấy từ archive, ký Apple Development)") \
    || skipped+=("xuất và ký Developer ID (app ký tạm ad hoc)")
fi

# --- re-sign Sparkle (Personal Team) -------------------------------------------
# Xcode signs Sparkle.framework but leaves the code nested in it with the signature Sparkle ships
# (ad hoc); -exportArchive would re-sign it. Under the hardened runtime the app only loads
# Sparkle when both carry one Team ID, so the nested code is signed inside-out here, then the
# app again, because its seal covers the framework. The entitlements of each item are kept.
resign_sparkle() { # app identity
  local app=$1 identity=$2 framework item
  framework=$app/Contents/Frameworks/Sparkle.framework
  for item in $framework/Versions/B/XPCServices/*.xpc(N) $framework/Versions/B/Autoupdate $framework/Versions/B/Updater.app $framework "$app"; do
    codesign --force --sign "$identity" --timestamp --options runtime --preserve-metadata=entitlements "$item"
  done
}
if (( signed && ! developer_id )); then
  log_step "Ký lại mã của Sparkle và app bằng Apple Development"
  resign_sparkle "$app" "$signing_id"
fi

# --- notarize ----------------------------------------------------------------
notary_key_file=""
cleanup() {
  [[ -z $notary_key_file ]] || command rm -f "$notary_key_file"
  [[ -z $base_appcast ]] || command rm -f "$base_appcast"
  return 0
}
trap cleanup EXIT
notarize() { # file: submit, wait, fail unless Accepted (the log of a rejection is printed)
  local file=$1 result id nstatus
  result=$(xcrun notarytool submit "$file" --key "$notary_key_file" --key-id "$DAU_NOTARY_KEY_ID" \
    --issuer "$DAU_NOTARY_ISSUER_ID" --wait --output-format plist) || true
  id=$(print -r -- "$result" | /usr/libexec/PlistBuddy -c "Print :id" /dev/stdin 2>/dev/null) || id=""
  nstatus=$(print -r -- "$result" | /usr/libexec/PlistBuddy -c "Print :status" /dev/stdin 2>/dev/null) || nstatus=""
  if [[ $nstatus != Accepted ]]; then
    [[ -z $id ]] || xcrun notarytool log "$id" --key "$notary_key_file" --key-id "$DAU_NOTARY_KEY_ID" --issuer "$DAU_NOTARY_ISSUER_ID" >&2 || true
    log_die "Apple không chấp nhận ${file:t} (notarize, trạng thái '${nstatus}')."
  fi
}
if (( developer_id )); then
  notary_key_file=$(mktemp "${TMPDIR:-/tmp}/dau-notary.XXXXXX")
  chmod 600 "$notary_key_file"
  print -r -- "$DAU_NOTARY_KEY" > "$notary_key_file"
  log_step "Notarize Dau.app"
  ditto -c -k --keepParent "$app" "$out/Dau-notarize.zip"
  notarize "$out/Dau-notarize.zip"
  command rm -f "$out/Dau-notarize.zip"
  xcrun stapler staple "$app" >/dev/null
  log_ok "Dau.app đã notarize và staple"
else
  skipped+=("notarize và staple")
fi

# --- check the app -----------------------------------------------------------
check=("$DAU_ROOT/scripts/release/check-build.sh" "$app" --archive "$archive")
(( signed )) && check+=(--feed "$official_feed" --signed --team "$DAU_TEAM_ID")
(( developer_id )) && check+=(--developer-id)
DAU_SPARKLE_PUBLIC_KEY=${DAU_SPARKLE_PUBLIC_KEY-} "${check[@]}" || log_die "Bản build không đạt kiểm tra."

# --- DMG ---------------------------------------------------------------------
dmg_suffix=""
if (( ! signed )); then
  # Without a tag file_version is already "dev": Dau-dev-unsigned, not Dau-dev-dev-unsigned.
  [[ $file_version == dev ]] && dmg_suffix=-unsigned || dmg_suffix=-dev-unsigned
fi
dmg_name=Dau-$file_version$dmg_suffix.dmg
dmg=$out/$dmg_name
log_step "Dựng DMG: $dmg_name"
staging=$out/dmg-root
mkdir -p "$staging"
ditto "$app" "$staging/Dau.app"
ln -s /Applications "$staging/Applications"
bg_dir=$DAU_ROOT/Resources/Brand
if (( layout )); then
  if [[ -f $bg_dir/DmgBackground.png ]]; then
    mkdir -p "$staging/.background"
    if [[ -f $bg_dir/DmgBackground@2x.png ]]; then
      # One TIFF with both scales: Finder picks the one that fits the screen.
      tiffutil -cathidpicheck "$bg_dir/DmgBackground.png" "$bg_dir/DmgBackground@2x.png" -out "$staging/.background/DmgBackground.tiff" >/dev/null
    else
      cp "$bg_dir/DmgBackground.png" "$staging/.background/DmgBackground.png"
    fi
  else
    log_warn "Resources/Brand/DmgBackground.png chưa có: DMG không có ảnh nền."
  fi
fi
rw=$out/rw.dmg
hdiutil create -srcfolder "$staging" -volname "Dấu" -fs APFS -format UDRW -ov "$rw" >/dev/null
laid_out=no
if (( layout )); then
  if "$DAU_ROOT/scripts/release/layout-dmg.sh" "$rw"; then laid_out=yes
  else log_warn "Bố cục cửa sổ DMG không đạt: DMG vẫn dùng được nhưng mở ra không có bố cục thiết kế."; fi
else
  skipped+=("bố cục cửa sổ DMG (không có --layout: Finder mặc định, không nền)")
fi
# ULFO: lzfse, the compression Sparkle's documentation recommends for APFS images.
hdiutil convert "$rw" -format ULFO -o "$dmg" >/dev/null
command rm -rf "$rw" "$staging"

if (( developer_id )); then
  log_step "Ký và notarize DMG"
  codesign --force --sign "$signing_id" --timestamp "$dmg"
  notarize "$dmg"
  xcrun stapler staple "$dmg" >/dev/null
  log_ok "DMG đã ký, notarize và staple"
elif (( signed )); then
  log_step "Ký DMG"
  codesign --force --sign "$signing_id" --timestamp "$dmg"
  log_ok "DMG đã ký (Apple Development, không notarize)"
  skipped+=("notarize và staple")
else
  skipped+=("ký, notarize và staple DMG")
fi

# --- check the DMG -----------------------------------------------------------
log_step "Mở DMG (không hiện Finder) để kiểm nội dung"
mnt=$(mktemp -d "${TMPDIR:-/tmp}/dau-mnt.XXXXXX")
hdiutil attach "$dmg" -nobrowse -readonly -mountpoint "$mnt" >/dev/null
detach() { hdiutil detach "$mnt" -quiet 2>/dev/null || hdiutil detach "$mnt" -force -quiet 2>/dev/null || true; rmdir "$mnt" 2>/dev/null || true; }
trap 'detach; cleanup' EXIT
[[ -d $mnt/Dau.app ]] || log_die "DMG không có Dau.app."
[[ $(readlink "$mnt/Applications") == /Applications ]] || log_die "DMG không có liên kết Applications."
# diskutil prints the name decomposed (NFD): convert to NFC before comparing.
vol=$(diskutil info "$mnt" | awk -F': +' '/Volume Name/ {print $2}' | iconv -f UTF-8-MAC -t UTF-8)
[[ $vol == "Dấu" ]] || log_die "Tên ổ là '$vol', cần 'Dấu'."
log_ok "DMG có Dau.app, liên kết Applications, ổ tên Dấu"
if [[ $laid_out == yes ]]; then
  [[ -f $mnt/.DS_Store ]] && log_ok "DMG có bố cục (.DS_Store)" || log_die "DMG thiếu .DS_Store dù đã sắp xếp."
fi
dmg_check=("$DAU_ROOT/scripts/release/check-build.sh" "$mnt/Dau.app")
(( signed )) && dmg_check+=(--feed "$official_feed" --signed --team "$DAU_TEAM_ID")
(( developer_id )) && dmg_check+=(--developer-id)
DAU_SPARKLE_PUBLIC_KEY=${DAU_SPARKLE_PUBLIC_KEY-} "${dmg_check[@]}" || log_die "App trong DMG không đạt kiểm tra."
if (( signed )); then
  codesign --verify --strict "$dmg" || log_die "Chữ ký DMG không hợp lệ."
  [[ $(codesign -dvv "$dmg" 2>&1) == *"TeamIdentifier=$DAU_TEAM_ID"$'\n'* ]] || log_die "DMG không ký bằng Team $DAU_TEAM_ID."
  log_ok "DMG: chữ ký hợp lệ, Team $DAU_TEAM_ID"
fi
if (( developer_id )); then
  spctl --assess --type open --context context:primary-signature --verbose=2 "$dmg" \
    || log_die "spctl từ chối DMG."
  xcrun stapler validate "$dmg" >/dev/null || log_die "DMG chưa có vé notarize."
  log_ok "spctl chấp nhận DMG, vé notarize đã đính kèm"
fi
trap cleanup EXIT
detach

# --- dSYM --------------------------------------------------------------------
dsyms=$out/Dau-$file_version.dSYMs.zip
ditto -c -k --keepParent "$archive/dSYMs" "$dsyms"
log_ok "dSYM đã lưu: ${dsyms:t}"

# --- appcast -----------------------------------------------------------------
appcast=""
if (( signed )); then
  log_step "Sinh appcast (ký EdDSA)"
  gen=$(print -rl -- "$derived"/SourcePackages/artifacts/sparkle/Sparkle/bin/generate_appcast(N) | head -1)
  [[ -x $gen ]] || log_die "Không thấy generate_appcast trong $derived/SourcePackages/artifacts."
  work=$out/appcast
  mkdir -p "$work"
  cp "$base_appcast" "$work/appcast.xml"   # site/appcast.xml of origin/main, checked above
  cp "$dmg" "$work/"
  # -o: generate_appcast otherwise names the file after SUFeedURL. It keeps the items already in
  # the file (checked with an older item whose DMG was absent) and puts the new one first.
  # The private key goes in on stdin: no file, no argument (which `ps` would show), no log.
  # --channel beta tags only the new item (every release this script builds is a beta, D7); items
  # already in the file keep what they have. The stable release is made by promote-release.sh,
  # which removes the tag from the item of the last beta.
  print -rn -- "$DAU_SPARKLE_PRIVATE_KEY" | "$gen" --ed-key-file - -o "$work/appcast.xml" --channel beta \
    --download-url-prefix "$download_base/$tag/" "$work"
  command rm -f "$work/$dmg_name"
  appcast=$work/appcast.xml
  grep -q "sparkle:edSignature" "$appcast" || log_die "Appcast không có chữ ký EdDSA."
  if appcast_is_feed_signed "$appcast"; then
    log_die "Appcast mang chữ ký của chính nó (SURequireSignedFeed): promote-release.sh sửa appcast sẽ làm chữ ký đó hỏng. Cần cập nhật cách quảng bá trước (docs/Releasing.md)."
  fi
  "$DAU_ROOT/scripts/release/check-appcast.sh" --beta "$tag" --appcast "$appcast" --base "$base_appcast" || exit 1
  log_ok "Appcast có chữ ký EdDSA: ${appcast#$DAU_ROOT/}"
else
  skipped+=("ký bản cập nhật và sinh appcast")
fi

# --- release notes ------------------------------------------------------------
notes=""
if (( signed )); then
  notes=$out/release-notes.md
  # Drops the template comment and the marker lines; the part between the markers only without notarization.
  awk -v notarized=$developer_id '
    /^<!-- Template/ {comment=1}
    comment {if (/-->/) comment=0; next}
    /<!-- gatekeeper:begin -->/ {part=1; next}
    /<!-- gatekeeper:end -->/ {part=0; next}
    !(part && notarized) {print}
  ' "$DAU_ROOT/scripts/release/release-notes-template.md" > "$notes"
  log_ok "Ghi chú bản phát hành: ${notes#$DAU_ROOT/}"
fi

# --- checksums ----------------------------------------------------------------
# Same flow as the appcast: start from origin/main's file (not the one at the tagged commit, which
# can lack the previous release), add this build. The key is sparkle:version, the build number.
log_step "Ghi SHA-256 của DMG vào Checksums.json"
checksums=$out/Checksums.json
base_checksums=$(mktemp "${TMPDIR:-/tmp}/dau-checksums.XXXXXX")
checksums_from_ref origin/main > "$base_checksums"
dmg_sha256=$(checksums_sha256 "$dmg")
checksums_merge "$base_checksums" "$build_number" "$dmg_sha256" > "$checksums" \
  || log_die "Checksums.json của origin/main đã ghi SHA-256 khác cho số build $build_number."
command rm -f "$base_checksums"
[[ $(checksums_get "$checksums" "$build_number") == "$dmg_sha256" ]] || log_die "Checksums.json không khớp DMG."
log_ok "Checksums.json: build $build_number = ${dmg_sha256[1,16]}… (${dmg_name})"

# --- summary -----------------------------------------------------------------
{
  print -r -- "Dấu ${label:-${display:-dev}} (hiển thị ${display:-dev}, build $build_number), chế độ: $( (( developer_id )) && print "ký Developer ID, notarize" || { (( signed )) && print "ký Apple Development (Personal Team), không notarize" || print "không ký" } )"
  print -r -- "DMG: $dmg_name"
  print -r -- "SHA-256 của DMG: $dmg_sha256"
  print -r -- "Bố cục cửa sổ DMG: $laid_out"
  for s in $skipped; do print -r -- "Đã bỏ qua: $s"; done
} > "$out/summary.txt"
if [[ -n ${GITHUB_OUTPUT-} ]]; then
  {
    print -r -- "dmg=$dmg"; print -r -- "dsyms=$dsyms"; print -r -- "checksums=$checksums"; print -r -- "appcast=$appcast"; print -r -- "notes=$notes"
    print -r -- "display=${display:-dev}"; print -r -- "label=${label:-${display:-dev}}"; print -r -- "signed=$signed"
  } >> "$GITHUB_OUTPUT"
fi
command rm -rf "$derived"
log_step "Kết quả trong ${out#$DAU_ROOT/}"
cat "$out/summary.txt"
(( ${#skipped} )) && log_warn "Đã bỏ qua ${#skipped} bước (liệt kê ở trên)."
log_done "Phát hành xong"
