#!/bin/zsh
# PreToolUse hook (Bash): repo scripts the user must schedule (CLAUDE.md, section "Điều phối")
# run only after the user allows them in Claude Code's permission prompt.
# Side effects: none
#
# Splits the command into simple commands (on ; && || | & and parentheses). When one of
# them runs a script listed in the table below (directly, or through
# zsh/bash/sh/source/env/time/nohup) and the table says it is guarded for that simple
# command's arguments:
#   - a subagent's call (the hook input has agent_id) is blocked with exit 2: subagents
#     never run these scripts;
#   - the main session's call gets permissionDecision "ask": Claude Code shows the user a
#     permission prompt, and the script runs only if the user allows it.
# Reading a script (cat, grep, sed) is not running it and passes. Not a lock: a script
# run after `cd` into its own folder is not seen.
# The table is explicit: a new script whose "# Side effects:" line disturbs the user
# must be added to it by hand.
set -uo pipefail
setopt extendedglob

input=$(cat)
cmd=$(jq -r '.tool_input.command // empty' <<< "$input")
agent=$(jq -r '.agent_id // empty' <<< "$input")
[[ -z $cmd ]] && exit 0

root=${CLAUDE_PROJECT_DIR:-${0:A:h:h:h}}
# script -> when blocked: "always", "with --flag" (only when the flag is given),
# "unless --flag" (unless the flag is given); several flags: "unless --a|--b" (any of them).
typeset -A guarded=(
  [scripts/selftest/typing/run.sh]="always"
  [scripts/selftest/load/run.sh]="unless --dry-run|--print"
  [scripts/selftest/load/heavy.sh]="unless --dry-run"
  [scripts/selftest/settings-window/run.sh]="always"
  [scripts/selftest/app-group.sh]="always"
  [scripts/selftest/typing/d20-docs.sh]="always"
  [scripts/research/compare-ims/run.sh]="always"
  [scripts/research/terminal-underline/run.sh]="always"
  [scripts/research/terminal-underline/real-shell.sh]="always"
  [scripts/dev/install-app.sh]="unless --build-only"
  [scripts/dev/clean-dau.sh]="with --yes"
  [scripts/release/layout-dmg.sh]="always"
  [scripts/release/build-release.sh]="with --layout"
)
runners=(zsh bash sh source . env time nohup exec command)

blocked=()
for seg in ${(f)${cmd//(\&\&|\|\||[;|\&()])/$'\n'}}; do
  words=(${(Q)${(z)seg}})
  # Skip VAR=value assignments, runner words and the runner's own options.
  # A shell's -n only parses the script (syntax check): not a run.
  syntax_only=0
  while (( $#words )) && [[ $words[1] == [A-Za-z_][A-Za-z0-9_]#=* || ${runners[(Ie)$words[1]]} -gt 0 ]]; do
    shift words
    while (( $#words )) && [[ $words[1] == -* ]]; do
      [[ $words[1] == -[a-z]#n[a-z]# ]] && syntax_only=1
      shift words
    done
  done
  (( $#words && ! syntax_only )) || continue
  [[ $words[1] == (*/|)scripts/*.sh ]] || continue
  rel=scripts/${words[1]#*scripts/}
  rule=${guarded[$rel]-}
  [[ -n $rule ]] || continue
  args=(${words[2,-1]})
  kind=${rule%% *}; flag=${rule#* }
  present=0
  if [[ $kind != always ]]; then for f in ${(s:|:)flag}; do (( ${args[(I)$f]} )) && present=1; done; fi
  [[ $kind == unless && $present == 1 ]] && continue
  [[ $kind == with && $present == 0 ]] && continue
  blocked+=("$rel (${rule})")
done

(( $#blocked )) || exit 0
if [[ -n $agent ]]; then
  source "$root/scripts/lib/log.sh"
  log_error "Chặn: subagent không chạy script người dùng tự chọn giờ chạy (CLAUDE.md, mục \"Điều phối\"):"
  log_hint "${(@)blocked}"
  log_hint "Ghi vào mục 4 của báo cáo để phiên chính chạy."
  exit 2
fi
jq -n --arg reason "Script cần bạn cho phép (chiếm màn hình hoặc đổi bản Dấu đã cài): ${(j:, :)blocked}. Cho phép thì script chạy ngay." \
  '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "ask", permissionDecisionReason: $reason}}'
