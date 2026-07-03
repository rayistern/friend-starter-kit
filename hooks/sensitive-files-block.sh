#!/usr/bin/env bash
# ----------------------------------------------------------------------------
# sensitive-files-block.sh
#
# WHAT THIS IS:
#   A Claude Code "PreToolUse" safety hook that runs before Claude Code edits
#   or writes a file. If the target file looks like it holds secrets — a `.env`
#   file, something with "credentials" or "secret" in the name, or a private
#   key (.key / .pem) — the hook BLOCKS the write.
#
# WHY:
#   Secret files (API keys, passwords, tokens) are the files you least want an
#   assistant to rewrite by accident, and the files most dangerous to commit to
#   git. Blocking writes to them by default protects you from both leaking a
#   secret into version control and clobbering credentials you need.
#
# HOW TO BYPASS (e.g. you really are scaffolding an example file):
#   Set CLAUDE_ALLOW_SENSITIVE=1 for that session.
#   On WSL2 / Linux / macOS:  export CLAUDE_ALLOW_SENSITIVE=1
#
# NOTE: This intentionally does NOT block ".envrc" or "env.example" / ".env.example"
#   style files, because those are meant to be edited and contain no real secrets.
#   (Bugfix 2026-07-03: the original pattern accidentally blocked ".env.example"
#   too, contradicting this note — an explicit example/sample/template/dist
#   suffix exclusion was added below so template files stay editable while real
#   env files like ".env.local" and ".env.production" stay blocked.)
#
# REQUIREMENTS: bash + jq (sudo apt-get install -y jq on WSL2/Ubuntu).
# ----------------------------------------------------------------------------
set -u

# Escape hatch for intentional edits to example/scaffolding files.
[ "${CLAUDE_ALLOW_SENSITIVE:-0}" = "1" ] && exit 0

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')

# Only relevant for file-writing tools. Everything else passes through.
case "$TOOL" in
    Edit|Write|MultiEdit) ;;
    *) exit 0 ;;
esac

FP=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
[ -z "$FP" ] && exit 0

# We match on the file's name only (not the full path), lower-cased so the
# patterns are case-insensitive.
BASENAME=$(basename "$FP")
LOWER=$(echo "$BASENAME" | tr '[:upper:]' '[:lower:]')

MATCH=""
# ".env", ".env.local", ".env.production", etc. — but NOT ".envrc" (no dot
# before "rc", so the pattern below doesn't match it) and NOT template files
# like ".env.example" / ".env.sample" / ".env.template" / ".env.dist". Those
# templates hold placeholder values by design, are meant to be committed and
# edited freely, and the kit's .gitignore likewise un-ignores ".env.example" —
# blocking them would just train the user to reach for the bypass variable,
# which weakens the habit of taking this hook's blocks seriously.
if echo "$LOWER" | grep -qE '^\.env(\.[a-z0-9_-]+)?$' \
   && ! echo "$LOWER" | grep -qE '\.(example|sample|template|dist)$'; then
    MATCH=".env file (usually holds secrets)"
elif echo "$LOWER" | grep -q 'credentials'; then
    MATCH="'credentials' in the filename"
elif echo "$LOWER" | grep -qE '\.(key|pem)$'; then
    MATCH="private key file (.key / .pem)"
elif echo "$LOWER" | grep -q 'secret'; then
    MATCH="'secret' in the filename"
fi

if [ -n "$MATCH" ]; then
    REASON="Blocked: $FP looks like a secrets file ($MATCH). If this is intentional (for example, editing an example template), ask the user to confirm, or set CLAUDE_ALLOW_SENSITIVE=1 for this session."
    jq -n --arg r "$REASON" '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":$r}}'
    exit 0
fi

exit 0
