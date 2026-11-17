# Two macOS accounts on one Mac

You may want to keep your personal stuff and work stuff on two macOS accounts of the same Mac, both set up with these dotfiles. Each account has its own shell, git identity, SSH keys and app data. _Homebrew and the apps in `/Applications` are installed once and shared._

The main admin account is the one that should install Homebrew, and the first one where you run `make`. Which one is personal and which is work doesn't matter.

## What's shared, what isn't

| | Shared | One per account |
|---|---|---|
| Homebrew | `/opt/homebrew` and every formula in it, owned by the main account | |
| Apps | `/Applications` (casks, App Store apps, `make apps`) | their settings and data in `~/Library` |
| mise | | the binary in `~/.local/bin`, the tools and runtimes in `~/.local/share/mise` |
| Dotfiles | | the clone, `custom/` inside it, the symlinks, `~/.gitconfig` |
| SSH keys, `gh`, `glab`, `docker login` | | all of it, in `~/.ssh` and `~/.config` |
| Docker | | all of it. Colima and the docker CLI come from mise, the VM and the images live in `~/.colima` |
| Dropbox | the app | the signed-in account and `~/Dropbox` |
| macOS settings | machine name, time zone, software update (the `sudo` lines of `make macos`) | the rest of `make macos` |

## Rules

1. Only the main account touches Homebrew. brew only works for the account that owns `/opt/homebrew`, and never as root (`sudo brew` is refused). In the second account, `make brew` and `update` skip Homebrew.
2. `brew install` and `brew upgrade` typed in the second account fail with a permission error. Use `cd /tmp && sudo -u <main-account> brew install <package>` instead.
3. Same machine name in both accounts. The wizard offers the current one, keep it.
4. One clone per account, in its own home folder. Never point the second account to the main account's clone, its `custom/` holds the main account's answers and private files.

## Set up the second account

### 1. Make it an administrator

`make` needs `sudo`, so the second account has to be an administrator.

In System Settings → Users & Groups, click ⓘ next to the account, turn on "Allow this user to administer this computer", then log out and back in. Or from the main account:

```bash
sudo dseditgroup -o edit -a <second-account> -t user admin
```

```bash
groups <second-account> # should list admin
```

### 2. Run the wizard and `make`

Log in to the second account (and to the App Store if this account installs apps) then follow the same [install steps](../README.md#one-command). Answer for this account. **Keep the same machine name the wizard offers.**

Let the wizard run `make`, or run it afterwards:

```bash
cd ~/.dotfiles && make
```

<details>
<summary>What each step of <code>make</code> does in the second account</summary>

- `homebrew` sees brew is there and does nothing.
- `brew` prints `make brew: skipped, Homebrew belongs to <main account>`.
- `link` creates the symlinks in this account's home folder.
- `mise` installs this account's tools and runtimes. Ruby builds against `libyaml` and `openssl@3` from the shared Homebrew, which works since it only reads them.
- `apps` finds the apps already in `/Applications` and skips them.
- `ohmyzsh` installs oh-my-zsh for this account.

</details>

Open a new terminal and everything is there.

### 3. Sign in again

Nothing carries over from the main account.

- Sign in to Dropbox, if this account backs up its app settings (see [Mackup](#mackup-backuprestore))
- The agent tools need their setup again too, see [agentic-tooling.md](./agentic-tooling.md#on-a-second-macos-account).
- Sign in again to other tooling if needed `gh auth login`, `glab auth login`.

### 4. `make macos`, if you want it

Most of what `make macos` sets belongs to the current account, so run it in each account. Its `sudo` lines change the whole Mac, but running them twice just sets the same values again.

## Day to day

### Add a Homebrew package

From the main account, nothing changes. Edit the `Brewfile`, then `make brew`.

From the second account, run brew as the main account:

```bash
cd /tmp && sudo -u <main-account> brew install <package>
```

`sudo` asks for the second account's password, not the main one's. The `cd /tmp` matters because brew starts in the current folder, and the main account may not be allowed to read yours.

### Update

`update` does macOS updates, then Homebrew, then mise. In the second account it skips Homebrew and runs the rest. Prefer updating Homebrew and the apps from the main account, and each account updates its own other tools.

### Edit the dotfiles

Each account has its own clone. Commit and push from one, `git pull` in the other.

### Both accounts open at once

With fast user switching, both accounts keep running. Anything that listens on a fixed port then clashes with its twin in the other account. A dev server, a database, a container publishing the same port in both VMs. Stop it in one account before you start it in the other, or disable fast user switching.

## Mackup backup/restore

Mackup copies the app settings into a folder of the Dropbox signed in to the current account. If the two accounts have different app settings, give each its own folder, `Mackup` and `Mackup-work` for example when the wizard asks for it.

## Time Machine Backups

Time Machine backs up the whole disk, both accounts included. To leave one out, see [time-machine.md](./time-machine.md#exclude-an-account).
