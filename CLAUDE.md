# CLAUDE.md — Global working instructions

This file holds standing instructions that Claude Code reads at the start of
every session. Copy it to `~/.claude/CLAUDE.md` to make it apply everywhere, or
drop a copy into a specific project folder to apply it just to that project.
A project-level `CLAUDE.md` wins over this global one where they disagree.

These are sensible, general-purpose defaults. Edit them to taste as you learn
what you like — there is nothing project-specific or secret here.

---

## How to talk to me

- Use plain language. Spell out what things are on first mention; avoid
  unexplained jargon and acronyms. If a sentence would confuse someone who just
  walked into the conversation, rewrite it.
- It is fine to be thorough. Clear and complete beats short and cryptic.
- When you are unsure what I want, ask one focused question rather than guessing
  and doing a lot of work in the wrong direction.

---

## Decision-making

1. **No quick fixes that create hidden problems.** Avoid silencing errors,
   stubbing things out, or working around the design just to make something pass.
   Prefer a clean solution even if it takes a little more work, and explain the
   reasoning behind any non-obvious choice.
2. **Explain before big changes.** For anything substantial (touching many files,
   changing how something fundamentally works), outline your plan and the
   trade-offs first, then carry it out.
3. **Follow the patterns already in the code.** Read the surrounding style and
   structure before adding new code. Extend what's there rather than inventing a
   parallel way of doing the same thing.

---

## Working in steps

- Break larger work into clear phases. Don't try to do a sweeping multi-file
  change in one giant leap — do a piece, check it, then continue.
- After 10+ messages in a conversation, re-read a file before editing it. Long
  conversations get summarized automatically, and that can blur your memory of a
  file's exact current contents.

---

## Commit and version-control habits

- **Commit frequently.** Make a commit after each logical, working change. Write
  messages that capture *why* the change was made, not just *what* changed.
- **Work on feature branches; merge through pull requests.** Do day-to-day work
  on a branch (for example `feature/add-login`), then merge into `main` via a
  pull request rather than pushing straight to `main`. (A safety hook in this kit
  warns you when a push targets `main`.)
- A reasonable branch naming habit: `feature/<short-description>` for new work,
  `fix/<short-description>` for bug fixes.

---

## Don't break existing things by default

Treat changes as **backward-compatible by default**. Adding new options,
commands, or fields with sensible defaults is fine to do freely. Removing or
renaming something that existing code, data, or users depend on — or changing
what an existing thing means — is a "breaking change": pause and confirm with me
before doing it.

---

## Quality before declaring done

- **Verify your work.** A tool reporting "success" does not mean the code is
  correct. Before calling a task complete, run the project's type-checker, tests,
  and/or linter (whatever the project uses) and fix every error you introduced.
  If the project has no such checks configured, say so plainly instead of
  implying everything passed.
- **Edit carefully.** If a conversation has gotten long, re-read a file right
  before editing it so your change applies to its real current state.

---

## Preserve history — annotate, don't quietly overwrite

When a decision or a documented fact changes, prefer adding a short dated note
("Update YYYY-MM-DD: ...") next to the old text rather than silently deleting the
old text. Future-you benefits from seeing how the thinking evolved, not just the
latest state. (Deleting content outright is a judgment call — when in doubt, ask.)

---

## Comments and documentation

Default to clear, useful inline comments and docstrings. For each function or
non-obvious piece of code, briefly explain **why** it works the way it does —
the trade-offs considered, the assumptions made, and (for bug fixes) what the
bug was and why this fixes it. Well-named variables already say *what* the code
does; comments should add the *why* that the code can't express on its own.
Avoid comments that will rot, like references to "the current task."
