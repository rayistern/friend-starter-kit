# DECISIONS.md — what this kit includes, what it excludes, and why

This kit was built by studying an experienced user's Claude Code setup and
keeping only the parts that are genuinely portable and useful for a newer user
on Windows who already uses BMAD. This log records the judgment calls so they can
be reviewed, and so the kit doesn't look arbitrary.

_Date written: 2026-06-29_

---

## Design constraints this kit was built for

- User is on **Windows**, new to git/GitHub, and wants a "should just work" setup.
- User already uses **BMAD-METHOD** — so BMAD is the single planning/orchestration
  layer. The kit adds no competing orchestration system.
- Goal: safe, minimal, well-documented. Training wheels on.

---

## INCLUDED, and why

| Item | Why it's here |
|------|---------------|
| `README.md` with a **WSL2-first Windows path** | The safety hooks are bash `.sh` scripts that native Windows can't run. WSL2 is the clean way to get a real Linux shell on Windows so the hooks (and Claude Code) work properly. A "no-hooks minimal" fallback is documented for anyone who refuses WSL2. |
| From-scratch **GitHub + git + auth** instructions | User has no GitHub account or git yet. Used `gh auth login` (GitHub CLI) instead of manual SSH keys because it's by far the gentlest first-time path. |
| `CLAUDE.md` with general working habits | Harvested only the portable behavioral rules: plain communication, decision-making discipline, commit-frequently, feature-branch + pull-request workflow, backward-compatibility-by-default, verify-before-done, edit-safety, preserve-history, and a clear inline-comment standard. These read like sensible defaults any developer would want. |
| `settings.json` with **permission prompts ON** | Deliberate safety choice for a newer user (see EXCLUDED). Also keeps the auto-updater on, enables 1-hour prompt caching, dark theme, auto-compaction, and a 1-year history retention — all harmless sensible defaults. |
| Four safety **hooks** | `dangerous-bash-block` (blocks `rm -rf`, `git push --force`, `git reset --hard`, `DROP TABLE`, etc.), `sensitive-files-block` (blocks writes to `.env` / credential / key files), `push-to-main-warn` (warns on pushes to `main`), `claudemd-warn` (warns when editing a `CLAUDE.md`). These are the universally-useful safety nets, with no dependency on any personal setup. |
| `mcp-setup.md` covering **Playwright + web search** | Two genuinely portable, broadly-useful add-ons. Playwright needs no account. Account-bound servers (Gmail/Jira/etc.) are mentioned only as "optional, use your own login." |
| `install.sh` + `test-hooks.sh` (added 2026-08-07) | Public-OSS prep. `install.sh` removes the last copy/paste friction and refuses to clobber an existing `settings.json`/`CLAUDE.md`; `test-hooks.sh` lets anyone verify the safety net deterministically in one command, without a live session. |
| `LICENSE` (MIT, added 2026-08-07) | So public recipients know they can reuse/modify the kit. MIT is the conventional choice for a permissive starter kit; © Rayi Stern. |

_Update 2026-08-07: this kit was prepared to be published as public open source
(previously private). Changes in that pass: added MIT LICENSE, added `install.sh`
and `test-hooks.sh`, and generalized the README's BMAD section from "you already
use BMAD" to "optional — skip if you don't." No behavior of the hooks or settings
changed. See ROADMAP.md for the item-by-item log._

---

## EXCLUDED, and why

| Item left out | Why |
|---------------|-----|
| **Account-swapping tooling** (a system the source setup used to rotate between multiple Claude accounts) and all of its hooks | The friend has a single account; this adds complexity and risk with zero benefit. |
| `skipDangerousModePermissionPrompt` / `skipAutoPermissionPrompt` | The source setup turned permission prompts **off** for speed. For a newer user that removes the single most important safety layer, so these were **flipped back on** (i.e. left out, which means prompts stay on). |
| **Validator-on-every-response** (an extra AI call after each answer) | Adds cost and latency and is tuned to the original user's habits. Not appropriate for a simple starter setup. |
| **Reconciliation / staging-file / "frozen-CLAUDE.md" machinery** | These enforce a multi-repo documentation discipline specific to the source user's workflow. Irrelevant and confusing for a single newer user. The kit's `CLAUDE.md` is meant to be freely edited. |
| **Orchestration / methodology / research tooling and their plugins/MCP servers** | The friend's one orchestration layer is BMAD. Importing another planning system would directly conflict with that constraint. |
| **Account-bound MCP servers** from the source setup (email, calendar, issue trackers, and domain-specific knowledge servers) | All tied to the original user's personal accounts and subject matter. Replaced with neutral guidance: add your own, authenticate as yourself. |
| **Any hardcoded personal file paths** | All hook paths in `settings.json` use `$HOME` so they resolve to the friend's own home folder. The hooks themselves contain no absolute user paths and no references to anyone's specific projects or conventions. |
| **The source user's personal memory/notes files** | Personal context with no value to the friend. |

---

## Things worth a human review

- **Exact install commands drift over time.** The README points to official docs
  (Claude Code, WSL, BMAD) as the source of truth for anything that might change.
  The Node.js install uses the NodeSource setup script pinned to Node 20 — fine
  today; bump the version if needed later.
- **Web search MCP** intentionally isn't pinned to a specific provider, because
  the built-in web search may already cover the need and third-party providers /
  keys change. The README/`mcp-setup.md` send the user to the live MCP docs.
- **`settings.json` uses `_comment_*` keys** to document itself, since JSON has no
  real comments. Claude Code ignores unknown keys, so this is safe; the comment
  keys were deliberately kept *out* of the `env` block (keys there would become
  real environment variables).
- **Native-Windows fallback** loses the hooks entirely. If the friend ends up on
  native Windows long-term and wants safety hooks, that would need a PowerShell
  port of the four scripts — out of scope for this kit, noted here in case it
  comes up.
