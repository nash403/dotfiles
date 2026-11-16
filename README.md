# .files

[![ci-macos](https://github.com/nash403/dotfiles/actions/workflows/ci-macos.yml/badge.svg)](https://github.com/nash403/dotfiles/actions/workflows/ci-macos.yml)
[![ci-ubuntu](https://github.com/nash403/dotfiles/actions/workflows/ci-ubuntu.yml/badge.svg)](https://github.com/nash403/dotfiles/actions/workflows/ci-ubuntu.yml)

> These are my dotfiles. Take anything you want, but at your own risk.

Made for macOS with zsh. Linux gets the shell setup and the command-line tools.

![](https://imgs.xkcd.com/comics/borrow_your_laptop.png)

## What's inside

- [Homebrew](https://brew.sh) for desktop apps, fonts, App Store apps and a few GNU tools ([Brewfile](./Brewfile))
- [mise](https://mise.jdx.dev) for languages and command-line tools: node, python, ruby, go, rust, gh, jq… ([config/mise/config.toml](./config/mise/config.toml))
- [oh-my-zsh](https://ohmyz.sh) with the [Spaceship](https://spaceship-prompt.sh) prompt
- [aliases](./shell/aliases.sh), [exports](./shell/exports.sh), [PATH](./shell/path.sh) and [one function per file](./shell/functions), each function [tested](./test/functions)
- a git config, a global gitignore and [sensible macOS defaults](./macos/defaults.sh)
- [Mackup](https://github.com/lra/mackup) to copy the settings of [the apps you list](./mackup/mackup.cfg) to Dropbox, and back

## Install

### Prerequisites

```bash
sudo softwareupdate -i -a
```

```bash
xcode-select --install
```

Then **sign in to the App Store app**: `make` installs App Store apps and cannot sign in for you.

### One command

```bash
curl -fsSL https://raw.githubusercontent.com/nash403/dotfiles/main/install.sh | sh
```

<details>
<summary>What the wizard asks</summary>

1. where to clone the repo (default `~/dev/dotfiles`; `~/.dotfiles` always points to it),
2. your personal and work project folders (default `~/dev` and `~/work`),
3. the Dropbox folder for the [app settings backup](#app-settings-back-up-and-restore) (default `Mackup`),
4. your git name and email,
5. the machine name,
6. whether to create an SSH key, sign your commits with it, and add it to GitHub or GitLab.

It shows a summary before changing anything, then clones, writes your answers and offers to run `make`. To try the questions without changing anything, add `DOTFILES_DRY_RUN=1` before `sh`: the wizard then only prints what it would write and run.

</details>

<details>
<summary>Install a fork or another branch</summary>

Set `DOTFILES_REPO` or `DOTFILES_BRANCH` before `sh`:

```bash
curl -fsSL https://raw.githubusercontent.com/nash403/dotfiles/main/install.sh | DOTFILES_REPO=https://github.com/you/dotfiles sh
```

```bash
curl -fsSL https://raw.githubusercontent.com/nash403/dotfiles/next/install.sh | DOTFILES_BRANCH=next sh
```

</details>

### Then, if you didn't let the wizard run `make`

The wizard's last question is "Run make now?". If you answered yes, skip this step. Otherwise, run it from the clone:

```bash
cd ~/.dotfiles && make
```

`make` installs Homebrew, links the dotfiles, installs the Brewfile (App Store apps included), the mise tools, the apps without a Homebrew cask, and oh-my-zsh.

### After `make`

Whether the wizard ran `make` or you did, open a new terminal.

## App settings: back up and restore

The dotfiles cover the shell and git. The settings of the apps (Alfred, Ghostty, Zed, Xcode, Superwhisper…) are copied to Dropbox by [Mackup](https://github.com/lra/mackup), in copy mode: no symlinks, which macOS no longer accepts for app preferences.

- [mackup/mackup.cfg](./mackup/mackup.cfg) lists the apps to back up. Add or remove a line to change it.
- [config/mackup/applications/](./config/mackup/applications/) holds our definitions: apps Mackup doesn't know, and replacements for Mackup definitions that copy credentials (docker, opencode, azure) or miss the current paths (k9s, lazydocker, mole).
- The wizard asks for the folder in Dropbox (default `Mackup`, so `~/Dropbox/Mackup`) and records it in `custom/dotfiles.env`. It never backs up or restores anything itself.

Every command needs the Dropbox app, which `make` installs: **sign in to it** first.

### Restore, if your Dropbox already holds a backup

On a new Mac, after `make`: wait until Dropbox has synced the backup folder, quit the apps listed in [mackup/mackup.cfg](./mackup/mackup.cfg) (a running app can overwrite its restored settings), then:

```bash
make mackup-restore
```

### Back up

```bash
make mackup-dry       # what would be copied
make mackup-backup    # copy the settings to Dropbox
```

Each command first writes `~/.mackup.cfg` from `mackup/mackup.cfg` and the chosen folder, so `mackup` also works on its own afterwards.

## macOS settings

Optional. [macos/defaults.sh](./macos/defaults.sh) sets Finder, Dock, keyboard, trackpad, screenshots, software update and more. Read it first: it changes a lot of settings. Then:

```bash
make macos
```

## Useful commands

| Command | When |
|---|---|
| `make` | First install, or reinstall everything |
| `make setup` | Run the wizard again (other dev folder, other git email…) |
| `make setup-dry` | Answer the wizard's questions and see what it would write and run, without changing anything |
| `make brew` / `make mise` | After editing the Brewfile / the mise config |
| `make apps` | Install the apps without a Homebrew cask (DashBeam, Scratch, Orca) |
| `make link` / `make unlink` | Recreate the symlinks / go back to the files you had before |
| `make detach` | Replace the symlinks with copies (freeze the current state) |
| `make backups` | List the `.bak` files left to sort, with the command to compare them |
| `make macos` | Apply the macOS defaults |
| `make mackup-backup` / `make mackup-restore` | Copy the app settings to Dropbox / copy them back (see below) |
| `make mackup-dry` | Show what `make mackup-backup` would copy, copying nothing |
| `make test` / `make lint` | Check before committing (`make test T=test/functions/gwtaa.bats` for one file) |
| `update` | Update macOS, Homebrew (Brewfile and custom/Brewfile) and mise. Skips Homebrew in an account that doesn't own it |

## Your private files: `custom/`

`custom/` is ignored by git. It mirrors `shell/`: `path.sh`, `exports.sh`, `aliases.sh`, `functions/`, plus a `Brewfile` and a `mise.toml` for apps and tools you don't want to publish. The wizard creates these files with a comment explaining each one. They load right after the tracked files, so they can override them. Any other `*.sh` or `*.zsh` file you put there is loaded too.

`custom/dotfiles.env` holds the wizard's answers. Don't edit it: run `make setup` again.

## When `make link` finds existing files

On a Mac that is already set up, `make link` finds files where its symlinks go. What it does depends on what is there:

| Already there | `make link` |
|---|---|
| A symlink to the same repo file | Leaves it |
| A symlink into this clone, or left by another clone of these dotfiles, or by this one before it moved | Replaces it and prints where it pointed |
| A real file | Moves it to `X.bak` |
| Any other symlink (another dotfiles repo, a tool's own link) | Moves the link itself to `X.bak`, like a real file |

`X.bak` becomes `X.bak.<date>` when `X.bak` already exists. Nothing is overwritten. To sort them:

1. `make backups` lists them, each with a `code --diff X.bak X` command.
2. The right side of that diff **is** the repo file (`~/.zshrc` is a symlink to it). Copy what you want to keep there, or into `custom/`.
3. `git diff` in the repo shows what you added. Commit what applies to every machine.
4. Delete the `.bak`.

A `.bak` that is a symlink to a file that no longer exists shows in `make backups` as an `rm` command: there is nothing to compare.

## Troubleshooting and quick reference

[docs/](./docs/index.md) covers the less common cases: SSH keys by hand, a second macOS account, Time Machine, moving the dotfiles folder, agentic tooling.

## Tests

```bash
make lint && make test
```

They need bats and shellcheck, listed in [mise.toml](./mise.toml). `make` installs them; in a clone where you didn't run `make`, run `mise install` first.

The tests use [bats-core](https://github.com/bats-core/bats-core). They run on macOS and Ubuntu on every push.

## Credits

This repo started the day I stumbled upon [Mathias Bynens'](https://github.com/mathiasbynens/dotfiles), [webpro's](https://github.com/webpro/dotfiles) and [Dennis Muensterer's](https://github.com/dnnsmnstrr/dotfiles) dotfiles and thought "I want one of those". Most of what I ~~stole~~ borrowed has been rewritten since, but the spirit is theirs.

Tools this setup relies on: [Homebrew](https://brew.sh), [mise](https://mise.jdx.dev), [oh-my-zsh](https://ohmyz.sh), [Spaceship](https://spaceship-prompt.sh), [mas](https://github.com/mas-cli/mas), [Mackup](https://github.com/lra/mackup), [bats-core](https://github.com/bats-core/bats-core).

Many thanks to the [dotfiles community](https://dotfiles.github.io).

## License

[MIT](./LICENSE) - Copyright (c) 2020-present [Honoré Nintunze](https://twitter.com/nash_403)
