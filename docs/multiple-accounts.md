# Two macOS accounts on one Mac

I keep my personal stuff and my work on two macOS accounts of the same Mac, both set up with these dotfiles. Each account has its own shell, git identity, SSH keys and app data. Homebrew and the apps in `/Applications` are installed once and shared.

Below, the main account is the one that installed Homebrew, so the first one where you ran `make`. The second account is the other one. Which one is personal and which is work doesn't matter.

## What's shared, what isn't

| | Shared | One per account |
|---|---|---|
| Homebrew | `/opt/homebrew` and every formula in it, owned by the main account | |
| Apps | `/Applications` (casks, App Store apps, `make apps`) | their settings and data in `~/Library` |
| mise | | the binary in `~/.local/bin`, the tools and runtimes in `~/.local/share/mise` |
| Dotfiles | | the clone, `custom/`, the symlinks, `~/.gitconfig` |
| SSH keys, `gh`, `glab`, `docker login` | | all of it, in `~/.ssh` and `~/.config` |
| Docker | | all of it. Colima and the docker CLI come from mise, the VM and the images live in `~/.colima` |
| Dropbox | the app | the signed-in account and `~/Dropbox` |
| macOS settings | machine name, time zone, software update (the `sudo` lines of `make macos`) | the rest of `make macos` |

So the second account installs nothing in `/opt/homebrew` or `/Applications`. It links its own dotfiles and downloads its own mise tools, which costs some disk space and nothing else.

## Rules

1. Only the main account touches Homebrew. brew only works for the account that owns `/opt/homebrew`, and never as root, so no `sudo brew`. In the second account, `make brew` and `update` skip Homebrew and say why.
2. `brew install` and `brew upgrade` typed in the second account fail with a permission error. Use [the `sudo -u` trick](#add-a-homebrew-package) instead.
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

Log in to the second account and run the [install command](../README.md#one-command). Answer for this account. Its own clone folder, its project folders, its git name and email, a new SSH key. Keep the machine name the wizard offers.

Let the wizard run `make`, or run it afterwards:

```bash
cd ~/.dotfiles && make
```

Here's what each step does in the second account:

- `homebrew` sees brew is there and does nothing.
- `brew` prints `make brew: skipped, Homebrew belongs to <main account>`.
- `link` creates the symlinks in this account's home folder.
- `mise` installs this account's tools and runtimes. Ruby builds against `libyaml` and `openssl@3` from the shared Homebrew, which works since it only reads them.
- `apps` finds the apps already in `/Applications` and skips them.
- `ohmyzsh` installs oh-my-zsh for this account.

Open a new terminal and everything is there.

### 3. Sign in again

Nothing carries over from the main account. Sign in to:

- the App Store, if this account installs App Store apps
- Dropbox, if this account backs up its app settings (see [Mackup](#mackup))
- `gh auth login`, `glab auth login`, `docker login`
- GitHub or GitLab with the new SSH key, if you skipped it in the wizard ([ssh-keys.md](./ssh-keys.md))

The agent tools need their setup again too, see [agentic-tooling.md](./agentic-tooling.md#on-a-second-macos-account).

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

Add the package to the Brewfile in the main account's clone too, or a new Mac won't get it.

### Update

`update` does macOS updates, then Homebrew, then mise. In the second account it skips Homebrew with a message and runs the rest. So I update Homebrew and the apps from the main account, and each account updates its own mise tools.

Apps that update themselves (most casks) may ask for an administrator password when you update them from the second account, because the main account owns them.

### Edit the dotfiles

Each account has its own clone. I commit and push from one, `git pull` in the other, then `make link` if I added a file to `home/` or `config/`.

### Both accounts open at once

With fast user switching, both accounts keep running. Anything that listens on a fixed port then clashes with its twin in the other account. A dev server, a database, a container publishing the same port in both Colima VMs. Stop it in one account before you start it in the other.

## Mackup

Mackup copies the app settings into a folder of the Dropbox signed in to the current account. The two accounts have different app settings, so I give each its own folder, `Mackup` and `Mackup-work` for example. The wizard asks for it and `make setup` changes it. If both accounts share a folder, a `make mackup-backup` in one overwrites the other's settings.

If the work account shouldn't touch your personal Dropbox, just don't run the `mackup-*` targets there.

## Backups

Time Machine backs up the whole disk, both accounts included. To leave one out, see [time-machine.md](./time-machine.md#exclude-an-account).
