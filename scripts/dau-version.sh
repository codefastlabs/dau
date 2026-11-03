#!/bin/zsh
# Which build of Dấu is installed and running, against the repo.
#
# Usage: scripts/dau-version.sh
#
# Prints the commit (Resources/BuildCommit.txt, scripts/stamp-build-commit.sh) of the
# installed input method and of the Debug Dấu.app, the repo's HEAD, and whether the
# running input method process started after the installed bundle was written (if not,
# switch input source away from Dấu and back, so macOS starts the new one).
# Reads only; changes nothing.
set -u
root=${0:A:h:h}
im="$HOME/Library/Input Methods/DauInputMethod.app"
app="$root/build/DerivedData.noindex/Build/Products/Debug/Dau.app"

commit_of() { # bundle
  local f="$1/Contents/Resources/BuildCommit.txt"
  if [[ -f $f ]]; then print -r -- "$(<"$f")"; else print -r -- "(không có mã commit)"; fi
}

head=$(git -C "$root" rev-parse --short=7 HEAD 2>/dev/null)
[[ -n $(git -C "$root" status --porcelain --untracked-files=no 2>/dev/null) ]] && head+="+"
print -r -- "Repo:              $head"

if [[ -d $im ]]; then
  print -r -- "Bộ gõ đã cài:      $(commit_of "$im")  (ghi lúc $(stat -f '%Sm' "$im/Contents/MacOS/DauInputMethod"))"
else
  print -r -- "Bộ gõ đã cài:      chưa cài"
fi
[[ -d $app ]] && print -r -- "Dấu.app (Debug):   $(commit_of "$app")"

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
    print -r -- "Tiến trình bộ gõ:  pid $pid, đang chạy bản CŨ — chuyển nguồn nhập liệu ra rồi vào lại Dấu"
  fi
fi
