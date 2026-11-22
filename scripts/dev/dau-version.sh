#!/bin/zsh
# Which build of Dấu is installed and running, against the repo.
# Side effects: none
#
# Usage: scripts/dev/dau-version.sh
#
# Prints the commit (Resources/BuildCommit.txt, scripts/build/stamp-build-commit.sh) of the
# installed input method, of the Dấu.app in /Applications (with its signature) and of the
# Debug Dấu.app, each installed bundle's build configuration
# (Debug when signed with get-task-allow, D8), the repo's HEAD, and whether the
# running input method process started after the installed bundle was written (if not,
# switch input source away from Dấu and back, so macOS starts the new one). Also prints
# whether each installed bundle's signature still verifies (a revoked "Apple Development"
# certificate, e.g. after the same Apple ID made a new one on another Mac, shows here as
# CSSMERR_TP_CERT_REVOKED) and the Apple Development identities in the keychain, and warns
# when the Dấu.app in /Applications and the installed input method differ (D37).
# It also answers "is the day-to-day build the latest?" (the installed input method
# against ref main, the ref `install-app.sh --ref main` builds): "mới nhất" only when the build
# inputs are unchanged between the two commits (the paths that do not count: see the block
# below), the same Xcode and SDK built it, and it is a Release without "+";
# otherwise "cần cài lại" or "không rõ" with the reason and the command. Details: the block
# after the Debug line; the test-only overrides are listed there too.
# Reads only; changes nothing.
set -uo pipefail
root=${0:A:h:h:h}
source "${0:A:h:h}/lib/log.sh"
source "${0:A:h:h}/lib/bundle-config.sh"
im="$HOME/Library/Input Methods/DauInputMethod.app"
app="$root/build/DerivedData.noindex/Build/Products/Debug/Dau.app"
host="/Applications/Dau.app"

commit_of() { # bundle
  local f="$1/Contents/Resources/BuildCommit.txt"
  if [[ -f $f ]]; then print -r -- "$(<"$f")"; else print -r -- "(không có mã commit)"; fi
}

signature_of() { # bundle -> "hợp lệ, Team X" or the codesign error
  local out team
  team=$(codesign -dv "$1" 2>&1 | sed -n 's/^TeamIdentifier=//p')
  if out=$(codesign --verify --strict "$1" 2>&1); then
    print -r -- "hợp lệ, Team ${team:-?}"
  else
    out=${out%%$'\n'*}   # first line: "<path>: <reason>"
    print -r -- "KHÔNG hợp lệ, Team ${team:-?}: ${out##*: }"
  fi
}

head=$(git -C "$root" rev-parse --short=7 HEAD 2>/dev/null)
[[ -n $(git -C "$root" status --porcelain --untracked-files=no 2>/dev/null) ]] && head+="+"
print -r -- "Repo:              $head"

if [[ -d $im ]]; then
  print -r -- "Bộ gõ đã cài:      $(commit_of "$im") · $(bundle_config "$im")  (ghi lúc $(stat -f '%Sm' "$im/Contents/MacOS/DauInputMethod"))"
  print -r -- "  chữ ký:          $(signature_of "$im")"
else
  print -r -- "Bộ gõ đã cài:      chưa cài"
fi
if [[ -d $host ]]; then
  print -r -- "Dấu.app (/Applications): $(commit_of "$host") · $(bundle_config "$host")"
  print -r -- "  chữ ký:          $(signature_of "$host")"
  # The app replaces the installed input method with its own at launch (D37): differing
  # commits mean the app has not been opened since it was installed.
  if [[ -d $im && $(commit_of "$host") != $(commit_of "$im") ]]; then
    log_warn "Dấu.app ($(commit_of "$host")) khác bộ gõ đã cài ($(commit_of "$im"))"
    log_hint "mở Dấu.app một lần để nó thay bộ gõ đã cài"
  fi
fi
# Whether the installed build is the latest of main: the block below, not HEAD (a branch or
# uncommitted changes are not the day-to-day build).
[[ -d $app ]] && print -r -- "Dấu.app (Debug):   $(commit_of "$app")"

# --- Is the day-to-day build the latest? -------------------------------------------------------
# The answer to "bản dùng hằng ngày đã mới nhất chưa": the installed input method against ref
# main (the ref `install-app.sh --ref main` builds, not HEAD). "Latest" needs all three:
#   1. the build inputs are the same between the installed commit and main;
#   2. the same toolchain built it (DTXcodeBuild, DTSDKBuild in its Info.plist);
#   3. it is a Release with no "+" (no uncommitted changes) on its commit.
# Anything that cannot be read (commit not in git, no input method, no Xcode) is "cần cài lại" or
# "không rõ", never "mới nhất" (N5).
# Paths that do NOT count as build inputs (the only list, here): documentation, the website,
# CI and agent settings, any Markdown, and the test folders: none of them goes into Dấu.app.
# scripts/ is NOT excluded: the build calls scripts (stamp-build-commit.sh, check steps), so
# installing once too often is better than once too few.
# Test-only overrides (env): DAU_VERSION_MAIN_REF replaces "main", DAU_VERSION_INSTALLED_COMMIT the
# installed commit, DAU_VERSION_INSTALLED_XCODE_BUILD the installed DTXcodeBuild.
non_inputs=(':(exclude)docs' ':(exclude)site' ':(exclude).github' ':(exclude).claude'
            ':(exclude,glob)**/*.md' ':(exclude,glob)Apps/*/Tests/**' ':(exclude,glob)Packages/*/Tests/**')
reinstall_cmd="scripts/dev/install-app.sh --ref main"

latest_verdict() { # prints "ok|<reason>", "reinstall|<reason>" or "unknown|<reason>"
  local main_ref=${DAU_VERSION_MAIN_REF:-main} built plist cfg
  if [[ ! -d $im ]]; then print -r -- "reinstall|chưa cài bộ gõ"; return; fi
  built=${DAU_VERSION_INSTALLED_COMMIT:-}
  if [[ -z $built ]]; then
    [[ -f $im/Contents/Resources/BuildCommit.txt ]] || { print -r -- "unknown|bộ gõ đã cài không ghi commit (BuildCommit.txt)"; return; }
    built=$(<"$im/Contents/Resources/BuildCommit.txt")
  fi
  [[ $built == *+ ]] && { print -r -- "reinstall|bộ gõ đã cài dựng từ cây có thay đổi chưa commit ($built)"; return; }
  [[ $built =~ '^[0-9a-f]{7,40}$' ]] || { print -r -- "unknown|không đọc được commit đã cài ('$built')"; return; }
  git -C "$root" cat-file -e "$built^{commit}" 2>/dev/null \
    || { print -r -- "reinstall|commit đã cài $built không có trong repo này"; return; }
  local main_sha
  main_sha=$(git -C "$root" rev-parse --verify --quiet --short=7 "$main_ref^{commit}") \
    || { print -r -- "unknown|không thấy ref $main_ref trong repo"; return; }
  cfg=$(bundle_config "$im")
  case $cfg in
    Release) ;;
    Debug) print -r -- "reinstall|bộ gõ đã cài là bản Debug (bản dùng hằng ngày là Release)"; return ;;
    *) print -r -- "unknown|không đọc được cấu hình của bộ gõ đã cài"; return ;;
  esac
  # Toolchain: installed DTXcodeBuild / DTSDKBuild against the Xcode and SDK of this Mac.
  local i_xc i_sdk n_xc n_sdk
  plist=$im/Contents/Info.plist
  i_xc=${DAU_VERSION_INSTALLED_XCODE_BUILD:-$(/usr/libexec/PlistBuddy -c "Print :DTXcodeBuild" "$plist" 2>/dev/null)}
  i_sdk=$(/usr/libexec/PlistBuddy -c "Print :DTSDKBuild" "$plist" 2>/dev/null)
  n_xc=$(xcodebuild -version 2>/dev/null | sed -n 's/^Build version //p')
  n_sdk=$(xcrun --sdk macosx --show-sdk-build-version 2>/dev/null | head -1)
  if [[ -z $i_xc || -z $i_sdk ]]; then print -r -- "unknown|bộ gõ đã cài không ghi DTXcodeBuild hoặc DTSDKBuild"; return; fi
  if [[ -z $n_xc || -z $n_sdk ]]; then print -r -- "unknown|không đọc được Xcode hoặc SDK hiện tại (xcodebuild -version, xcrun --show-sdk-build-version)"; return; fi
  if [[ $i_xc != $n_xc || $i_sdk != $n_sdk ]]; then
    print -r -- "reinstall|bộ công cụ dựng khác: đã cài Xcode $i_xc, SDK $i_sdk; hiện tại Xcode $n_xc, SDK $n_sdk"; return
  fi
  # Build inputs between the installed commit and main.
  local changed rc
  changed=$(git -C "$root" diff --name-only "$built" "$main_ref" -- . $non_inputs 2>/dev/null); rc=$?
  (( rc == 0 )) || { print -r -- "unknown|git diff $built $main_ref lỗi"; return; }
  if [[ -n $changed ]]; then
    local n first
    n=$(print -r -- "$changed" | wc -l | tr -d ' ')
    first=$(print -r -- "$changed" | head -5 | paste -sd ',' - | sed 's/,/, /g')
    print -r -- "reinstall|$n file đầu vào build đã đổi từ $built tới $main_ref ($main_sha): $first$( (( n > 5 )) && print -r -- ', …')"; return
  fi
  if [[ ${built} == ${main_sha}* || ${main_sha} == ${built}* ]]; then
    print -r -- "ok|bộ gõ đã cài là $main_ref ($main_sha); Release, cùng Xcode $n_xc, SDK $n_sdk"
  else
    print -r -- "ok|các commit sau ${built[1,7]} tới $main_ref ($main_sha) không đổi đầu vào build; cùng Xcode $n_xc, SDK $n_sdk"
  fi
}
verdict=$(latest_verdict)
case ${verdict%%|*} in
  ok) log_ok "mới nhất: ${verdict#*|}" ;;
  reinstall) log_warn "cần cài lại: ${verdict#*|}"; log_hint "$reinstall_cmd" ;;
  *) log_warn "không rõ bản dùng hằng ngày đã mới nhất chưa: ${verdict#*|}"; log_hint "$reinstall_cmd" ;;
esac

# Apple Development identities: valid, or why not (revoked, expired).
# find-identity prints "Matching identities" then "Valid identities only": keep the first list.
ids=$(security find-identity -p codesigning 2>/dev/null | sed '/Valid identities only/q' | grep -E '^ +[0-9]+\) .*"Apple Development' | sed -E 's/^ +[0-9]+\) [0-9A-F]+ //')
if [[ -z $ids ]]; then
  print -r -- "Chứng chỉ ký:      không có \"Apple Development\" trong keychain"
else
  print -r -- "Chứng chỉ ký:"
  print -r -- "$ids" | while IFS= read -r l; do
    if [[ $l == *CSSMERR* ]]; then print -r -- "  KHÔNG dùng được: $l"; else print -r -- "  dùng được:       $l"; fi
  done
fi

pid=$(pgrep -f "Input Methods/DauInputMethod.app/Contents/MacOS/DauInputMethod" | head -1)
if [[ -z $pid ]]; then
  print -r -- "Tiến trình bộ gõ:  chưa chạy (macOS mở khi gõ phím với nguồn Dấu)"
elif [[ -d $im ]]; then
  started=$(date -j -f "%a %b %d %T %Y" "$(ps -o lstart= -p $pid | sed 's/  */ /g; s/^ //; s/ $//')" +%s 2>/dev/null)
  written=$(stat -f %m "$im/Contents/MacOS/DauInputMethod")
  if [[ -z $started ]]; then
    # Never claim an old build runs when the start time could not be parsed.
    print -r -- "Tiến trình bộ gõ:  pid $pid, không xác định bản nào (không đọc được giờ khởi động)"
  elif (( started >= written )); then
    print -r -- "Tiến trình bộ gõ:  pid $pid, chạy bản đã cài"
  else
    print -r -- "Tiến trình bộ gõ:  pid $pid, đang chạy bản CŨ"
    log_warn "Tiến trình bộ gõ đang chạy bản CŨ (khởi động trước lúc bản đã cài được ghi)"
    log_hint "chuyển nguồn đầu vào ra rồi vào lại Dấu"
  fi
fi
