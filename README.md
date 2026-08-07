# Claude Code Starter Kit

A small, safe starter setup for using **Claude Code** — Anthropic's command-line
coding assistant — when you're newer to it. It gives you:

- Sensible default instructions for the assistant (`CLAUDE.md`)
- A safe settings file with permission prompts left **on** (`settings.json`)
- A few **safety hooks** that block the most dangerous commands and warn you
  about risky ones (`hooks/`)
- Guides for adding optional extras (`mcp-setup.md`)

It is designed to "just work" with as little fuss as possible, while keeping
training wheels on so the assistant can't quietly do something destructive.

> **Plain-English note on jargon:** a *hook* is just a small script that Claude
> Code runs automatically at certain moments (for example, right before it runs
> a shell command). We use hooks here as a safety net.

---

## What's in this kit

```
friend-starter-kit/
├── README.md          ← you are here
├── CLAUDE.md          ← default instructions for the assistant
├── settings.json      ← Claude Code configuration (safe defaults)
├── install.sh         ← one-command installer (copies everything into ~/.claude/)
├── test-hooks.sh      ← self-test that verifies the safety hooks work
├── mcp-setup.md       ← optional add-ons (web search, browser automation)
├── DECISIONS.md       ← why this kit includes/excludes what it does
├── ROADMAP.md         ← known gaps and planned improvements
├── LICENSE            ← MIT license (free to use, modify, and share)
└── hooks/             ← the safety scripts
    ├── dangerous-bash-block.sh    (BLOCKS things like rm -rf, git push --force)
    ├── sensitive-files-block.sh   (BLOCKS edits to secret files like .env)
    ├── push-to-main-warn.sh       (WARNS when pushing to the main branch)
    └── claudemd-warn.sh           (WARNS when editing a CLAUDE.md file)
```

---

## Important: Windows users should use WSL2

**The safety hooks in this kit are bash scripts (`.sh` files). Native Windows
cannot run them.** If you install Claude Code straight onto Windows, the hooks
simply won't fire, and you'd lose the safety net this kit is built around.

The clean fix is **WSL2** (Windows Subsystem for Linux) — an official Microsoft
feature that runs a real Linux environment inside Windows. It's free, it's a
one-command install, and Claude Code plus these bash hooks run perfectly inside
it. This is the **recommended path** for this kit.

### Install WSL2 (one time, ~10 minutes)

1. Open **PowerShell as Administrator** (click Start, type "PowerShell",
   right-click it, choose "Run as administrator").
2. Run:
   ```powershell
   wsl --install
   ```
   This installs WSL2 and Ubuntu (a popular Linux flavor) by default.
3. **Restart your computer** when it asks.
4. After restart, an Ubuntu window opens and asks you to create a Linux
   username and password. Pick something simple and remember it — you'll type
   that password occasionally for admin actions.
5. From now on, do all the steps below **inside the Ubuntu (WSL2) terminal**,
   not in regular Windows PowerShell.

> Microsoft's official guide, if you want pictures:
> https://learn.microsoft.com/windows/wsl/install

> **Where your files live:** inside WSL2, your home folder is `~` (for example
> `/home/yourname`). Keep your code projects there. You *can* reach Windows
> files under `/mnt/c/...`, but keeping projects inside the Linux home folder is
> faster and avoids permission headaches.

### "I really don't want WSL2" — the no-hooks minimal fallback

You can use Claude Code on native Windows without WSL2 — you just won't get the
bash safety hooks. If you go this route:

1. Install Claude Code on Windows (see the Anthropic docs link below).
2. Copy **`CLAUDE.md`** to your Windows home folder's `.claude` directory and
   copy **`settings.json`** there too, **but first delete the entire `"hooks"`
   block** from `settings.json` (the hook scripts won't run on native Windows,
   and leaving broken hook paths in causes errors).
3. Skip the `hooks/` folder entirely.

You'll still get the safe defaults (permission prompts on, good `CLAUDE.md`
instructions) — just without the extra command-blocking safety net. For that
reason, WSL2 is strongly preferred. If you start on native Windows and later
install WSL2, you can add the hooks back then.

---

## Step-by-step setup (recommended WSL2 path)

Do all of this **inside your Ubuntu / WSL2 terminal.**

> **Already on macOS or Linux?** Skip the WSL2 section entirely — everything
> below works in your normal terminal. On macOS, replace the `sudo apt-get
> install ...` commands with Homebrew (`brew install git jq node gh`); the rest
> is identical.

### 1. Install the basics: Node.js, git, and jq

Claude Code needs Node.js. The hooks need `git` and `jq` (a tiny tool for
reading JSON). Install all three:

```bash
# Update the package list first
sudo apt-get update

# git (version control) and jq (used by the safety hooks)
sudo apt-get install -y git jq

# Node.js (needed by Claude Code and by BMAD). This installs Node 20.
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
```

Check they worked:

```bash
node --version    # should print something like v20.x
git --version     # should print a git version
jq --version      # should print a jq version
```

### 2. Install Claude Code

Follow Anthropic's official installation instructions (the exact command can
change over time, so use their page as the source of truth):

- **Claude Code docs:** https://docs.claude.com/en/docs/claude-code

After installing, run `claude` in a terminal once to log in with your Anthropic
account and confirm it starts.

### 3. Create a GitHub account and set up git (if you don't have one yet)

GitHub is where your code lives online, so you can back it up and share it.

**a. Make a free GitHub account:** go to https://github.com and sign up. Pick a
username you're happy to be public, and use an email you can access.

**b. Tell git who you are** (this labels your commits — do it once):

```bash
git config --global user.name "Your Name"
git config --global user.email "the-email-you-used@example.com"
```

**c. Connect git to GitHub the easy way — GitHub CLI.** The `gh` tool handles
login and authentication for you, so you don't have to fuss with SSH keys:

```bash
# Install the GitHub CLI
sudo apt-get install -y gh

# Log in — this walks you through it in the terminal/browser
gh auth login
```

When `gh auth login` asks:
- Choose **GitHub.com**
- Choose **HTTPS** for the protocol
- When it asks "Authenticate Git with your GitHub credentials?", say **Yes**
- Choose **Login with a web browser**, then copy the one-time code it shows and
  paste it into the browser page it opens.

That's it — git can now push to and pull from your GitHub account.

> **Quick test** (optional): `gh repo create my-first-repo --private --clone`
> creates a private repository and downloads it. You can delete it later with
> `gh repo delete my-first-repo`.

### 4. Install this starter kit's files

**The easy way — one command.** From inside the folder where you put this kit:

```bash
./install.sh
```

That copies `CLAUDE.md`, `settings.json`, and the safety hooks into
`~/.claude/` and makes the hooks executable. It will **not** overwrite an
existing `~/.claude/settings.json` or `CLAUDE.md` — if you've customized Claude
Code before, it skips those and tells you to merge by hand (or you can re-run
`./install.sh --force` to replace them, which backs up the old ones first).

<details>
<summary><b>Prefer to do it by hand?</b> (click to expand the manual steps)</summary>

```bash
# Make the Claude Code config folder if it doesn't exist
mkdir -p ~/.claude/hooks

# Copy the global instructions and settings
cp CLAUDE.md       ~/.claude/CLAUDE.md
cp settings.json   ~/.claude/settings.json

# Copy the safety hooks and make them runnable
cp hooks/*.sh      ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh
```

If you already have a `~/.claude/settings.json` you care about, don't blindly
overwrite it — open both files and add this kit's `"hooks"` block to your
existing one instead.
</details>

The `settings.json` already points at `$HOME/.claude/hooks/...`, so the hooks
are found automatically once they're in `~/.claude/hooks/`.

### 5. Check that the hooks are active

**The quick check — one command.** From the kit folder:

```bash
./test-hooks.sh
```

This feeds each of the four hooks the same kind of input Claude Code sends them
(safe commands and dangerous ones) and prints `PASS`/`FAIL` for each, ending in
an overall result. Everything should pass. (It needs `jq`, same as the hooks.)

**The live check.** Start Claude Code (`claude`) in any folder and ask it to run
a deliberately dangerous command, for example: *"run `rm -rf /tmp/does-not-exist`"*.
The `dangerous-bash-block.sh` hook should refuse it with a clear message. If it
does, your safety net is working end-to-end inside a real session.

---

## Optional: how BMAD fits in (skip this if you don't use BMAD)

This kit is deliberately **planning-layer agnostic**. Its only job is to make
Claude Code itself safe and well-configured — it does **not** bundle any
planning or "agent orchestration" system. How you plan and build is up to you.

If you use **BMAD-METHOD** (the "Breakthrough Method for Agile AI-Driven
Development") — a framework that gives the AI a structured way to plan and build,
walking through roles like analyst, product manager, architect, and developer so
a project goes from idea to working code in organized steps — it layers cleanly
on top of this kit. The kit's `CLAUDE.md` habits and the safety hooks apply to
every Claude Code session, including the ones where you run BMAD, without getting
in its way.

BMAD installs *per project*, with its own installer. Inside a project folder:

```bash
npx bmad-method install
```

Follow the prompts. When it asks which tool you're using, pick **Claude Code**.
(For the exact current steps and options, use BMAD's own docs — they are the
source of truth and stay up to date.)

- **BMAD install guide:** https://docs.bmad-method.org/how-to/install-bmad/
- **BMAD on GitHub:** https://github.com/bmad-code-org/BMAD-METHOD

**Don't use BMAD?** That's completely fine — nothing in this kit depends on it.
Skip this section; the safe defaults and hooks work on their own, and you can
plan your projects however you like (including just talking to Claude directly).

---

## Optional related tools

These are **not** part of the kit and you don't need any of them — just pointers
in case they're useful as you grow into Claude Code:

- **[claude-usage-swap (`cus`)](https://github.com/rayistern/claude-usage-swap)** —
  if you ever run **more than one** Claude account (for example, to spread heavy
  usage across accounts), `cus` swaps the active account for you and shows usage
  in your status line. Not needed for a single account — skip it unless and until
  you're in that situation. Open source.

More may be added here over time as they're released.

---

## What to do first — hands-off checklist

Work down this list once. After that, day-to-day you just open a terminal, go to
your project, and run `claude`.

- [ ] Install **WSL2** (`wsl --install` in PowerShell as Admin, then restart).
- [ ] In the Ubuntu terminal, install **Node.js, git, and jq** (Step 1 above).
- [ ] Install **Claude Code** and log in (Step 2).
- [ ] Create a **GitHub account**, set your git name/email, and run
      `gh auth login` (Step 3).
- [ ] Run **`./install.sh`** to copy CLAUDE.md, settings.json, and the hooks into
      `~/.claude/` (Step 4).
- [ ] Run **`./test-hooks.sh`** to confirm the safety hooks work (Step 5).
- [ ] (Optional) Add MCP add-ons like web search — see `mcp-setup.md`.
- [ ] (Optional) If you use BMAD, run `npx bmad-method install` in your first
      project folder. If you don't, just `cd` into a project and run `claude`.

If anything in here doesn't match what you see on screen, trust the official docs
linked above — tools update over time, and those pages stay current.

---

## Sources

- [Claude Code documentation](https://docs.claude.com/en/docs/claude-code)
- [Install WSL (Microsoft)](https://learn.microsoft.com/windows/wsl/install)
- [How to Install BMAD](https://docs.bmad-method.org/how-to/install-bmad/)
- [BMAD-METHOD on GitHub](https://github.com/bmad-code-org/BMAD-METHOD)

---

## License

Released under the **MIT License** — see [LICENSE](LICENSE). You're free to use,
modify, and share this kit. It's provided as-is, with no warranty.

Suggestions and fixes are welcome: open an issue or a pull request.
