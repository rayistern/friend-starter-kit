#!/usr/bin/env bash
# ----------------------------------------------------------------------------
# dangerous-bash-block.sh
#
# WHAT THIS IS:
#   A Claude Code "PreToolUse" safety hook. Claude Code runs this script every
#   time the assistant is about to run a shell (Bash) command. The script reads
#   the command, and if it matches a known-dangerous pattern (like "rm -rf" or
#   "git push --force"), it tells Claude Code to BLOCK the command before it
#   runs. Nothing is deleted; the command is simply refused.
#
# WHY:
#   When you're newer to a tool, the scariest failure mode is an assistant
#   confidently running a command that wipes files or rewrites git history.
#   This hook is a seatbelt: it stops the handful of commands that are almost
#   never what you want, and asks you to confirm if you really meant it.
#
# HOW TO BYPASS (when you genuinely DO mean it):
#   Set the environment variable CLAUDE_ALLOW_DANGEROUS=1 for that session.
#   On WSL2 / Linux / macOS:  export CLAUDE_ALLOW_DANGEROUS=1
#
# REQUIREMENTS:
#   This is a bash script and needs the `jq` tool (a tiny JSON processor) on
#   your PATH. On WSL2/Ubuntu:  sudo apt-get install -y jq
# ----------------------------------------------------------------------------
set -u

# Escape hatch: if the user has explicitly opted in for this session, do nothing.
[ "${CLAUDE_ALLOW_DANGEROUS:-0}" = "1" ] && exit 0

# Claude Code passes the tool call to us as JSON on standard input.
INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')

# We only care about shell commands. Anything else: let it through untouched.
[ "$TOOL" != "Bash" ] && exit 0

CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
[ -z "$CMD" ] && exit 0

MATCH=""
# Order matters here — we check the most specific / most destructive patterns
# first so the reported reason is as precise as possible.
if echo "$CMD" | grep -qE 'rm[[:space:]]+(-[[:alnum:]]*[rRf][[:alnum:]]*[[:space:]]+)+/'; then
    MATCH="rm -rf on an absolute path (could delete large parts of your disk)"
elif echo "$CMD" | grep -qE 'rm[[:space:]]+(-[[:alnum:]]*[rR][[:alnum:]]*[[:space:]]+-[[:alnum:]]*f|-[[:alnum:]]*rf|-[[:alnum:]]*fr)'; then
    MATCH="rm -rf (recursive force-delete)"
elif echo "$CMD" | grep -qE 'git[[:space:]]+push[[:space:]]+(-f|--force)'; then
    MATCH="git push --force (can overwrite history on the server)"
elif echo "$CMD" | grep -qE 'git[[:space:]]+reset[[:space:]]+--hard'; then
    MATCH="git reset --hard (throws away uncommitted work)"
elif echo "$CMD" | grep -qE 'git[[:space:]]+checkout[[:space:]]+\.[[:space:]]*$'; then
    MATCH="git checkout . (discards all working changes)"
elif echo "$CMD" | grep -qE 'git[[:space:]]+restore[[:space:]]+\.[[:space:]]*$'; then
    MATCH="git restore . (discards all working changes)"
elif echo "$CMD" | grep -qE 'git[[:space:]]+clean[[:space:]]+(-[[:alnum:]]*f|-f[[:alnum:]]*)'; then
    MATCH="git clean -f (force-deletes untracked files)"
elif echo "$CMD" | grep -qE 'git[[:space:]]+branch[[:space:]]+-D'; then
    MATCH="git branch -D (force-delete a branch)"
elif echo "$CMD" | grep -qiE 'DROP[[:space:]]+TABLE'; then
    MATCH="DROP TABLE (deletes a database table)"
elif echo "$CMD" | grep -qiE 'DELETE[[:space:]]+FROM' && ! echo "$CMD" | grep -qiE 'WHERE'; then
    MATCH="DELETE FROM without a WHERE clause (deletes every row)"
fi

if [ -n "$MATCH" ]; then
    REASON="Blocked: command matches a dangerous pattern — '$MATCH'. If you really want this, ask the user to confirm, or set CLAUDE_ALLOW_DANGEROUS=1 for this session and try again."
    # This JSON shape tells Claude Code: deny the tool call, and show this reason.
    jq -n --arg r "$REASON" '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":$r}}'
    exit 0
fi

# No dangerous pattern matched — allow the command to run normally.
exit 0
