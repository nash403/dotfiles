# Agentic tooling

The agents themselves come from mise (`claude`, `opencode` in [config/mise/config.toml](../config/mise/config.toml)). This page covers what I add on top to make them spend fewer tokens. `make` installs the binaries, but each tool also needs a one-time setup per agent, which I do by hand.

## rtk

[rtk](https://github.com/rtk-ai/rtk) sits between the agent and the shell. When the agent runs `git status`, `ls` or a test command, rtk compresses the output before the agent reads it.

`make brew` installs it from the Brewfile. Then hook it into each agent once:

```bash
rtk init -g          # Claude Code
```

```bash
rtk init -g --opencode
```

Restart the agent afterwards. Other agents (Codex, Cursor, Gemini…) have their own flag, listed in the rtk README.

Check it's the right rtk, there's an unrelated one on crates.io:

```bash
rtk gain
```

It prints a dashboard of the tokens saved so far. "command not found" means you have the other one.

I use two Claude Code configs (`claude-perso` and `claude-work` in [shell/aliases.sh](../shell/aliases.sh)). `rtk init -g` sets up `~/.claude`, so check the hook landed in each config folder you use.

## TokenEconomizer

[TokenEconomizer](https://github.com/microsoft/TokenEconomizer) is a Claude Code plugin. It learns from your past sessions in a repo and then keeps facts about the repo, hides the tools you never use there, and stops turns stuck retrying the same failure. What it learns stays in `~/.tokeneconomizer`.

It needs Python 3.10+, which mise provides.

Claude Code runs the plugin from its clone, so the clone stays where you put it. I keep it out of my project folders:

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

- Its README lists the Claude Code versions it supports. mise installs the latest Claude Code, which can be newer than that range. Check with `claude --version` before you blame the plugin.
- Tool pruning writes to `.claude/settings.local.json` in each repo and adds that file to `.git/info/exclude`, so it never shows up in git. `/tokeneconomizer:toolprune restore` removes its entries.
- Codex is supported too, see its README.

## On a second macOS account

rtk is shared (it's in `/opt/homebrew`), but its hooks live in each account's agent config: run `rtk init -g` again there. TokenEconomizer needs its own clone and install in each account. See [multiple-accounts.md](./multiple-accounts.md).
