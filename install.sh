#!/usr/bin/env bash
# ----------------------------------------------------------------------------
# install.sh
#
# WHAT THIS IS:
#   A one-command installer for this starter kit. It copies the kit's files into
#   your Claude Code config folder (~/.claude): the global CLAUDE.md, the safe
#   settings.json, and the four safety hooks (made executable).
#
# SAFETY:
#   It will NOT overwrite an existing ~/.claude/settings.json or ~/.claude/CLAUDE.md,
#   because you may have customized them. If one exists, it is left untouched and
#   you're told to merge by hand — unless you pass --force, in which case the
#   existing file is backed up (to <file>.pre-starter-kit.bak) before replacing.
#   The hooks are always (re)installed, since they live in their own folder and
#   don't clobber anything you'd have edited.
#
# USAGE:
#   ./install.sh            # safe install; skips existing config files
#   ./install.sh --force    # replace existing config files (backs them up first)
#
# REQUIREMENTS: bash. The hooks it installs also need jq at runtime; this script
#   warns if jq is missing but still installs (you can add jq afterwards).
# ----------------------------------------------------------------------------
set -u

FORCE=0
[ "${1:-}" = "--force" ] && FORCE=1

# Resolve the kit directory from this script's own location so it works from anywhere.
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="$HOME/.claude"

echo "Installing the Claude Code Starter Kit into: $DEST"

# The hooks depend on jq at runtime. Warn early if it's missing, but don't abort —
# the user can install jq later and the copied files are still valid.
if ! command -v jq >/dev/null 2>&1; then
    echo "  WARNING: 'jq' is not installed. The safety hooks need it to run."
    echo "           Install it with: sudo apt-get install -y jq   (macOS: brew install jq)"
fi

mkdir -p "$DEST/hooks"

# copy_config <filename>
#   Copy a top-level config file into ~/.claude, protecting any existing one.
copy_config() {
    local f="$1" src="$HERE/$1" dst="$DEST/$1"
    if [ -e "$dst" ] && [ "$FORCE" -ne 1 ]; then
        echo "  SKIP   $f — $dst already exists; not overwriting."
        echo "         Merge by hand, or re-run with --force to replace it (a backup is made)."
        return
    fi
    if [ -e "$dst" ]; then
        cp "$dst" "$dst.pre-starter-kit.bak"
        echo "  BACKUP $f → $(basename "$dst").pre-starter-kit.bak"
    fi
    cp "$src" "$dst"
    echo "  COPIED $f → $dst"
}

copy_config CLAUDE.md
copy_config settings.json

# Hooks are additive and self-contained — always refresh them and set the execute bit.
cp "$HERE"/hooks/*.sh "$DEST/hooks/"
chmod +x "$DEST"/hooks/*.sh
echo "  COPIED hooks/*.sh → $DEST/hooks/ (made executable)"

echo
echo "Done. Recommended next steps:"
echo "  1. ./test-hooks.sh      # confirm the safety hooks work"
echo "  2. claude               # start Claude Code and log in"
