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
3. the Dropbox folder for the [app settings backup](#restoring-app-settings-from-previous-mackup-backup) (default `Mackup`),
4. your git name and email,
5. the machine name,
6. whether to create an SSH key, sign your commits with it, and add it to GitHub or GitLab.

It shows a summary before changing anything, then clones, writes your answers and offers to run `make`. To try the questions without changing anything, add `DOTFILES_DRY_RUN=1` before `sh`: the wizard then only prints what it would write and run.

</details>

<details>
<summary>Install a fork or another branch</summary>

```bash
# Install from a fork of this repo set `DOTFILES_REPO`
curl -fsSL https://raw.githubusercontent.com/nash403/dotfiles/main/install.sh | DOTFILES_REPO=https://github.com/you/dotfiles sh
# Install from another branch set `DOTFILES_BRANCH`
curl -fsSL https://raw.githubusercontent.com/nash403/dotfiles/next/install.sh | DOTFILES_BRANCH=next sh
# Both
curl -fsSL https://raw.githubusercontent.com/nash403/dotfiles/main/install.sh | DOTFILES_REPO=https://github.com/you/dotfiles DOTFILES_BRANCH=next sh
```

</details>

### Then, if you didn't let the wizard run `make`

The wizard's last question is "Run make now?". If you answered yes, skip this step. Otherwise, run it from the clone:

```bash
cd ~/.dotfiles && make
```

`make` installs Homebrew, links the dotfiles, installs the Brewfile (App Store apps included), the mise tools, the apps without a Homebrew cask, and oh-my-zsh.

⚠️ After `make`, whether by you or the wizard, open a new terminal/tab session. Only then do you see the config applied.

<details>
<summary>When <code>make link</code> finds existing files</summary>

On a Mac that is already set up, here's what `make link` does when it finds files that already exist:

| Already there | `make link` |
|---|---|
| A symlink to the same repo file | Leaves it |
| A symlink into this clone, or left by another clone of these dotfiles, or by this one before it moved | Replaces it and prints where it pointed |
| A real file | Moves it to `X.bak` |
| Any other symlink leading anywhere else | Moves the link itself to `X.bak`, like a real file |

`X.bak` becomes `X.bak.<date>` when `X.bak` already exists. Nothing is overwritten. To sort them:

1. `make backups` lists them, each with a `code --diff X.bak X` command.
2. The right side of that diff **is** the repo file (`~/.zshrc` is a symlink to it). Copy what you want to keep there, or into `custom/`.
3. `git diff` in the repo shows what you added. Commit what applies to every machine.
4. Delete the `.bak`.

A `.bak` that is a symlink to a file that no longer exists shows in `make backups` as an `rm` command: there is nothing to compare.

</details>

## Restoring App settings (from previous Mackup backup)

The dotfiles cover the shell and git. I am using [Mackup](https://github.com/lra/mackup) to backup the settings of the desktop apps into my Dropbox account, in copy mode (no symlinks).

_Restore and backup commands need the Dropbox app (`make` installs it): **sign in to it** first._

- [mackup/mackup.cfg](./mackup/mackup.cfg) lists the apps to back up. Add or remove a line to change it.
- [config/mackup/applications/](./config/mackup/applications/) for apps Mackup doesn't know, and replacements for Mackup definitions that copy credentials or miss the current paths.
- The wizard asks for the folder in Dropbox (default `Mackup`, so `~/Dropbox/Mackup`) and records it in `custom/dotfiles.env`. It never backs up or restores anything itself.

Each command first writes `~/.mackup.cfg` from `mackup/mackup.cfg` and the chosen folder, so `mackup` also works on its own afterwards.

### Restore

On a new Mac, after `make`: wait until Dropbox has synced the backup folder, quit the apps listed in [mackup/mackup.cfg](./mackup/mackup.cfg) (a running app can overwrite its restored settings), then:

```bash
make mackup-restore
```

### Back up

```bash
make mackup-dry       # what would be copied
make mackup-backup    # copy the settings to Dropbox
```

## macOS system settings

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
| `make detach` | Turn each symlink into a plain copy of its repo file: later edits in the repo no longer reach your home folder. Note: `~/.zshrc` still loads `~/.dotfiles/shell/init.zsh` |
| `make backups` | List the `.bak` files left to sort, with the command to compare them |
| `make macos` | Apply the macOS defaults |
| `make mackup-backup` / `make mackup-restore` | Copy the app settings to Dropbox / copy them back (see below) |
| `make mackup-dry` | Show what `make mackup-backup` would copy, copying nothing |
| `make test` / `make lint` | Check this repo (`make test T=test/functions/gwtaa.bats` for one file) |
| `update` function | Update macOS, Homebrew and mise. |

## Private config in `custom/`

`custom/` is ignored by git. It mirrors `shell/`: `path.sh`, `exports.sh`, `aliases.sh`, `functions/`, plus a `Brewfile` and a `mise.toml` for apps and tools you don't want to publish. They load right after the tracked files, so they can override them. Any other `*.sh` or `*.zsh` file you put there is loaded too.

`custom/dotfiles.env` holds the wizard's answers. Don't edit it: run `make setup` again instead.

## Troubleshooting and quick reference

[docs/](./docs/README.md) covers the less common cases: SSH keys, a second macOS account, Time Machine, moving the dotfiles folder after setup (which can break symlinks), agentic tooling.

## Tests

```bash
make lint && make test
```

Requires [bats-core](https://github.com/bats-core/bats-core) and shellcheck (`make` installs them via mise).

They run in GitHub Actions CI on macOS and Ubuntu on every push.

## Credits

This repo started the day I stumbled upon [Mathias Bynens'](https://github.com/mathiasbynens/dotfiles), [webpro's](https://github.com/webpro/dotfiles) and [Dennis Muensterer's](https://github.com/dnnsmnstrr/dotfiles) dotfiles and thought "I want one of those". Most of what I ~~stole~~ borrowed has been rewritten since, but the spirit is theirs.

Tools this setup relies on: [Homebrew](https://brew.sh), [mise](https://mise.jdx.dev), [oh-my-zsh](https://ohmyz.sh), [Spaceship](https://spaceship-prompt.sh), [mas](https://github.com/mas-cli/mas), [Mackup](https://github.com/lra/mackup), [bats-core](https://github.com/bats-core/bats-core).

Many thanks to the [dotfiles community](https://dotfiles.github.io).

## License

[MIT](./LICENSE) - Copyright (c) 2020-present [Honoré Nintunze](https://twitter.com/nash_403)
