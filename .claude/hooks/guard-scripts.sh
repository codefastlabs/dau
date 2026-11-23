#!/bin/zsh
# PreToolUse hook (Bash): subagents never run the repo scripts that take over the screen or
# change the installed Dấu (CLAUDE.md, section "Điều phối"); only the main session does.
# Side effects: none
#
# Only what Claude Code cannot do itself: its permission rules apply to the main session and
# to subagents alike, and a subagent's `disallowedTools` removes all of Bash, not one command.
# Whether the main session asks the user first is Claude Code's permission mode, so the
# main session's calls pass here untouched.
#
# For a subagent's call (the hook input has agent_id), splits the command into simple
# commands (on ; && || | & and parentheses). When one of them runs a script listed in the
# table below (directly, or through zsh/bash/sh/source/env/time/nohup) and the table says it
# is guarded for that simple command's arguments, the call is blocked with exit 2.
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
# The main session runs every script; whether the user is asked first is Claude Code's
# permission mode (Manual asks, Bypass permissions does not), not this hook.
[[ -z $agent ]] && exit 0

root=${CLAUDE_PROJECT_DIR:-${0:A:h:h:h}}
# script -> when blocked: "always", "with --flag" (only when the flag is given),
# "unless --flag" (unless the flag is given); several flags: "unless --a|--b" (any of them).
typeset -A guarded=(
  [scripts/selftest/typing/run.sh]="always"
  [scripts/selftest/load/run.sh]="unless --dry-run|--print"
  [scripts/selftest/load/heavy.sh]="unless --dry-run"
  [scripts/selftest/settings-window/run.sh]="always"
  [scripts/selftest/app-group.sh]="always"
  [scripts/selftest/typing/typed-word-docs.sh]="always"
  [scripts/research/compare-ims/run.sh]="always"
  [scripts/research/terminal-underline/run.sh]="always"
  [scripts/research/terminal-underline/real-shell.sh]="always"
  [scripts/dev/install-app.sh]="unless --build-only"
  [scripts/dev/clean-dau.sh]="with --yes"
  [scripts/release/layout-dmg.sh]="always"
  [scripts/release/build-release.sh]="with --layout"
  [scripts/release/promote-release.sh]="unless --dry-run"
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
source "$root/scripts/lib/log.sh"
log_error "Chặn: subagent không chạy script chiếm màn hình hay đổi bản Dấu đã cài (CLAUDE.md, mục \"Điều phối\"):"
log_hint "${(@)blocked}"
log_hint "Ghi vào mục 4 của báo cáo để phiên chính chạy."
exit 2
