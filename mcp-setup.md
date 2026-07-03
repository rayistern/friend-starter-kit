# Optional add-ons: MCP servers

**MCP** ("Model Context Protocol") is a standard way to give Claude Code extra
abilities by connecting it to small helper programs called *MCP servers*. Each
server adds a set of tools — for example, the ability to search the web, or to
drive a real web browser.

This file lists a couple of genuinely useful, portable ones you can add safely.
None of these are required. Add them only if you want the capability.

> **The general command** to add an MCP server to Claude Code is `claude mcp add`.
> If a command below doesn't match what you see, check the current docs:
> https://docs.claude.com/en/docs/claude-code/mcp

---

## 1. Browser automation — Playwright (recommended, no account needed)

Lets Claude Code open and control a real web browser: navigate to pages, click
buttons, fill forms, take screenshots. Useful for testing web apps you build, or
having the assistant check how a page actually behaves. It needs no login.

```bash
claude mcp add playwright -- npx -y @playwright/mcp@latest
```

The first time it runs it may download a browser engine, which can take a minute.

---

## 2. Web search (recommended)

Lets Claude Code look things up on the web for current information instead of
relying only on what it already knows.

Claude Code includes a built-in web search/fetch capability in recent versions —
try simply asking the assistant to "search the web for ..." first; it may already
be able to do it with no setup.

If you want a dedicated search MCP server, several exist. Many require a free API
key from the search provider (you sign up, they give you a key, you paste it into
the `claude mcp add` command as an environment variable). Because the exact
provider and signup steps change over time, pick one from the current Claude Code
MCP documentation rather than hard-coding a stale command here:

- MCP directory / docs: https://docs.claude.com/en/docs/claude-code/mcp

The pattern looks like this (example shape — replace with your chosen provider
and your own key):

```bash
claude mcp add web-search --env SOME_API_KEY=your_key_here -- npx -y the-search-mcp-package
```

---

## Account-bound servers (optional, and they need YOUR OWN login)

There are MCP servers for services like **Gmail, Google Calendar, Slack,
Notion, Figma**, and so on. These are powerful but they connect to *your*
personal accounts, so:

- You must authenticate them with **your own** credentials/login. Never paste
  someone else's keys or tokens.
- Only add the ones you actually use, and review what permissions you're granting.
- Treat the access seriously: a calendar or email server can read and change real
  data in your account.

Setup for each of these is specific to the service. When you want one, find the
official server and follow its own setup instructions, and authenticate as
yourself.

---

## Managing MCP servers

```bash
claude mcp list             # see what's installed
claude mcp remove <name>    # remove one you no longer want
```

Start with just **Playwright** (and the built-in web search). Add more only when
you have a concrete need — fewer moving parts means fewer things to go wrong while
you're getting comfortable.
