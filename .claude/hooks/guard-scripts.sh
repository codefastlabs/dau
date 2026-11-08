#!/bin/zsh
# PreToolUse hook (Bash): blocks repo scripts the user must schedule (scripts/README.md, "Ai chạy").
# Side effects: none
#
# Splits the command into simple commands (on ; && || | & and parentheses). When one of
# them runs scripts/**/*.sh (directly, or through zsh/bash/sh/source/env/time/nohup),
# parses that script's "# Side effects:" line: clauses split by ";", "unless --flag: …"
# and "with --flag: …" honoured against that simple command's words, parentheses
# ignored. Blocks with exit 2 when an effect that disturbs the user's machine applies.
# Reading a script (cat, grep, sed) is not running it and passes.
# A command that contains DAU_USER_APPROVED=1 passes: only the main session writes it,
# after the user said yes in chat. A speed bump, not a lock: a script run after `cd`
# into its own folder is not seen.
set -uo pipefail
setopt extendedglob

cmd=$(jq -r '.tool_input.command // empty')
[[ -z $cmd || $cmd == *DAU_USER_APPROVED=1* ]] && exit 0

root=${CLAUDE_PROJECT_DIR:-${0:A:h:h:h}}
disturbing=('takes the screen' 'kills processes' 'changes input source' 'installs input method'
            'installs app' 'deletes data' 'changes user settings' 'needs admin password')
runners=(zsh bash sh source . env time nohup exec command)

blocked=()
for seg in ${(f)"$(print -r -- $cmd | perl -pe 's/&&|\|\||[;|&()]/\n/g')"}; do
  words=(${(Q)${(z)seg}})
  # Skip VAR=value assignments, runner words and the runner's own options.
  while (( $#words )) && [[ $words[1] == [A-Za-z_][A-Za-z0-9_]#=* || ${runners[(Ie)$words[1]]} -gt 0 ]]; do
    shift words
    while (( $#words )) && [[ $words[1] == -* ]]; do shift words; done
  done
  (( $#words )) || continue
  [[ $words[1] == (*/|)scripts/*.sh ]] || continue
  rel=scripts/${words[1]#*scripts/}
  file=$root/$rel
  [[ -f $file ]] || continue
  header=$(grep -m1 '^# Side effects: ' $file) || continue
  header=$(print -r -- ${header#\# Side effects: } | sed -E 's/\([^)]*\)//g')
  args=(${words[2,-1]})
  applied=()
  for clause in ${(s:;:)header}; do
    clause=${clause##[[:space:]]#}
    if [[ $clause =~ '^(unless|with) ([^:]+): *(.*)$' ]]; then
      kind=$match[1]; flags=(${(M)${(s: :)match[2]}:#--*}); clause=$match[3]
      present=0
      for f in $flags; do
        (( ${args[(I)$f]} || ${args[(I)$f=*]} )) && present=1
      done
      [[ $kind == unless && $present == 1 ]] && continue
      [[ $kind == with && $present == 0 ]] && continue
    fi
    for e in $disturbing; do
      [[ $clause == *$e* ]] && applied+=($e)
    done
  done
  (( $#applied )) && blocked+=("$rel (${(j:, :)${(@u)applied}})")
done

(( $#blocked )) || exit 0
{
  print -r -- "Blocked: scripts the user runs at a time they choose (scripts/README.md, column \"Ai chạy\"):"
  print -rl -- "  "${^blocked}
  print -r -- "Subagent: do not run it; list it under item 4 of your report."
  print -r -- "Main session: ask the user when to run it; once they say yes in chat, rerun with the prefix DAU_USER_APPROVED=1."
} >&2
exit 2
