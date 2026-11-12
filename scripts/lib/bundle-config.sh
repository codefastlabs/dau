#!/bin/zsh
# Build configuration of an installed bundle (sourced, not run).
# Side effects: none
#
#   bundle_config BUNDLE
#       Prints Debug when the bundle is signed with get-task-allow (only Debug builds are,
#       D8), Release when it has a readable signature without it, and "cấu hình không rõ"
#       when codesign cannot read the signature. Reads only.
bundle_config() {
  local ents
  if ! ents=$(codesign -d --entitlements - --xml "$1" 2>/dev/null); then
    print -r -- "cấu hình không rõ"
  elif [[ ${ents//[[:space:]]/} == *'<key>com.apple.security.get-task-allow</key><true/>'* ]]; then
    print -r -- Debug
  else
    print -r -- Release
  fi
}
