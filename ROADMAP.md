# ROADMAP.md — what's next for this kit

The kit is usable today (see README). This file tracks known gaps and
nice-to-haves, split by how much they matter for actually handing the kit to
someone. Written 2026-07-03 after a full coherence + viability pass in which
all four hooks were tested against simulated Claude Code hook input (all
passed; one bug in `sensitive-files-block.sh` — `.env.example` was blocked
despite the hook's own docs saying it shouldn't be — was found and fixed).

---

## Near-term — before sharing widely

> **Update 2026-08-07: all four near-term items DONE** in the public-OSS prep
> pass (kit is being prepared to go public). Details noted under each item.

- [x] **Add a `test-hooks.sh` self-test script.** ✅ Done 2026-08-07. `test-hooks.sh`
      feeds each of the four hooks the two payload shapes Claude Code sends
      (`Bash` command / file-write) across ~28 cases — destructive commands and
      secret-file writes that must block, plus safe inputs (incl. the
      `.env.example` bugfix case) that must pass — and prints PASS/FAIL with an
      overall exit code. Wired into README Step 5.
- [x] **Add a one-command installer (`install.sh`).** ✅ Done 2026-08-07. Copies
      CLAUDE.md/settings.json/hooks into `~/.claude/`, sets execute bits, and
      **refuses to overwrite an existing `settings.json` or `CLAUDE.md`** unless
      `--force` (which backs up the old file first). Warns if `jq` is missing.
      Now the primary path in README Step 4 (manual steps kept in a `<details>`).
- [x] **Decide on a LICENSE.** ✅ Done 2026-08-07. **MIT**, © 2026 Rayi Stern.
      `LICENSE` added; referenced from a new README "License" section.
- [x] **Generalize or gate the BMAD section.** ✅ Done 2026-08-07. Retitled
      "Optional: how BMAD fits in (skip this if you don't use BMAD)", reframed as
      "the kit is planning-layer agnostic; *if* you use BMAD, here's how it
      layers on; if you don't, skip it." The hands-off checklist's BMAD step is
      now marked optional.

## Later — nice-to-haves

- [ ] **PowerShell port of the four hooks** for people who stay on native
      Windows and refuse WSL2. Documented as out-of-scope in DECISIONS.md;
      revisit only if a real recipient actually hits this.
- [ ] **Re-verify `settings.json` against current Claude Code releases
      periodically.** Two mild aging risks, both harmless today:
      (1) the self-documenting `_comment_*` keys rely on Claude Code ignoring
      unknown keys — if a future version validates settings strictly, move
      the explanations into the README instead; (2) the hook matcher lists
      `MultiEdit`, a tool newer Claude Code versions have folded into `Edit` —
      a stale matcher entry never fires and hurts nothing, but can be pruned
      on the next touch.
- [ ] **Bump the pinned Node.js major** (currently the NodeSource Node 20
      script in README Step 1) when Node 20 approaches end-of-life; the
      DECISIONS.md "things worth a human review" section already flags
      install-command drift generally.
- [ ] **Optional: a short "first session" walkthrough** — a 10-minute guided
      exercise ("make a folder, run `claude`, ask it to build a tiny page,
      commit it") so a first-timer experiences the commit/branch habits from
      CLAUDE.md instead of just reading about them.

## Explicitly out of scope (see DECISIONS.md for reasoning)

Account-swapping tooling, response validators, multi-repo documentation
machinery, orchestration systems beyond BMAD, and account-bound MCP servers.
These were deliberately excluded, not forgotten.
