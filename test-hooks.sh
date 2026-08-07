#!/usr/bin/env bash
# ----------------------------------------------------------------------------
# test-hooks.sh
#
# WHAT THIS IS:
#   A one-command self-test for the four safety hooks in this kit. It feeds each
#   hook the same kind of JSON that Claude Code feeds it (on standard input) for
#   a range of situations, and checks the hook reacts correctly:
#     - block hooks should DENY dangerous input and stay silent on safe input
#     - warn  hooks should WARN on the relevant input and stay silent otherwise
#
# WHY:
#   The README's Step 5 verifies the install by asking Claude to run a dangerous
#   command and watching it get refused. That works, but it depends on the
#   assistant's phrasing and needs a live session. This script verifies all four
#   hooks deterministically, in one command, before you even start Claude Code.
#
# HOW HOOKS SIGNAL (so you can read the checks below):
#   A hook that BLOCKS prints JSON containing "permissionDecision":"deny".
#   A hook that WARNS prints JSON containing "systemMessage".
#   A hook that is fine with the input prints NOTHING and exits 0.
#   This script classifies each run by which of those it sees.
#
# REQUIREMENTS: bash + jq (the hooks need jq). On WSL2/Ubuntu: sudo apt-get install -y jq
#
# EXIT CODE: 0 if every check passes, 1 if any check fails, 2 if jq is missing.
# ----------------------------------------------------------------------------
set -u

# Resolve the kit directory from this script's own location, so the test works
# no matter where it's invoked from.
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS="$HERE/hooks"

if ! command -v jq >/dev/null 2>&1; then
    echo "ERROR: 'jq' is not installed, and the hooks need it to run."
    echo "       Install it first:  sudo apt-get install -y jq   (macOS: brew install jq)"
    exit 2
fi

pass=0
fail=0

# run <label> <hook-filename> <expected> <json-payload>
#   <expected> is one of: block | warn | pass
# Feeds the JSON to the hook on stdin, classifies the reaction, compares.
run() {
    local label="$1" hook="$2" expected="$3" json="$4"
    local out actual
    out="$(printf '%s' "$json" | bash "$HOOKS/$hook" 2>/dev/null)"
    if printf '%s' "$out" | grep -q '"permissionDecision"'; then
        actual="block"
    elif printf '%s' "$out" | grep -q '"systemMessage"'; then
        actual="warn"
    else
        actual="pass"
    fi
    if [ "$actual" = "$expected" ]; then
        printf '  PASS   %-6s  %s\n' "[$expected]" "$label"
        pass=$((pass + 1))
    else
        printf '  FAIL   expected %s, got %s  —  %s\n' "$expected" "$actual" "$label"
        fail=$((fail + 1))
    fi
}

# Small helpers to build the two payload shapes the hooks understand.
bash_cmd() { printf '{"tool_name":"Bash","tool_input":{"command":%s}}' "$(jq -Rn --arg c "$1" '$c')"; }
edit_file() { printf '{"tool_name":"%s","tool_input":{"file_path":%s}}' "$2" "$(jq -Rn --arg f "$1" '$f')"; }

echo "=== dangerous-bash-block.sh (should BLOCK destructive commands) ==="
run "rm -rf on an absolute path"          dangerous-bash-block.sh block "$(bash_cmd 'rm -rf /')"
run "rm -rf on a relative path"           dangerous-bash-block.sh block "$(bash_cmd 'rm -rf ./build')"
run "git push --force"                    dangerous-bash-block.sh block "$(bash_cmd 'git push --force origin main')"
run "git reset --hard"                    dangerous-bash-block.sh block "$(bash_cmd 'git reset --hard HEAD~1')"
run "DROP TABLE"                          dangerous-bash-block.sh block "$(bash_cmd 'DROP TABLE users;')"
run "DELETE FROM without WHERE"           dangerous-bash-block.sh block "$(bash_cmd 'DELETE FROM users')"
run "safe: ls -la"                        dangerous-bash-block.sh pass  "$(bash_cmd 'ls -la')"
run "safe: git status"                    dangerous-bash-block.sh pass  "$(bash_cmd 'git status')"
run "safe: rm a single file"              dangerous-bash-block.sh pass  "$(bash_cmd 'rm oldfile.txt')"
run "safe: DELETE FROM with WHERE"        dangerous-bash-block.sh pass  "$(bash_cmd 'DELETE FROM users WHERE id=1')"
run "ignores non-Bash tools"             dangerous-bash-block.sh pass  "$(edit_file '/tmp/x.txt' Edit)"

echo
echo "=== sensitive-files-block.sh (should BLOCK writes to secret files) ==="
run ".env"                                sensitive-files-block.sh block "$(edit_file '/home/u/proj/.env' Edit)"
run ".env.local"                          sensitive-files-block.sh block "$(edit_file '/home/u/proj/.env.local' Write)"
run "credentials.json"                    sensitive-files-block.sh block "$(edit_file '/home/u/credentials.json' Edit)"
run "private key .pem"                    sensitive-files-block.sh block "$(edit_file '/home/u/server.pem' Edit)"
run "filename contains 'secret'"          sensitive-files-block.sh block "$(edit_file '/home/u/my-secret.txt' Write)"
run "safe: .env.example (the 2026-07-03 bugfix)" sensitive-files-block.sh pass "$(edit_file '/home/u/.env.example' Edit)"
run "safe: .envrc"                        sensitive-files-block.sh pass  "$(edit_file '/home/u/.envrc' Edit)"
run "safe: README.md"                     sensitive-files-block.sh pass  "$(edit_file '/home/u/README.md' Edit)"
run "ignores non-write tools"            sensitive-files-block.sh pass  "$(bash_cmd 'cat .env')"

echo
echo "=== push-to-main-warn.sh (should WARN on pushes to main/master) ==="
run "push to main"                        push-to-main-warn.sh warn "$(bash_cmd 'git push origin main')"
run "push to master"                      push-to-main-warn.sh warn "$(bash_cmd 'git push origin master')"
run "safe: push to a feature branch"      push-to-main-warn.sh pass "$(bash_cmd 'git push origin feature/login')"
run "safe: not a push at all"             push-to-main-warn.sh pass "$(bash_cmd 'git status')"

echo
echo "=== claudemd-warn.sh (should WARN when editing a CLAUDE.md) ==="
run "edit CLAUDE.md"                       claudemd-warn.sh warn "$(edit_file '/home/u/proj/CLAUDE.md' Edit)"
run "edit CLAUDE.md in a subfolder"        claudemd-warn.sh warn "$(edit_file '/home/u/proj/sub/CLAUDE.md' Write)"
run "safe: edit README.md"                 claudemd-warn.sh pass "$(edit_file '/home/u/proj/README.md' Edit)"
run "ignores non-write tools"             claudemd-warn.sh pass "$(bash_cmd 'cat CLAUDE.md')"

echo
echo "-----------------------------------------------------------------------"
printf 'RESULT: %d passed, %d failed\n' "$pass" "$fail"
if [ "$fail" -ne 0 ]; then
    echo "Some hooks did not behave as expected. Do NOT rely on the safety net until this is fixed."
    exit 1
fi
echo "All hooks behaved correctly. Your safety net is working."
exit 0
