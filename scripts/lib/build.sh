#!/bin/zsh
# Shared build step for the scripts that build Dấu with xcodebuild (sourced, not run).
# Side effects: builds
# Callers: scripts/dev/install-app.sh, scripts/selftest/app-group.sh.
# This file holds what must be identical everywhere:
#
#   dau_signing_identities        the usable "Apple Development" identities, one
#                                 find-identity line each ("N) <SHA-1> "<name>"")
#   dau_team_signing_identity T   SHA-1 of the usable "Apple Development" identity of Team T, matched on the
#                                 certificate's Organizational Unit; status 1 when there is none
#   dau_require_signing_identity  stop early when the keychain has no usable
#                                 "Apple Development" identity (revoked, expired, missing)
#   dau_marketing_version         X.Y.Z of the nearest vX.Y.Z[-beta.N] tag on HEAD; empty with no tag
#   dau_build SCHEME CONFIG       xcodegen, then xcodebuild universal into $DAU_DERIVED, with
#                                 MARKETING_VERSION from dau_marketing_version when there is one
#   dau_check_input_method BUNDLE CONFIG
#                                 the checks of an input method bundle (the one inside a
#                                 built Dau.app): universal (D1), valid signature, no
#                                 network entitlement (N2), and for Release no
#                                 get-task-allow. Status 1 with the reason when one fails.
#
# It never passes -allowProvisioningUpdates: that flag can create a new certificate and
# revoke the one of another Mac on the same Apple ID (docs/history/LogM5.md), so it is
# the user's action, printed below, never a script's.

# %x is the file being sourced; :A resolves it, each :h drops one path component.
DAU_ROOT="${${(%):-%x}:A:h:h:h}"
DAU_DERIVED="$DAU_ROOT/build/DerivedData.noindex"
source "$DAU_ROOT/scripts/lib/log.sh"

dau_signing_identities() {
  # find-identity -v still lists a revoked identity, tagged CSSMERR_TP_CERT_REVOKED, and
  # a new certificate keeps the revoked one's name: drop CSSMERR lines, never pick by
  # name alone.
  security find-identity -v -p codesigning 2>/dev/null \
    | grep '"Apple Development' | grep -v CSSMERR
}

dau_require_signing_identity() {
  dau_signing_identities >/dev/null && return 0
  log_error "Không có chứng chỉ \"Apple Development\" dùng được trong keychain (thiếu, hết hạn hoặc bị thu hồi)."
  log_hint "scripts/dev/dau-version.sh cho biết lý do. Chọn một trong hai cách (docs/Troubleshooting.md, \"Chữ ký bị thu hồi khi dùng một Apple ID trên hai máy Mac\"):" \
    "a) Máy Mac khác dùng cùng Apple ID đang có chứng chỉ hợp lệ: xuất nó kèm khoá riêng ra" \
    "   .p12 ở máy đó (Keychain Access › login › My Certificates › Export), nhập ở máy này." \
    "b) Tạo chứng chỉ mới cho máy này. Chứng chỉ của máy Mac kia có thể bị thu hồi. Tự chạy:" \
    "   xcodegen generate && \\" \
    "     xcodebuild -project Dau.xcodeproj -scheme Dau -configuration Release \\" \
    "     -destination 'generic/platform=macOS' -derivedDataPath build/DerivedData.noindex \\" \
    "     -allowProvisioningUpdates build"
  return 1
}

dau_team_signing_identity() {
  local team="$1" valid line hash="" pem="" subject matches=()
  valid=$(dau_signing_identities | awk '{print $2}')
  [[ -n $valid ]] || return 1
  # The parentheses in an "Apple Development" name are the certificate's user ID, not the
  # Team ID: the team is the Organizational Unit of the certificate subject.
  while IFS= read -r line; do
    case $line in
      "SHA-1 hash: "*) hash=${line#SHA-1 hash: } ;;
      "-----BEGIN CERTIFICATE-----") pem="$line"$'\n' ;;
      "-----END CERTIFICATE-----")
        pem+="$line"
        subject=$(print -r -- "$pem" | /usr/bin/openssl x509 -noout -subject -nameopt multiline 2>/dev/null)
        if [[ $subject == *"organizationalUnitName"*"= $team"$'\n'* && -n ${(M)${(f)valid}:#$hash} ]]; then
          matches+=$hash
        fi
        pem="" ;;
      *) [[ -z $pem ]] || pem+="$line"$'\n' ;;
    esac
  done < <(security find-certificate -a -Z -c "Apple Development" -p 2>/dev/null)
  (( ${#matches} )) || return 1
  print -r -- $matches[1]
}

dau_marketing_version() { # X.Y.Z of the nearest vX.Y.Z[-beta.N] tag reachable from HEAD; empty with no tag
  local t
  t=$(git -C "$DAU_ROOT" describe --tags --match 'v[0-9]*' --abbrev=0 2>/dev/null) || return 0
  t=${${t#v}%%-*}
  [[ $t == <->.<->.<-> ]] && print -r -- $t
  return 0
}

dau_build() {
  local scheme="$1" config="$2" version version_args=()
  # The development build shows the version of the nearest release tag on HEAD (D7: every
  # beta and its stable show the same X.Y.Z); with no tag, the number in project.yml.
  # A build from Xcode itself does not go through here and keeps project.yml.
  version=$(dau_marketing_version)
  [[ -z $version ]] || version_args=(MARKETING_VERSION=$version)
  if ! command -v xcodegen >/dev/null 2>&1; then
    log_error "Cần XcodeGen: brew install xcodegen"
    return 1
  fi
  dau_require_signing_identity || return 1
  log_step "Sinh Dau.xcodeproj"
  (cd "$DAU_ROOT" && xcodegen generate --quiet) || return 1
  log_step "Build $config universal (scheme $scheme)${version:+, số hiển thị $version}"
  xcodebuild \
    -project "$DAU_ROOT/Dau.xcodeproj" \
    -scheme "$scheme" \
    -configuration "$config" \
    -destination 'generic/platform=macOS' \
    -derivedDataPath "$DAU_DERIVED" \
    -quiet \
    $version_args \
    build
}

dau_check_input_method() {
  local bundle="$1" config="$2" binary archs entitlements
  binary="$bundle/Contents/MacOS/${bundle:t:r}"
  if [[ ! -f "$binary" ]]; then
    log_error "Không thấy bộ gõ ở $bundle."
    return 1
  fi
  archs="$(lipo -archs "$binary" 2>/dev/null)"
  log_detail "kiến trúc bộ gõ: ${archs:-không đọc được}"
  if [[ "$archs" != *arm64* || "$archs" != *x86_64* ]]; then
    log_error "Bộ gõ không phải universal (D1)."
    return 1
  fi
  if ! codesign --verify --strict "$bundle" 2>/dev/null; then
    log_error "Chữ ký của bộ gõ ($bundle) không hợp lệ."
    return 1
  fi
  # Matched in the shell, not with `| grep -q`: under pipefail a grep that quits at the first
  # match can fail the pipeline through SIGPIPE on codesign, and the check would pass.
  # The input method is sandboxed (D37), so an empty answer means the entitlements were
  # not read, never "no network entitlement".
  entitlements="$(codesign -d --entitlements - --xml "$bundle" 2>/dev/null)" || entitlements=""
  if [[ "$entitlements" != *com.apple.security.app-sandbox* ]]; then
    log_error "Không đọc được entitlements của bộ gõ (không thấy App Sandbox): chưa kiểm được N2."
    return 1
  fi
  if [[ "$entitlements" == *com.apple.security.network* ]]; then
    log_error "Bộ gõ có quyền mạng, trái N2."
    return 1
  fi
  if [[ "$config" == Release && "$entitlements" == *get-task-allow* ]]; then
    log_error "Bộ gõ bản Release còn get-task-allow (cho phép gắn debugger)."
    return 1
  fi
  if [[ "$config" == Release ]]; then
    log_ok "Bộ gõ: universal (D1), chữ ký hợp lệ, không có quyền mạng (N2), không có get-task-allow"
  else
    log_ok "Bộ gõ: universal (D1), chữ ký hợp lệ, không có quyền mạng (N2)"
  fi
}
