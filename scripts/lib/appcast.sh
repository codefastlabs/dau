#!/bin/zsh
# Reading and editing the Sparkle appcast with awk (sourced, not run).
# Side effects: none
# Callers: scripts/release/build-release.sh, promote-release.sh, check-appcast.sh, test-appcast.sh.
# An item is found by its enclosure URL, which holds the tag (…/releases/download/<tag>/…).
# generate_appcast writes one element per line, which these functions rely on.
#
#   appcast_summary FILE         one line per item, newest first: "<sparkle:version>|<channel or ->|<enclosure URL>"
#   appcast_item_channel FILE TAG   "beta" (or another channel name), "-" (no channel tag: stable) or
#                                "missing" (no item for TAG)
#   appcast_has_version FILE N   status 0 when some item has sparkle:version N
#   appcast_is_feed_signed FILE  status 0 when the appcast carries its own signature block
#                                (Sparkle's SURequireSignedFeed): editing it would break that signature
#   appcast_untag FILE TAG       FILE with the beta channel tag removed from the item of TAG only,
#                                everything else byte-identical (stdout). Status 1 when TAG has no
#                                item or it carries no beta tag.
# The EdDSA signature of an update is sparkle:edSignature on the item's <enclosure>: it covers the
# archive (DMG), not the item's other elements, so a channel tag can change without re-signing.

appcast_summary() { # file
  awk '
    /<item>/ { inItem = 1; ver = ""; ch = "-"; url = "" }
    inItem && /<sparkle:version>/ { s = $0; sub(/.*<sparkle:version>/, "", s); sub(/<\/sparkle:version>.*/, "", s); ver = s }
    inItem && /<sparkle:channel>/ { s = $0; sub(/.*<sparkle:channel>/, "", s); sub(/<\/sparkle:channel>.*/, "", s); ch = s }
    inItem && /<enclosure / { s = $0; sub(/.*url="/, "", s); sub(/".*/, "", s); url = s }
    /<\/item>/ { if (inItem) print ver "|" ch "|" url; inItem = 0 }
  ' "$1"
}

appcast_item_channel() { # file tag
  local line
  for line in ${(f)"$(appcast_summary "$1")"}; do
    if [[ ${line#*|*|} == *"/releases/download/$2/"* ]]; then
      local rest=${line#*|}
      print -r -- "${rest%%|*}"
      return 0
    fi
  done
  print missing
}

appcast_has_version() { # file number
  local line
  for line in ${(f)"$(appcast_summary "$1")"}; do
    [[ ${line%%|*} == $2 ]] && return 0
  done
  return 1
}

appcast_is_feed_signed() { # file
  grep -q 'sparkle-signatures' "$1"
}

appcast_untag() { # file tag
  [[ $(appcast_item_channel "$1" "$2") == beta ]] || return 1
  local result
  result=$(awk -v url="/releases/download/$2/" '
    /<item>/ { inItem = 1; n = 0; hit = 0 }
    inItem {
      buf[++n] = $0
      if (index($0, url)) hit = 1
      if ($0 ~ /<\/item>/) {
        for (i = 1; i <= n; i++) {
          if (hit && buf[i] ~ /^[ \t]*<sparkle:channel>beta<\/sparkle:channel>[ \t]*$/) continue
          print buf[i]
        }
        inItem = 0
      }
      next
    }
    { print }
  ' "$1")
  # Command substitution drops the trailing newlines: put back what the file had (awk always ends
  # with one), so a file without a final newline (generate_appcast writes none) stays identical.
  if [[ -z $(tail -c1 "$1") ]]; then print -r -- "$result"; else print -rn -- "$result"; fi
}
