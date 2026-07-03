#!/usr/bin/env bash
# ----------------------------------------------------------------------------
# push-to-main-warn.sh
#
# WHAT THIS IS:
#   A Claude Code "PreToolUse" hook that runs before a shell command. If the
#   command pushes to the "main" (or "master") branch, it prints a friendly
#   WARNING. It does NOT block — the push still happens.
#
# WHY:
#   A common good habit is: do your work on a separate "feature branch", then
#   merge it into main through a pull request (a reviewed change). Pushing
#   straight to main skips that review step. This hook just reminds you when
#   that's about to happen, so it's a deliberate choice and not an accident.
#
# REQUIREMENTS: bash + jq (sudo apt-get install -y jq on WSL2/Ubuntu).
# ----------------------------------------------------------------------------
set -u

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')
[ "$TOOL" != "Bash" ] && exit 0

CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
[ -z "$CMD" ] && exit 0

# Fast exit: if the command isn't a git push at all, there's nothing to warn about.
echo "$CMD" | grep -qE 'git[[:space:]]+push' || exit 0

WARN=""
# Case 1: the command names main/master explicitly as the push target.
if echo "$CMD" | grep -qE 'git[[:space:]]+push([[:space:]]+[^[:space:]]+)*[[:space:]]+(main|master)([[:space:]]|$)'; then
    WARN="explicit push to main/master"
elif echo "$CMD" | grep -qE 'git[[:space:]]+push[[:space:]]+(main|master)([[:space:]]|$)'; then
    WARN="push to a main/master remote"
elif echo "$CMD" | grep -qE '^[[:space:]]*git[[:space:]]+push[[:space:]]*$'; then
    # Case 2: a bare "git push" with no arguments. Whether that hits main
    # depends on which branch you're currently on, so we check the branch.
    CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
    [ -z "$CWD" ] && CWD="$PWD"
    BRANCH=$(cd "$CWD" 2>/dev/null && git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
    if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
        WARN="bare 'git push' while on the $BRANCH branch"
    fi
fi

if [ -n "$WARN" ]; then
    # A "systemMessage" shows the note to you and Claude without blocking anything.
    MSG="[push-to-main-warn] $WARN. The usual safer habit is to work on a feature branch (e.g. feature/my-change) and merge into main via a pull request. Proceeding anyway."
    printf '{"systemMessage":%s}\n' "$(jq -Rn --arg m "$MSG" '$m')"
fi

exit 0
