# Agentic tooling

This page covers what I add on top of my agents to make them more efficient.

## rtk

[rtk](https://github.com/rtk-ai/rtk) (installed by `make`) sits between the agent and the shell. When the agent runs `git status`, `ls` or a test command, rtk compresses the output before the agent reads it.

Hook it into each agent once:

```bash
rtk init -g          # Claude Code
```

```bash
rtk init -g --opencode
```

Restart the agent afterwards. Other agents (Codex, Cursor, Gemini…) have their own flag, listed in the [rtk README](https://github.com/rtk-ai/rtk).

```bash
rtk gain # prints a dashboard of the tokens saved so far
```

`rtk init -g` sets up `~/.claude`, so if you are using `claude-perso` and `claude-work` from [shell/aliases.sh](../shell/aliases.sh), please check the hook landed in each config folder.

## TokenEconomizer

[TokenEconomizer](https://github.com/microsoft/TokenEconomizer) learns from your past sessions in a repo and then keeps facts about the repo, hides the tools you never use there, and stops turns stuck retrying the same failure. What it learns stays in `~/.tokeneconomizer`.

It needs Python 3.10+.

```bash
git clone https://github.com/microsoft/TokenEconomizer.git ~/.local/share/TokenEconomizer
```

```bash
claude plugin marketplace add ~/.local/share/TokenEconomizer
```

```bash
claude plugin install tokeneconomizer@tokeneconomizer
```

Then, in Claude Code, inside one of your repos:

1. `/tokeneconomizer:status`, and allow its script if it asks.
2. `/tokeneconomizer:toolprune refresh-catalog`. Run it again after each Claude Code update.

Update it with `git pull` in the clone.

A few things to know:

- Its [README](https://github.com/microsoft/TokenEconomizer) lists the Claude Code versions it supports. Your Claude Code can be newer than that range.
- Tool pruning writes to `.claude/settings.local.json` in each repo and adds that file to `.git/info/exclude`, so it never shows up in git. `/tokeneconomizer:toolprune restore` removes its entries.

## On a second macOS account

- rtk is shared (it's in `/opt/homebrew`), but its hooks live in each account's agent config: run `rtk init -g` again there.
- TokenEconomizer needs its own clone and install in each account.

See [multiple-accounts.md](./multiple-accounts.md).
