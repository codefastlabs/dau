#!/bin/zsh
# Mechanical doc checks, run before every commit that touches code or docs.
#
# Usage: scripts/check-docs/check.sh
#
# Living docs = docs/*.md (except PROGRESS.md's dated log and history/research,
# which record the past), CLAUDE.md, README.md, .claude/agents, .claude/commands.
# Checks:
#   1. repo paths in backticks exist;
#   2. no file:line references (line numbers drift; name the type or function);
#   3. every D# / N# cited exists in docs/DECISIONS.md;
#   4. no wording listed in superseded.txt (DECISIONS.md and the dated M*-TESTING.md plans may);
#   5. PROGRESS.md "Trạng thái hiện tại" holds no test counts;
#   6. UI.md, UI-CHECKS.md and ARCHITECTURE.md hold no UI measurements (pt, W×H):
#      they live in scripts/check-settings-window/Reference.swift and
#      docs/research/SYSTEM-SETTINGS-REFERENCE.md. Code spans in backticks are skipped.
# Exit status 0 only if every check passes.
set -uo pipefail
here=${0:A:h}
root=${here:h:h}
cd "$root"
fail=0
report() { print -r -- "$1"; fail=1 }

living=(docs/*.md(N) CLAUDE.md README.md(N) .claude/agents/*.md(N) .claude/commands/*.md(N))
living=(${living:#docs/PROGRESS.md})
cited=($living docs/PROGRESS.md)

# 1. Paths.
for f in $cited; do
  for p in ${(f)"$(grep -oE '`(Apps|Packages|scripts|docs|\.claude)/[^` ]+`' $f | tr -d '`' | sort -u)"}; do
    [[ -z $p ]] && continue
    p=${p%%:*}; p=${p%/}
    [[ $p == *'*'* || $p == *'<'* || $p == *'{'* || $p == *…* ]] && continue
    [[ -e $p ]] || report "$f: missing path $p"
  done
done

# 2. Line numbers.
for f in $cited; do
  grep -nE '[A-Za-z]+\.(swift|plist|yml|json):[0-9]+' $f | while read -r l; do report "$f: line reference: ${l[1,160]}"; done
done

# 3. Decision numbers.
known=(${(f)"$(grep -oE '^- \*\*[DN][0-9]+' docs/DECISIONS.md | grep -oE '[DN][0-9]+' | sort -u)"})
for f in $living; do
  for d in ${(f)"$(grep -oE '\b[DN][0-9]{1,2}\b' $f | sort -u)"}; do
    [[ -z $d ]] && continue
    (( ${known[(Ie)$d]} )) || report "$f: cites $d, not in DECISIONS.md"
  done
done

# 4. Superseded wording.
grep -vE '^(#|$)' $here/superseded.txt | while IFS=$'\t' read -r pattern why; do
  for f in ${${living:#docs/DECISIONS.md}:#docs/*-TESTING.md}; do
    grep -nE -- "$pattern" $f | while read -r l; do report "$f: superseded ($why): ${l[1,140]}"; done
  done
done

# 5. Status section without test counts.
awk '/^## Trạng thái hiện tại/{on=1; next} /^## /{on=0} on' docs/PROGRESS.md \
  | grep -nE '[0-9]+ test|test[^.]*[0-9]{2}' | while read -r l; do report "docs/PROGRESS.md status: test count: ${l[1,120]}"; done

# 6. No UI measurements outside their single home.
for f in docs/UI.md docs/UI-CHECKS.md docs/ARCHITECTURE.md; do
  sed -E 's/`[^`]*`//g' $f | grep -nE '[0-9]{2,} ?pt\b|[0-9]{2,} ?× ?[0-9]{2,}' | while read -r l; do report "$f: UI measurement belongs in Reference.swift: ${l[1,140]}"; done
done

(( fail )) && { print "Doc checks failed."; exit 1 }
print "Doc checks passed."
