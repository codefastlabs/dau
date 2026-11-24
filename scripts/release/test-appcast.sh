#!/bin/zsh
# Offline self-test of the appcast channel logic (scripts/lib/appcast.sh, check-appcast.sh --beta and --promoted) and of the Checksums.json merge (scripts/lib/checksums.sh).
# Side effects: builds (build/appcast-test, deleted when it ends; no network, no signing)
# Uses a hand-made appcast in the shape generate_appcast writes (one element per line, no final
# newline), never a real key or archive. What it covers: the beta item is found by tag (beta.1 is
# not beta.10), promotion removes only that item's channel tag and changes no other byte (with and
# without a final newline), the EdDSA signature line is untouched, and the checks accept the right
# files and refuse the wrong ones.
# Usage: scripts/release/test-appcast.sh
# Exit status: 0 every case passed; 1 at least one failed.

set -uo pipefail
source "${${(%):-%x}:A:h:h}/lib/log.sh"
source "${${(%):-%x}:A:h:h}/lib/appcast.sh"
source "${${(%):-%x}:A:h:h}/lib/checksums.sh"
DAU_ROOT=${${(%):-%x}:A:h:h:h}
check=$DAU_ROOT/scripts/release/check-appcast.sh
dir=$DAU_ROOT/build/appcast-test
trap 'command rm -rf "$dir"' EXIT
rm -rf "$dir"; mkdir -p "$dir"

fails=0
expect() { # description, expected status, command...
  local what=$1 want=$2; shift 2
  "$@" >"$dir/out" 2>&1; local got=$?
  if [[ $got == $want ]]; then log_ok "$what"; else
    log_error "$what: trạng thái $got, cần $want"; sed 's/^/    /' "$dir/out" >&2; fails=$(( fails + 1 ))
  fi
}
same() { # description, file a, file b
  if cmp -s "$2" "$3"; then log_ok "$1"; else log_error "$1: hai file khác nhau"; fails=$(( fails + 1 )); fi
}

item() { # version tag [channel]
  print -r -- "        <item>
            <title>0.1.0</title>
            <pubDate>Tue, 17 Nov 2026 10:00:00 +0700</pubDate>"
  [[ -n ${3-} ]] && print -r -- "            <sparkle:channel>$3</sparkle:channel>"
  print -r -- "            <sparkle:version>$1</sparkle:version>
            <sparkle:shortVersionString>0.1.0</sparkle:shortVersionString>
            <sparkle:minimumSystemVersion>12.0</sparkle:minimumSystemVersion>
            <enclosure url=\"https://github.com/codefastlabs/dau/releases/download/$2/Dau-${2#v}.dmg\" length=\"100\" type=\"application/octet-stream\" sparkle:edSignature=\"SIG$1==\"/>
        </item>"
}
wrap() { # items on stdin; no final newline, like generate_appcast
  local body; body=$(cat)
  print -rn -- "<?xml version=\"1.0\" standalone=\"yes\"?>
<rss xmlns:sparkle=\"http://www.andymatuschak.org/xml-namespaces/sparkle\" version=\"2.0\">
    <channel>
        <title>Dấu</title>
$body
    </channel>
</rss>"
}

# before: beta.10 (build 100) newest, beta.1 (build 10) older, both tagged beta
{ item 100 v0.1.0-beta.10 beta; item 10 v0.1.0-beta.1 beta; } | wrap > $dir/before.xml
before=$dir/before.xml

log_step "Lectura"
[[ $(appcast_item_channel $before v0.1.0-beta.1) == beta ]] && log_ok "beta.1 mang thẻ beta" || { log_error "beta.1"; fails=$((fails+1)); }
[[ $(appcast_item_channel $before v0.1.0-beta.10) == beta ]] && log_ok "beta.10 mang thẻ beta" || { log_error "beta.10"; fails=$((fails+1)); }
[[ $(appcast_item_channel $before v0.1.0-beta.2) == missing ]] && log_ok "beta.2 không có mục" || { log_error "beta.2"; fails=$((fails+1)); }
expect "số build 100 có trong appcast" 0 appcast_has_version $before 100
expect "số build 50 không có" 1 appcast_has_version $before 50

log_step "Quảng bá: bỏ thẻ của beta.1, không đụng beta.10"
appcast_untag $before v0.1.0-beta.1 > $dir/promoted.xml
[[ $(appcast_item_channel $dir/promoted.xml v0.1.0-beta.1) == "-" ]] && log_ok "beta.1 hết thẻ" || { log_error "beta.1 còn thẻ"; fails=$((fails+1)); }
[[ $(appcast_item_channel $dir/promoted.xml v0.1.0-beta.10) == beta ]] && log_ok "beta.10 giữ thẻ" || { log_error "beta.10 mất thẻ"; fails=$((fails+1)); }
tagline="            <sparkle:channel>beta</sparkle:channel>"
removed=$(( $(wc -c < $before) - $(wc -c < $dir/promoted.xml) ))   # wc pads with spaces: compare as numbers
(( removed == ${#tagline} + 1 )) \
  && log_ok "chỉ mất đúng một dòng thẻ kênh" || { log_error "mất $removed byte, cần $(( ${#tagline} + 1 ))"; fails=$((fails+1)); }
grep -q 'sparkle:edSignature="SIG10=="' $dir/promoted.xml && grep -q 'sparkle:edSignature="SIG100=="' $dir/promoted.xml \
  && log_ok "chữ ký EdDSA còn nguyên" || { log_error "chữ ký đổi"; fails=$((fails+1)); }
[[ -z $(tail -c1 $dir/promoted.xml) ]] && { log_error "file mất/được thêm dòng cuối"; fails=$((fails+1)); } || log_ok "không có dòng cuối, như bản gốc"
expect "mục đã quảng bá thì không quảng bá lại" 1 appcast_untag $dir/promoted.xml v0.1.0-beta.1
expect "tag không có mục thì từ chối" 1 appcast_untag $before v0.1.0-beta.2
# a file with a final newline stays identical too
print -r -- "$(cat $before)" > $dir/nl.xml
appcast_untag $dir/nl.xml v0.1.0-beta.1 > $dir/nl-promoted.xml
{ print -r -- "$(cat $dir/promoted.xml)"; } > $dir/nl-expected.xml
same "file có dòng cuối: kết quả khớp" $dir/nl-promoted.xml $dir/nl-expected.xml

log_step "check-appcast.sh --promoted"
expect "appcast quảng bá đúng thì đạt" 0 $check --promoted v0.1.0-beta.1 --appcast $dir/promoted.xml --before $before
expect "appcast chưa quảng bá (còn thẻ) thì lỗi" 1 $check --promoted v0.1.0-beta.1 --appcast $before --before $before
sed 's/SIG10==/SIGX==/' $dir/promoted.xml > $dir/tampered.xml
expect "đổi chữ ký hay chỗ khác ngoài thẻ thì lỗi" 1 $check --promoted v0.1.0-beta.1 --appcast $dir/tampered.xml --before $before
{ item 20 v0.1.0-beta.2; item 100 v0.1.0-beta.10 beta; item 10 v0.1.0-beta.1; } | wrap > $dir/added.xml
expect "thêm một mục khi quảng bá thì lỗi" 1 $check --promoted v0.1.0-beta.1 --appcast $dir/added.xml --before $before

log_step "check-appcast.sh --beta"
{ item 110 v0.1.0-beta.11 beta; item 100 v0.1.0-beta.10 beta; item 10 v0.1.0-beta.1 beta; } | wrap > $dir/new-ok.xml
expect "mục mới gắn beta, mục cũ giữ nguyên thì đạt" 0 $check --beta v0.1.0-beta.11 --appcast $dir/new-ok.xml --base $before
{ item 110 v0.1.0-beta.11; item 100 v0.1.0-beta.10 beta; item 10 v0.1.0-beta.1 beta; } | wrap > $dir/new-untagged.xml
expect "mục mới thiếu thẻ beta thì lỗi" 1 $check --beta v0.1.0-beta.11 --appcast $dir/new-untagged.xml --base $before
{ item 110 v0.1.0-beta.11 beta; item 100 v0.1.0-beta.10 beta; item 10 v0.1.0-beta.1; } | wrap > $dir/old-changed.xml
expect "mục cũ mất thẻ thì lỗi" 1 $check --beta v0.1.0-beta.11 --appcast $dir/old-changed.xml --base $before
{ item 110 v0.1.0-beta.11 beta; item 10 v0.1.0-beta.1 beta; } | wrap > $dir/old-lost.xml
expect "mất một mục cũ thì lỗi" 1 $check --beta v0.1.0-beta.11 --appcast $dir/old-lost.xml --base $before
{ item 100 v0.1.0-beta.11 beta; item 100 v0.1.0-beta.10 beta; item 10 v0.1.0-beta.1 beta; } | wrap > $dir/dup-build.xml
expect "số build trùng mục cũ thì lỗi" 1 $check --beta v0.1.0-beta.11 --appcast $dir/dup-build.xml --base $before
expect "mục đầu không phải của tag thì lỗi" 1 $check --beta v0.1.0-beta.1 --appcast $dir/new-ok.xml

# --- Checksums.json (scripts/lib/checksums.sh) ---
[[ $(appcast_item_version $before v0.1.0-beta.10) == 100 ]] && log_ok "sparkle:version của mục beta.10 là 100" \
  || { log_error "appcast_item_version beta.10"; fails=$(( fails + 1 )); }
expect "tag không có mục thì appcast_item_version lỗi" 1 appcast_item_version $before v9.9.9-beta.1
print -rn -- "$(head -c 2048 /dev/zero | tr '\0' 'x')" > $dir/fake.dmg
fake_sha=$(checksums_sha256 $dir/fake.dmg)
[[ $fake_sha == $(shasum -a 256 $dir/fake.dmg | cut -d' ' -f1) && $fake_sha =~ ^[0-9a-f]{64}$ ]] \
  && log_ok "SHA-256 là 64 chữ số hex thường, khớp shasum" || { log_error "checksums_sha256: $fake_sha"; fails=$(( fails + 1 )); }
print -r -- '{}' > $dir/cs-empty.json
checksums_merge $dir/cs-empty.json 1230 $fake_sha > $dir/cs-one.json
[[ $(checksums_get $dir/cs-one.json 1230) == $fake_sha ]] && log_ok "merge vào {} ghi đúng mục" || { log_error "merge vào {}"; fails=$(( fails + 1 )); }
print -r -- '{
  "990": "aaa"
}' > $dir/cs-old.json
checksums_merge $dir/cs-old.json 1230 $fake_sha > $dir/cs-two.json
{ print '{'; print "  \"990\": \"aaa\","; print "  \"1230\": \"$fake_sha\""; print '}'; } > $dir/cs-two.want
same "merge giữ mục cũ, khoá xếp theo số, thụt 2 dấu cách, có xuống dòng cuối" $dir/cs-two.json $dir/cs-two.want
checksums_merge $dir/cs-two.json 1230 $fake_sha > $dir/cs-again.json
same "merge cùng số, cùng SHA-256 thì không đổi gì" $dir/cs-two.json $dir/cs-again.json
expect "merge cùng số build, SHA-256 khác thì lỗi" 1 checksums_merge $dir/cs-two.json 1230 deadbeef
[[ $(checksums_from_ref no-such-ref) == '{}' ]] && log_ok "ref không có file thì ra {}" || { log_error "checksums_from_ref"; fails=$(( fails + 1 )); }
(( fails == 0 )) || log_die "$fails ca không đạt."
log_done "Mọi ca đạt"
