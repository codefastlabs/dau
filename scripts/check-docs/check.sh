#!/bin/zsh
# Mechanical doc checks, run before every commit that touches code or docs.
# Side effects: none
#
# Usage: scripts/check-docs/check.sh
#
# Living docs = docs/*.md (except PROGRESS.md's dated log and history/research,
# which record the past), CLAUDE.md, README.md, CONTRIBUTING.md, .claude/agents, .claude/commands.
# Checks:
#   1. repo paths in backticks exist;
#   2. no file:line references (line numbers drift; name the type or function);
#   3. every D# / N# cited exists in docs/DECISIONS.md;
#   4. no wording listed in superseded.txt (DECISIONS.md and the dated M*-TESTING.md plans may);
#      also in the comment lines of scripts/**/*.sh and scripts/**/*.swift (not in
#      scripts/check-docs, which holds the patterns);
#   5. PROGRESS.md "Trạng thái hiện tại" holds no test counts;
#   6. UI.md, UI-CHECKS.md and ARCHITECTURE.md hold no UI measurements (pt, W×H):
#      they live in scripts/selftest/settings-window/Reference.swift and
#      docs/research/SYSTEM-SETTINGS-REFERENCE.md. Code spans in backticks are skipped.
#   7. commit hashes in living docs exist in the repo (`git cat-file`): a 7+ hex token with
#      at least one digit and one letter, inside backticks or parentheses. PROGRESS.md's
#      log, docs/history and docs/research are not living docs, so they are not checked.
#   8. research notes: every docs/research/*.md except SYSTEM-SETTINGS-REFERENCE.md (a
#      measured reference, not a research note) has a "## … Hiện trạng" heading within
#      its first 40 lines and no "Đính chính" heading (corrections are edited into the
#      text, not appended);
#   9. scripts list: every scripts/**/*.sh (not .build) starts with "#!/bin/zsh" (one
#      shell: /bin/bash on macOS is 3.2), passes `zsh -n`, has a "# Side effects:" line and
#      is named, by path in backticks, in scripts/README.md; every script but the sourced
#      files in scripts/lib has a `set` line with -u and one with pipefail (scripts/README.md,
#      "Mở đầu"); every repo path in backticks in scripts/README.md exists; no script but
#      scripts/lib/log.sh writes ANSI color codes or the "==>" step mark (scripts/README.md,
#      "Đầu ra").
#  10. no dd/mm/yyyy date in the comment lines of scripts/**/*.sh and scripts/**/*.swift
#      (not scripts/check-docs, scripts/research, scripts/snapshot-settings): a comment keeps
#      the reason; the dated measurement or story lives in docs/PROGRESS.md or docs/history.
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
for f in $cited; do
  for p in ${(f)"$(grep -oE '`(Apps|Packages|scripts|docs|\.claude)/[^` ]+`' $f | tr -d '`' | sort -u)"}; do
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

# 5. Status section without test counts.
awk '/^## Trạng thái hiện tại/{on=1; next} /^## /{on=0} on' docs/PROGRESS.md \
  | grep -nE '[0-9]+ test|test[^.]*[0-9]{2}' | while read -r l; do report "docs/PROGRESS.md, mục trạng thái: có số test: ${l[1,120]}"; done

# 6. No UI measurements outside their single home.
for f in docs/UI.md docs/UI-CHECKS.md docs/ARCHITECTURE.md; do
  sed -E 's/`[^`]*`//g' $f | grep -nE '[0-9]{2,} ?pt\b|[0-9]{2,} ?× ?[0-9]{2,}' | while read -r l; do report "$f: số đo giao diện phải nằm ở Reference.swift: ${l[1,140]}"; done
done

# 7. Commit hashes in living docs must exist.
# Hashes of other repositories: 89c2fd3 is the OpenKey commit docs/OPENKEY-NOTES.md read.
foreign_hashes=(89c2fd3)
for f in $living; do
  # Spans in backticks or parentheses only: plain words that look like hex stay out.
  for h in ${(f)"$(grep -oE '`[^`]*`|\([^)]*\)' $f | grep -oE '\b[0-9a-f]{7,40}\b' | grep '[0-9]' | grep '[a-f]' | sort -u)"}; do
    [[ -z $h ]] && continue
    (( ${foreign_hashes[(Ie)$h]} )) && continue
    git cat-file -e "${h}^{commit}" 2>/dev/null || report "$f: commit $h không có trong repo này (hash cũ? xem docs/history/COMMIT-MAP.md)"
  done
done

# 8. Research notes: a "Hiện trạng" heading up front, no appended "Đính chính".
for f in docs/research/*.md(N); do
  [[ $f == docs/research/SYSTEM-SETTINGS-REFERENCE.md ]] && continue
  (( $(head -40 $f | grep -cE '^## .*Hiện trạng') )) || report "$f: thiếu tiêu đề \"## … Hiện trạng\" trong 40 dòng đầu"
  grep -nE '^#+ .*Đính chính' $f | while read -r l; do report "$f: có tiêu đề đính chính (hãy sửa thẳng vào thân bài): ${l[1,120]}"; done
done

# 9. Scripts list: Side effects line, and listed in scripts/README.md.
readme=scripts/README.md
if [[ ! -f $readme ]]; then
  report "thiếu $readme"
else
  for s in scripts/**/*.sh(N); do
    [[ $s == */.build/* ]] && continue
    [[ "$(head -1 $s)" == '#!/bin/zsh' ]] || report "$s: dòng đầu không phải #!/bin/zsh"
    zsh -n $s 2>/dev/null || report "$s: zsh -n báo lỗi cú pháp"
    if [[ $s != scripts/lib/*.sh ]]; then
      (( $(grep -cE '^set -[a-z]*u' $s) )) || report "$s: thiếu set -u (scripts/README.md, \"Mở đầu\")"
      (( $(grep -cE '^set .*pipefail' $s) )) || report "$s: thiếu set -o pipefail (scripts/README.md, \"Mở đầu\")"
    fi
    grep -qE '^# Side effects: ' $s || report "$s: thiếu dòng \"# Side effects:\""
    grep -qF -- "\`$s\`" $readme || report "$s: chưa có trong $readme"
  done
  for s in scripts/**/*.sh(N) .claude/hooks/*.sh(N); do
    [[ $s == */.build/* || $s == scripts/lib/log.sh || $s == scripts/check-docs/check.sh ]] && continue
    grep -nE '\\e\[|\\033\[|\\x1[bB]|tput (setaf|bold|sgr0)|==>' $s | while IFS= read -r l; do
      report "$s:${l%%:*}: mã màu hoặc dấu \"==>\" nằm ngoài scripts/lib/log.sh"
    done
  done
  for p in ${(f)"$(grep -oE '`(Apps|Packages|scripts|docs|\.claude)/[^` ]+`' $readme | tr -d '`' | sort -u)"}; do
    [[ -z $p ]] && continue
    p=${p%/}
    [[ $p == *'*'* || $p == *'<'* || $p == *'{'* || $p == *…* ]] && continue
    [[ -e $p ]] || report "$readme: đường dẫn không tồn tại: $p"
  done
fi

# 10. No dates in script comments: the reason stays, the dated story goes to the docs.
dated_files=(${script_files:#scripts/research/*})
dated_files=(${dated_files:#scripts/snapshot-settings/*})
for f in $dated_files; do
  grep -nE '(^|[[:space:]])(#|//|-- )' $f | grep -E '\b[0-3]?[0-9]/[01]?[0-9]/[0-9]{4}\b' | while IFS= read -r l; do
    report "$f:${l%%:*}: ngày trong chú thích (giữ lý do, ngày và chuyện đo ghi ở docs/PROGRESS.md hoặc docs/history)"
  done
done

(( fail )) && { log_error "Tài liệu lệch: sửa các chỗ trên rồi chạy lại."; exit 1 }
log_ok "Tài liệu khớp."
