#!/bin/zsh
# Mechanical doc checks, run before every commit that touches code or docs.
# Side effects: none
#
# Usage: scripts/check-docs/check.sh
#
# Living docs = docs/*.md (except PROGRESS.md's dated log and history/research,
# which record the past), CLAUDE.md, README.md, CONTRIBUTING.md, .claude/agents, .claude/commands.
# Checks:
#   1. repo paths in backticks exist (in PROGRESS.md, not in the dated log);
#   2. no file:line references (line numbers drift; name the type or function);
#   3. every D# / N# cited exists in docs/DECISIONS.md;
#   3b. the first citation of each D# / N# in a living doc or docs/research/*.md carries its
#      name, "D4 (Từ nước ngoài)" (decision-names.py; not L10N-REVIEW.md, a temporary list
#      that numbers its own rows D1–D4);
#   4. no wording listed in superseded.txt (DECISIONS.md and the dated M*-TESTING.md plans may);
#      also in the comment lines of scripts/**/*.sh and scripts/**/*.swift (not in
#      scripts/check-docs, which holds the patterns);
#   5. UI.md, UI-CHECKS.md and ARCHITECTURE.md hold no UI measurements (pt, W×H):
#      they live in scripts/selftest/settings-window/Reference.swift and
#      docs/research/SYSTEM-SETTINGS-REFERENCE.md. Code spans in backticks are skipped.
#   6. commit hashes in living docs exist in the repo (one `git cat-file --batch-check`
#      for all of them): a 7+ hex token with at least one digit and one letter, inside
#      backticks or parentheses. PROGRESS.md's log, docs/history and docs/research are not
#      living docs, so they are not checked.
#   7. scripts: every scripts/**/*.sh (not .build) and .claude/hooks/*.sh starts with
#      "#!/bin/zsh" (one shell: /bin/bash on macOS is 3.2), passes `zsh -n` and has a
#      "# Side effects:" line; every script but the sourced files in scripts/lib has a
#      `set` line with -u and one with pipefail (scripts/README.md, "Mở đầu"); every repo
#      path in backticks in scripts/README.md exists; no script but scripts/lib/log.sh
#      writes ANSI color codes or the "==>" step mark (scripts/README.md, "Đầu ra");
#   8. hook table: every script whose "# Side effects:" line holds a disturbing effect is
#      named in .claude/hooks/guard-scripts.sh, so the hook cannot silently miss one.
# Exit status 0 only if every check passes. Output (Vietnamese, via scripts/lib/log.sh):
# one "✗" line per problem, then a final verdict line.
set -uo pipefail
here=${0:A:h}
root=${here:h:h}
cd "$root"
source "$root/scripts/lib/log.sh"
fail=0
report() { log_error "$1"; fail=1 }

living=(docs/*.md(N) CLAUDE.md README.md(N) CONTRIBUTING.md(N) .claude/agents/*.md(N) .claude/commands/*.md(N))
living=(${living:#docs/PROGRESS.md})
cited=($living docs/PROGRESS.md)

# 1. Paths.
# PROGRESS.md's dated log records the past: a path removed later stays as it was written.
for f in $cited; do
  text=$(<$f)
  [[ $f == docs/PROGRESS.md ]] && text=${text%%$'\n'\#\# Nhật ký*}
  for p in ${(f)"$(print -r -- $text | grep -oE '`(Apps|Packages|scripts|docs|\.claude)/[^` ]+`' | tr -d '`' | sort -u)"}; do
    [[ -z $p ]] && continue
    p=${p%%:*}; p=${p%/}
    [[ $p == *'*'* || $p == *'<'* || $p == *'{'* || $p == *…* ]] && continue
    [[ -e $p ]] || report "$f: đường dẫn không tồn tại: $p"
  done
done

# 2. Line numbers.
for f in $cited; do
  grep -nE '[A-Za-z]+\.(swift|plist|yml|json):[0-9]+' $f | while read -r l; do report "$f: tham chiếu số dòng (hãy nêu tên kiểu hoặc hàm): ${l[1,160]}"; done
done

# 3. Decision numbers.
known=(${(f)"$(grep -oE '^- \*\*[DN][0-9]+' docs/DECISIONS.md | grep -oE '[DN][0-9]+' | sort -u)"})
for f in $living; do
  for d in ${(f)"$(grep -oE '\b[DN][0-9]{1,2}\b' $f | sort -u)"}; do
    [[ -z $d ]] && continue
    (( ${known[(Ie)$d]} )) || report "$f: dẫn $d, không có trong DECISIONS.md"
  done
done

# 3b. Names on first citations.
named=($living docs/research/*.md(N))
named=(${named:#docs/DECISIONS.md}); named=(${named:#docs/L10N-REVIEW.md})
python3 -I scripts/check-docs/decision-names.py $named | while IFS=$'\t' read -r f d found; do
  report "$f: lần dẫn đầu của $d phải kèm tên, dạng \"$d (tên trong DECISIONS.md)\": ${found[1,80]}"
done

# 4. Superseded wording.
grep -vE '^(#|$)' $here/superseded.txt | while IFS=$'\t' read -r pattern why; do
  for f in ${${living:#docs/DECISIONS.md}:#docs/*-TESTING.md}; do
    grep -nE -- "$pattern" $f | while read -r l; do report "$f: cách nói đã bị thay ($why): ${l[1,140]}"; done
  done
done

# 4b. Superseded wording in the comments of the scripts themselves.
script_files=(scripts/**/*.sh(N) scripts/**/*.swift(N))
script_files=(${script_files:#scripts/check-docs/*})
script_files=(${script_files:#*/.build/*})
grep -vE '^(#|$)' $here/superseded.txt | while IFS=$'\t' read -r pattern why; do
  for f in $script_files; do
    grep -nE '(^|[[:space:]])(#|//)' $f | grep -E -- "$pattern" | while read -r l; do report "$f: cách nói đã bị thay ($why): ${l[1,140]}"; done
  done
done

# 5. No UI measurements outside their single home.
for f in docs/UI.md docs/UI-CHECKS.md docs/ARCHITECTURE.md; do
  sed -E 's/`[^`]*`//g' $f | grep -nE '[0-9]{2,} ?pt\b|[0-9]{2,} ?× ?[0-9]{2,}' | while read -r l; do report "$f: số đo giao diện phải nằm ở Reference.swift: ${l[1,140]}"; done
done

# 6. Commit hashes in living docs must exist.
# Hashes of other repositories: 89c2fd3 is the OpenKey commit docs/OPENKEY-NOTES.md read.
foreign_hashes=(89c2fd3)
hash_files=(); hash_tokens=()
for f in $living; do
  # Spans in backticks or parentheses only: plain words that look like hex stay out.
  for h in ${(f)"$(grep -oE '`[^`]*`|\([^)]*\)' $f | grep -oE '\b[0-9a-f]{7,40}\b' | grep '[0-9]' | grep '[a-f]' | sort -u)"}; do
    [[ -z $h ]] && continue
    (( ${foreign_hashes[(Ie)$h]} )) && continue
    hash_files+=($f); hash_tokens+=($h)
  done
done
if (( $#hash_tokens )); then
  # One git process: "<token>^{commit} missing" for each unknown or non-commit token.
  hash_out=(${(f)"$(print -rl -- ${^hash_tokens}'^{commit}' | git cat-file --batch-check 2>/dev/null)"})
  for i in {1..$#hash_tokens}; do
    [[ ${hash_out[i]-missing} == *' missing' || ${hash_out[i]-missing} == *ambiguous* ]] \
      && report "${hash_files[i]}: commit ${hash_tokens[i]} không có trong repo này (hash cũ? xem docs/history/COMMIT-MAP.md)"
  done
fi

# 7. Scripts: opening lines, Side effects line, colour codes.
for s in scripts/**/*.sh(N) .claude/hooks/*.sh(N); do
  [[ $s == */.build/* ]] && continue
  [[ "$(head -1 $s)" == '#!/bin/zsh' ]] || report "$s: dòng đầu không phải #!/bin/zsh"
  zsh -n $s 2>/dev/null || report "$s: zsh -n báo lỗi cú pháp"
  if [[ $s != scripts/lib/*.sh ]]; then
    (( $(grep -cE '^set -[a-z]*u' $s) )) || report "$s: thiếu set -u (scripts/README.md, \"Mở đầu\")"
    (( $(grep -cE '^set .*pipefail' $s) )) || report "$s: thiếu set -o pipefail (scripts/README.md, \"Mở đầu\")"
  fi
  grep -qE '^# Side effects: ' $s || report "$s: thiếu dòng \"# Side effects:\""
  [[ $s == scripts/lib/log.sh || $s == scripts/check-docs/check.sh ]] && continue
  grep -nE '\\e\[|\\033\[|\\x1[bB]|tput (setaf|bold|sgr0)|==>' $s | while IFS= read -r l; do
    report "$s:${l%%:*}: mã màu hoặc dấu \"==>\" nằm ngoài scripts/lib/log.sh"
  done
done
for p in ${(f)"$(grep -oE '`(Apps|Packages|scripts|docs|\.claude)/[^` ]+`' scripts/README.md | tr -d '`' | sort -u)"}; do
  [[ -z $p ]] && continue
  p=${p%/}
  [[ $p == *'*'* || $p == *'<'* || $p == *'{'* || $p == *…* ]] && continue
  [[ -e $p ]] || report "scripts/README.md: đường dẫn không tồn tại: $p"
done

# 8. Hook table: a script with a disturbing effect must be named in the hook.
disturbing=('takes the screen' 'kills processes' 'changes input source' 'installs input method'
            'installs app' 'deletes data' 'changes user settings' 'needs admin password')
hook=.claude/hooks/guard-scripts.sh
for s in scripts/**/*.sh(N); do
  [[ $s == */.build/* ]] && continue
  line=$(grep -m1 '^# Side effects: ' $s) || continue
  for e in $disturbing; do
    if [[ $line == *$e* ]]; then
      grep -qF -- "[$s]" $hook || report "$s: tác dụng phụ \"$e\" nhưng chưa có trong bảng của $hook"
      break
    fi
  done
done

(( fail )) && { log_error "Tài liệu lệch: sửa các chỗ trên rồi chạy lại."; exit 1 }
log_ok "Tài liệu khớp."
