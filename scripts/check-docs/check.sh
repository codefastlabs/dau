#!/bin/zsh
# Mechanical doc checks, run before every commit that touches code or docs.
# Side effects: none
#
# Usage: scripts/check-docs/check.sh
#
# Living docs = docs/*.md except PROGRESS.md (history/ and research/ are not docs/*.md),
# CLAUDE.md, README.md, CONTRIBUTING.md, .claude/agents, .claude/commands. PROGRESS.md is
# read by checks 1 and 2 only, and only above its dated log.
# Checks:
#   1. repo paths in backticks exist (in PROGRESS.md, not in the dated log), in living docs
#      and docs/research/**/*.md; not-ours.txt lists the paths of other projects, of tools
#      removed from the repo and of files each developer creates locally;
#   1b. relative Markdown links resolve (living docs, docs/research, docs/canvas/README.md);
#   1c. docs/README.md names every Markdown file git tracks under docs/;
#   1d. every type or function name docs/ARCHITECTURE.md gives in backticks is a word of the
#      code (Apps, Packages, scripts/**/*.swift, project.yml, Config); system-names.txt lists
#      the names that belong to Apple;
#   2. no file:line references (line numbers drift; name the type or function);
#   3. every D# / N# cited exists in docs/DECISIONS.md;
#   3b. the first citation of each D# / N# in a living doc or docs/research/*.md carries its
#      name, "D4 (Từ nước ngoài)" (doc-check.swift names);
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
#   7. scripts: every scripts/**/*.sh (not .build), .claude/hooks/*.sh and .githooks/* starts with
#      "#!/bin/zsh" (one shell: /bin/bash on macOS is 3.2), passes `zsh -n`, assigns to
#      none of zsh's read-only parameters `status` and `pipestatus` (`zsh -n` does not see
#      that; the script dies at that line) and has a "# Side effects:" line; every script but the sourced files in scripts/lib has a
#      `set` line with -u and one with pipefail (scripts/README.md, "Mở đầu"); every repo
#      path in backticks in scripts/README.md exists; no script but scripts/lib/log.sh (and this file, which
#      names the patterns) writes ANSI color codes or the "==>" step mark (scripts/README.md, "Đầu ra");
#   8. hook table: every script whose "# Side effects:" line holds a disturbing effect is
#      named in .claude/hooks/guard-scripts.sh, so the hook cannot silently miss one.
#   9. every folder under scripts/ that git tracks has a row in the folder table of
#      scripts/README.md.
#   10. every option a living doc or docs/research/*.md cites for a script (in the same
#      code span) exists in that script (doc-check.swift flags).
#   11. script languages (scripts/README.md, "Ngôn ngữ"): outside scripts/research/external-tests,
#      no tracked .py/.pl/.rb file, no code line of a scripts/**/*.sh or hook that runs
#      python, perl or ruby, and no `swift <file>.swift` run interpreted (use dau_swift_tool).
#   12. project.yml never sets SWIFT_ACTIVE_COMPILATION_CONDITIONS (Debug would lose DEBUG).
# Checks 3b and 10 run doc-check.swift, compiled once into build/tools/ (scripts/lib/swift-tool.sh).
# Exit status 0 only if every check passes. Output (Vietnamese, via scripts/lib/log.sh):
# one "✗" line per problem, then a final verdict line.
set -uo pipefail
here=${0:A:h}
root=${here:h:h}
cd "$root"
source "$root/scripts/lib/log.sh"
source "$root/scripts/lib/swift-tool.sh"
doc_check=$(dau_swift_tool doc-check $here/doc-check.swift) || exit 1
fail=0
report() { log_error "$1"; fail=1 }

living=(docs/*.md(N) CLAUDE.md README.md(N) CONTRIBUTING.md(N) .claude/agents/*.md(N) .claude/commands/*.md(N))
living=(${living:#docs/PROGRESS.md})
cited=($living docs/PROGRESS.md)
research=(docs/research/**/*.md(N))

# 1. Paths.
# PROGRESS.md's dated log records the past: a path removed later stays as it was written.
# not-ours.txt lists the paths that are not files of this repo's working tree (another
# project's file, a tool removed from the repo, a file each developer creates locally).
not_ours=(${(f)"$(grep -vE '^(#|$)' $here/not-ours.txt | cut -f1)"})
for f in $cited $research; do
  text=$(<$f)
  [[ $f == docs/PROGRESS.md ]] && text=${text%%$'\n'\#\# Nhật ký*}
  for p in ${(f)"$(print -r -- $text | grep -oE '`(Apps|Packages|scripts|docs|Config|Resources|\.claude|\.githooks)/[^` ]+`' | tr -d '`' | sort -u)"}; do
    [[ -z $p ]] && continue
    p=${p%%:*}; p=${p%/}
    [[ $p == *'*'* || $p == *'<'* || $p == *'{'* || $p == *…* ]] && continue
    [[ -e $p ]] && continue
    for n in $not_ours; do [[ $p == $n || $p == $n/* ]] && continue 2; done
    report "$f: đường dẫn không tồn tại: $p"
  done
done

# 1b. Relative Markdown links resolve from the file that holds them.
for f in $cited $research docs/canvas/README.md(N); do
  for l in ${(f)"$(grep -oE '\]\([^)#: ]+(#[^)]*)?\)' $f | sed -E 's/^\]\(//; s/\)$//; s/#.*//' | sort -u)"}; do
    [[ -z $l ]] && continue
    [[ -e ${f:h}/$l ]] || report "$f: liên kết không tới file nào: $l"
  done
done

# 1c. docs/README.md is the index: it names every Markdown file under docs/.
index=$(<docs/README.md)
for f in ${(f)"$(git ls-files 'docs/*.md')"}; do
  [[ $f == docs/README.md || ! -e $f ]] && continue
  [[ $index == *"\`$f\`"* ]] || report "docs/README.md: thiếu $f trong mục lục"
done

# 1d. Names of types and functions in docs/ARCHITECTURE.md exist in the code: a capitalised
# identifier in backticks, alone or before ".member" or "(". system-names.txt lists the
# names that belong to Apple (keys, processes) and so are not in this repo's code.
code_words=$(cat Apps/**/*.(swift|plist|entitlements)(N) Packages/*/(Sources|Tests)/**/*.swift(N) \
  scripts/**/*.swift(N) project.yml Config/*(N.) | grep -oE '[A-Za-z_][A-Za-z0-9_]*' | sort -u)
nl=$'\n'
system_names=(${(f)"$(grep -vE '^(#|$)' $here/system-names.txt | cut -f1)"})
for id in ${(f)"$(grep -oE '`[A-Z][A-Za-z0-9]*[a-z][A-Za-z0-9]*(\.[a-z][A-Za-z0-9]*)?(\([^`]*\))?`' docs/ARCHITECTURE.md | tr -d '`' | sed -E 's/[.(].*//' | sort -u)"}; do
  [[ -z $id ]] && continue
  (( ${system_names[(Ie)$id]} )) && continue
  [[ $nl$code_words$nl == *$nl$id$nl* ]] || report "docs/ARCHITECTURE.md: tên $id không có trong mã"
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
named=($living $research)
named=(${named:#docs/DECISIONS.md})
$doc_check names $named | while IFS=$'\t' read -r f d found; do
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
# Hashes of other repositories: 89c2fd3 is the OpenKey commit docs/research/OPENKEY-NOTES.md read.
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
for s in scripts/**/*.sh(N) .claude/hooks/*.sh(N) .githooks/*(N.); do
  [[ $s == */.build/* ]] && continue
  [[ "$(head -1 $s)" == '#!/bin/zsh' ]] || report "$s: dòng đầu không phải #!/bin/zsh"
  zsh -n $s 2>/dev/null || report "$s: zsh -n báo lỗi cú pháp"
  grep -nE '^[[:space:]]*((local|typeset|integer|readonly)[[:space:]]+(-[A-Za-z]+[[:space:]]+)*)?(status|pipestatus)(=|[[:space:]]|$)' $s | while IFS= read -r l; do
    report "$s:${l%%:*}: gán vào biến chỉ đọc của zsh (status, pipestatus); đặt tên khác"
  done
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

# 9. Every tracked folder under scripts/ is in scripts/README.md's folder table.
for d in ${(f)"$(git ls-files scripts | cut -d/ -f2 | sort -u)"}; do
  [[ -d scripts/$d ]] || continue
  [[ "$(<scripts/README.md)" == *"| \`scripts/$d/\` |"* ]] || report "scripts/README.md: thư mục scripts/$d/ chưa có dòng trong bảng thư mục"
done

# 10. Options cited for a script exist in it.
$doc_check flags $living $research | while IFS=$'\t' read -r f sc opt; do
  report "$f: $sc không có tuỳ chọn $opt"
done

# 11. Script languages.
exempt=scripts/research/external-tests/
for f in ${(f)"$(git ls-files 'scripts/*.py' 'scripts/*.pl' 'scripts/*.rb' '.claude/*.py' '.claude/*.pl' '.claude/*.rb')"}; do
  [[ -z $f || $f == $exempt* || ! -e $f ]] && continue
  report "$f: script ngoài zsh và Swift (scripts/README.md, \"Ngôn ngữ\")"
done
for s in scripts/**/*.sh(N) .claude/hooks/*.sh(N) .githooks/*(N.); do
  [[ $s == $exempt* || $s == */.build/* || $s == scripts/check-docs/check.sh ]] && continue
  grep -nvE '^[[:space:]]*#' $s | grep -E '(^|[^[:alnum:]_./-])(/usr/bin/)?(python3?|perl|ruby)([[:space:]]|$)|(^|[[:space:]])(xcrun )?swift [^[:space:]]+\.swift' \
    | while IFS= read -r l; do
      report "$s:${l%%:*}: chạy Python/Perl/Ruby hoặc Swift thông dịch (scripts/README.md, \"Ngôn ngữ\")"
    done
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

# 12. project.yml never sets SWIFT_ACTIVE_COMPILATION_CONDITIONS: set there it replaces
# XcodeGen's per-config preset and Debug loses DEBUG (every #if DEBUG goes dark). Custom
# conditions go in OTHER_SWIFT_FLAGS (-D…), as DAU_OFFICIAL does (D25).
grep -n '^[^#]*SWIFT_ACTIVE_COMPILATION_CONDITIONS' project.yml | while IFS= read -r l; do
  report "project.yml:${l%%:*}: đặt SWIFT_ACTIVE_COMPILATION_CONDITIONS làm bản Debug mất DEBUG; dùng OTHER_SWIFT_FLAGS (-D…)"
done

(( fail )) && { log_error "Tài liệu lệch: sửa các chỗ trên rồi chạy lại."; exit 1 }
log_ok "Tài liệu khớp."
