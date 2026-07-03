# ROADMAP.md — what's next for this kit

The kit is usable today (see README). This file tracks known gaps and
nice-to-haves, split by how much they matter for actually handing the kit to
someone. Written 2026-07-03 after a full coherence + viability pass in which
all four hooks were tested against simulated Claude Code hook input (all
passed; one bug in `sensitive-files-block.sh` — `.env.example` was blocked
despite the hook's own docs saying it shouldn't be — was found and fixed).

---

## Near-term — before sharing widely

- [ ] **Add a `test-hooks.sh` self-test script.** Today the README's
      verification step is "ask Claude to run a dangerous command and see it
      refused" (Step 5). A small script that pipes simulated hook JSON through
      each of the four hooks and prints PASS/FAIL would verify the install in
      one command, without depending on the assistant's phrasing. The test
      cases used in the 2026-07-03 review are a ready-made starting point.
- [ ] **Add a one-command installer (`install.sh`).** Step 4's four copy
      commands are simple, but a single `./install.sh` that creates
      `~/.claude/hooks/`, copies files, sets execute bits, and *refuses to
      overwrite an existing `settings.json` without asking* (the README now
      warns about this, but a script can enforce it) would remove the last
      real copy/paste friction for a non-expert.
- [ ] **Decide on a LICENSE.** The repo is private for now, so this isn't
      urgent — but before it's shared beyond personal friends (or made
      public), pick a license (MIT is the obvious candidate for a starter
      kit) so recipients know they can reuse and modify it.
- [ ] **Generalize or gate the BMAD section.** The README currently assumes
      the reader "already uses BMAD-METHOD" — true for the original intended
      friend, not for everyone. If the audience widens, reframe that section
      as "if you use BMAD..." with a short pointer for people who don't.

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
