#!/bin/zsh
# Builds tis-probe, tis-act and TisAct.app into build/probe.noindex/.
# Side effects: builds
# Output: build/probe.noindex/bin/tis-probe, bin/tis-act, and TisAct.app (a minimal, non-sandboxed
# app named "Dấu thử" around tis-act, signed with the same Apple Development identity as the
# variants). Running tis-act has side effects; this script only compiles, signs and verifies.
set -u
ROOT="${0:A:h:h:h}"
HERE="${0:A:h}"
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
OUT="$ROOT/build/probe.noindex"
BIN="$OUT/bin"
APP="$OUT/TisAct.app"
mkdir -p "$BIN"

case "${1:-}" in -h|--help) awk 'NR==1{next} /^#/{sub(/^# ?/,""); print; next} {exit}' "$0"; exit 0 ;; esac

build() { # name
  if [[ ! -x $BIN/$1 || $HERE/$1.swift -nt $BIN/$1 ]]; then
    xcrun swiftc -O -o "$BIN/$1" "$HERE/$1.swift" || { print -u2 "Không biên dịch được $1"; exit 1 }
  fi
}
build tis-probe
build tis-act

IDENT_HASH=$(security find-identity -v -p codesigning | grep -F "Apple Development:" | awk '{print $2}' | head -1)
[[ -n $IDENT_HASH ]] || { print -u2 "Không có danh tính Apple Development trong keychain."; exit 1 }

if [[ ! -d $APP || $BIN/tis-act -nt $APP/Contents/MacOS/TisAct ]]; then
  rm -rf "$APP"; mkdir -p "$APP/Contents/MacOS"
  cp "$BIN/tis-act" "$APP/Contents/MacOS/TisAct"
  cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleExecutable</key>
	<string>TisAct</string>
	<key>CFBundleIdentifier</key>
	<string>com.codefastlabs.dauprobetool.tisact</string>
	<key>CFBundleName</key>
	<string>Dấu thử</string>
	<key>CFBundleDisplayName</key>
	<string>Dấu thử</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>LSUIElement</key>
	<true/>
</dict>
</plist>
PLIST
  codesign --force --sign "$IDENT_HASH" --options runtime --timestamp=none "$APP" || exit 1
fi
plutil -lint "$APP/Contents/Info.plist" >/dev/null || exit 1
codesign --verify --deep --strict "$APP" || exit 1
print "OK: $BIN/tis-probe $BIN/tis-act $APP"
