#!/usr/bin/env bash
# ----------------------------------------------------------------------------
# claudemd-warn.sh
#
# WHAT THIS IS:
#   A Claude Code "PreToolUse" hook that runs before a file edit/write. If the
#   file being changed is a CLAUDE.md, it prints a gentle WARNING. It does NOT
#   block the edit.
#
# WHY:
#   A CLAUDE.md file holds the standing instructions Claude Code reads at the
#   start of every session in that folder. It is high-leverage: a change to it
#   affects every future conversation. This hook just makes sure such edits are
#   noticed and deliberate, rather than slipped in as a side effect of some
#   other task.
#
# REQUIREMENTS: bash + jq (sudo apt-get install -y jq on WSL2/Ubuntu).
# ----------------------------------------------------------------------------
set -u

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')
FP=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only relevant for file-writing tools.
case "$TOOL" in
    Edit|Write|MultiEdit) ;;
    *) exit 0 ;;
esac

[ -z "$FP" ] && exit 0

# Match any file literally named CLAUDE.md, regardless of which folder it's in.
BASENAME=$(basename "$FP")
if [ "$BASENAME" = "CLAUDE.md" ]; then
    MSG="[claudemd-warn] You are editing $FP. CLAUDE.md sets the standing instructions for every Claude Code session in this folder, so changes here are high-impact. Make sure this edit is intended. Proceeding anyway."
    printf '{"systemMessage":%s}\n' "$(jq -Rn --arg m "$MSG" '$m')"
fi

exit 0
