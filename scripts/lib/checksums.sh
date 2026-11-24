#!/bin/zsh
# Reading and merging site/src/data/Checksums.json, the SHA-256 of each published DMG (sourced, not run).
# Side effects: none
# Callers: scripts/release/build-release.sh, promote-release.sh, test-appcast.sh.
# The file maps sparkle:version (the build number of an appcast item) to the lowercase hex SHA-256
# of that item's DMG. It travels like appcast.xml: the release scripts start from origin/main's
# copy and attach the result to the draft release as the asset Checksums.json; the publish step
# copies it to site/src/data/Checksums.json (docs/Releasing.md). Needs jq (macOS ships it).
#
#   checksums_sha256 FILE            SHA-256 of FILE, lowercase hex (stdout)
#   checksums_from_ref REF           site/src/data/Checksums.json at git ref REF, "{}" when the ref
#                                    or the file does not exist (stdout)
#   checksums_get FILE VERSION       the SHA-256 recorded for VERSION, empty when none (stdout)
#   checksums_merge FILE VERSION SHA FILE with VERSION set to SHA, keys in numeric order, 2-space
#                                    indent, final newline (stdout). Status 1 when VERSION already
#                                    holds a different SHA: two builds with one number are one to Sparkle.

checksums_sha256() { # file
  shasum -a 256 "$1" | awk '{print $1}'
}

checksums_from_ref() { # ref
  local json
  if json=$(git -C "$DAU_ROOT" show "${1}:site/src/data/Checksums.json" 2>/dev/null) \
      && print -r -- "$json" | jq -e 'type == "object"' >/dev/null 2>&1; then
    print -r -- "$json"
  else
    print -r -- '{}'
  fi
}

checksums_get() { # file version
  jq -r --arg v "$2" '.[$v] // empty' "$1"
}

checksums_merge() { # file version sha
  local current
  current=$(checksums_get "$1" "$2")
  if [[ -n $current && $current != $3 ]]; then
    return 1
  fi
  jq --arg v "$2" --arg s "$3" '. + {($v): $s} | to_entries | sort_by(.key | tonumber) | from_entries' "$1"
}
