#!/bin/zsh
# Builds throw-away variants "DauProbe<round><N>" of the Release DauInputMethod.app under build/probe.noindex/<round>/.
# Side effects: builds
# Probe tooling for docs/research/M5-INSTALL.md section 8.2 (not part of any release). It never
# copies anything to ~/Library/Input Methods or /Library/Input Methods: scripts/probe/step.sh does
# that, right before each step.
#
# Usage:
#   scripts/probe/make-variants.sh <round> [N...]   e.g. `A` makes DauProbeA1..DauProbeA8; `A 2 5` only A2, A5
#
# Each variant renames the .app, CFBundleExecutable and the executable file, CFBundleIdentifier and
# TISInputSourceID (com.codefastlabs.dau.inputmethod.DauProbe<round><N>), the input mode key and its
# TISInputSourceID (….vi, also in tsVisibleInputModeOrderedArrayKey), InputMethodConnectionName, the
# keys and display names in Resources/*.lproj/InfoPlist.strings ("Dấu thử <round><N>") and the
# mach-register entitlement; every other entitlement stays. It is signed again with the Apple
# Development identity of the original build (hardened runtime if the original has it).
#
# Every ID made is appended to build/probe.noindex/used-ids.txt; an ID listed there, or one of the
# IDs used on 03/11/2026 (…inputmethod.Probe…, com.codefastlabs.dau.probe.…), is refused.
set -u
setopt null_glob

ROOT="${0:A:h:h:h}"
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
SRC="$ROOT/build/DerivedData.noindex/Build/Products/Release/DauInputMethod.app"
OUT_ROOT="$ROOT/build/probe.noindex"
USED="$OUT_ROOT/used-ids.txt"
PREFIX="com.codefastlabs.dau.inputmethod"

case "${1:-}" in
  ""|-h|--help) awk 'NR==1{next} /^#/{sub(/^# ?/,""); print; next} {exit}' "$0"; exit 0 ;;
esac
ROUND="$1"; shift
if [[ ! $ROUND =~ '^[A-Za-z0-9]+$' ]]; then print -u2 "Vòng phải là chữ/số, ví dụ A: $ROUND"; exit 2; fi
NS=("$@"); (( ${#NS} )) || NS=(1 2 3 4 5 6 7 8)
for n in $NS; do [[ $n =~ '^[0-9]+$' ]] || { print -u2 "N phải là số: $n"; exit 2 }; done

mkdir -p "$OUT_ROOT"; touch "$USED"

if [[ ! -d $SRC ]]; then
  print "==> Chưa có bản Release: build"
  "$ROOT/scripts/dev/install-input-method.sh" --build-only --release || exit 1
fi
[[ -d $SRC ]] || { print -u2 "Không thấy $SRC"; exit 1 }

# Signing identity of the original build: the leaf certificate it was signed with.
IDENT_NAME=$(codesign -dvv "$SRC" 2>&1 | sed -n 's/^Authority=\(Apple Development: .*\)$/\1/p' | head -1)
[[ -n $IDENT_NAME ]] || { print -u2 "Bản gốc không ký bằng danh tính Apple Development."; exit 1 }
source "$ROOT/scripts/lib/build.sh"   # dau_signing_identities: skips revoked identities
IDENT_HASH=$(dau_signing_identities | grep -F "\"$IDENT_NAME\"" | awk '{print $2}' | head -1)
[[ -n $IDENT_HASH ]] || { print -u2 "Không thấy danh tính dùng được trong keychain: $IDENT_NAME"; exit 1 }
RUNTIME=()
codesign -dvv "$SRC" 2>&1 | grep -q 'flags=.*runtime' && RUNTIME=(--options runtime)
print "Danh tính ký: $IDENT_NAME ($IDENT_HASH) ${RUNTIME}"

ORIG_ENT=$(mktemp -t probe-ent).plist
codesign -d --entitlements - --xml "$SRC" > "$ORIG_ENT" 2>/dev/null
plutil -lint "$ORIG_ENT" >/dev/null || { print -u2 "Không đọc được entitlement bản gốc."; exit 1 }

failed=0
for n in $NS; do
  NAME="DauProbe$ROUND$n"
  ID="$PREFIX.$NAME"
  DISPLAY="Dấu thử $ROUND$n"
  if [[ $ID == $PREFIX.Probe* || $ID == com.codefastlabs.dau.probe.* ]]; then
    print -u2 "TỪ CHỐI $ID: trùng dạng ID đã dùng 03/11."; failed=1; continue
  fi
  if grep -qxF "$ID" "$USED"; then
    print -u2 "TỪ CHỐI $ID: đã có trong $USED (mỗi ID chỉ mới một lần cho mỗi tài khoản)."; failed=1; continue
  fi
  DEST="$OUT_ROOT/$ROUND/$NAME.app"
  print "==> $NAME"
  rm -rf "$DEST"; mkdir -p "$OUT_ROOT/$ROUND"
  ditto "$SRC" "$DEST" || { failed=1; continue }
  rm -rf "$DEST/Contents/_CodeSignature"
  mv "$DEST/Contents/MacOS/DauInputMethod" "$DEST/Contents/MacOS/$NAME"

  ENT=$(mktemp -t probe-ent).plist
  /usr/bin/python3 -I - "$DEST" "$ID" "$NAME" "$DISPLAY" "$ORIG_ENT" "$ENT" <<'PY' || { failed=1; continue }
import plistlib, sys, glob, os
dest, ident, name, display, ent_in, ent_out = sys.argv[1:7]
OLD = "com.codefastlabs.dau.inputmethod.Dau"

info_path = dest + "/Contents/Info.plist"
with open(info_path, "rb") as f:
    info = plistlib.load(f)
old_mode = OLD + ".vi"
new_mode = ident + ".vi"
info["CFBundleExecutable"] = name
info["CFBundleIdentifier"] = ident
info["CFBundleName"] = name          # unlocalized name equals the file name (see Apps/DauInputMethod/Info.plist)
info["CFBundleDisplayName"] = name
info["TISInputSourceID"] = ident
info["InputMethodConnectionName"] = ident + "_Connection"
modes = info["ComponentInputModeDict"]
lst = modes["tsInputModeListKey"]
entry = lst.pop(old_mode)
entry["TISInputSourceID"] = new_mode
lst[new_mode] = entry
modes["tsVisibleInputModeOrderedArrayKey"] = [new_mode]
with open(info_path, "wb") as f:
    plistlib.dump(info, f, fmt=plistlib.FMT_XML)

# Compiled .strings are UTF-16 XML property lists.
for path in glob.glob(dest + "/Contents/Resources/*.lproj/InfoPlist.strings"):
    with open(path, "rb") as f:
        raw = f.read()
    text = raw.decode("utf-16")
    data = plistlib.loads(text.replace('encoding="UTF-16"', 'encoding="UTF-8"').encode("utf-8"))
    new = {}
    for k, v in data.items():
        if k == OLD + ".vi":
            new[new_mode] = display
        elif k in ("CFBundleName", "CFBundleDisplayName"):
            new[k] = display
        else:
            new[k] = v
    xml = plistlib.dumps(new, fmt=plistlib.FMT_XML).decode("utf-8").replace('encoding="UTF-8"', 'encoding="UTF-16"')
    with open(path, "wb") as f:
        f.write(xml.encode("utf-16"))   # BOM + native (little-endian) order, as the original

with open(ent_in, "rb") as f:
    ent = plistlib.load(f)
key = "com.apple.security.temporary-exception.mach-register.global-name"
ent[key] = ident + "_Connection"
with open(ent_out, "wb") as f:
    plistlib.dump(ent, f, fmt=plistlib.FMT_XML)
PY
  codesign --force --sign "$IDENT_HASH" $RUNTIME --timestamp=none --entitlements "$ENT" "$DEST" || { failed=1; continue }
  rm -f "$ENT"

  # --- checks ---
  ok=1
  plutil -lint "$DEST/Contents/Info.plist" "$DEST"/Contents/Resources/*.lproj/InfoPlist.strings "$DEST"/Contents/Resources/*.lproj/Localizable.strings >/dev/null || { print -u2 "  plutil -lint lỗi"; ok=0 }
  codesign --verify --deep --strict "$DEST" 2>&1 || { print -u2 "  codesign --verify lỗi"; ok=0 }
  ents=$(codesign -d --entitlements - --xml "$DEST" 2>/dev/null)
  print -r -- "$ents" | grep -q "${ID}_Connection" || { print -u2 "  entitlement thiếu ${ID}_Connection"; ok=0 }
  # Old strings must be gone from Info.plist, .strings and the entitlement (UTF-16 files: convert first).
  leftover=$( { plutil -p "$DEST/Contents/Info.plist"; for s in "$DEST"/Contents/Resources/*.lproj/InfoPlist.strings; do plutil -p "$s"; done; print -r -- "$ents"; } | grep -E 'inputmethod\.Dau\.vi|inputmethod\.Dau_Connection|inputmethod\.Dau"' )
  [[ -z $leftover ]] || { print -u2 "  còn chuỗi ID của Dấu:\n$leftover"; ok=0 }
  [[ -x "$DEST/Contents/MacOS/$NAME" ]] || { print -u2 "  thiếu file thực thi"; ok=0 }
  if (( ok )); then
    print "$ID" >> "$USED"
    print "  OK: $DEST"
    print "      mode: $ID.vi, tên hiển thị: $DISPLAY"
  else
    failed=1
  fi
done
rm -f "$ORIG_ENT"
exit $failed
