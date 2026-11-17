# Time Machine

For Homebrew, the apps and the tools, I should not need Time Machine. But I need it for what nothing else can rebuild. My documents, my media files, my repos, my SSH keys, etc.

## What it backs up

The whole disk by default, whoever is logged in. Every home folder, `/Applications`, `/opt/homebrew`. Exclusions apply to the whole disk too, so you set them once, from any administrator account.

### Exclude what `make` rebuilds

```bash
sudo tmutil addexclusion -p /opt/homebrew
```

Ideally also exclude each account's mise tools. `make mise` downloads them again.

```bash
tmutil addexclusion ~/.local/share/mise
```

To check:

```bash
tmutil isexcluded /opt/homebrew ~/.local/share/mise
```

`-p` excludes the path itself, so the exclusion survives the folder being deleted and created again. It needs `sudo`. `sudo tmutil removeexclusion -p <path>` undoes it.

You can do the same in System Settings → General → Time Machine → Options…, with the + button. `Cmd+Shift+G` lets you type a path.

You may include the dotfiles clone because `custom/` (your private aliases, your private Brewfile, etc.) is ignored by git.

### Exclude an account

To not backup a whole account, you can just exclude its home directory.

```bash
sudo tmutil addexclusion -p /Users/<account>
```

## Set up a new Mac from a backup (Restore some accounts, or some kinds of data)

Migration Assistant picks what to restore by account and by kind of data. It runs during the first setup of a Mac, and also any time later from Applications → Utilities → Migration Assistant.

You choose:

- which accounts, one by one
- the applications
- other files and folders, outside the home folders
- computer and network settings

If an account with the same name already exists on the Mac, it asks whether to rename one or replace the existing one.

Steps:

1. In Migration Assistant, restore the accounts only and untick what `make` rebuilds (`/Applications`, `/opt/homebrew`, etc.)
2. Log in to the main account, the one that will own Homebrew. Either the clone came back with it, `custom/` and symlinks included, or you may clone it again.
3. Install the [prerequisites](../README.md#prerequisites), sign in to the App Store, follow the setup steps if you had to clone again, or `cd ~/.dotfiles && make` otherwise.
4. Sign in to Dropbox and your other CLI or Apps.

### If /Applications is restored with apps declared in Brewfile

`brew bundle` then stops on apps it didn't install itself, with "It seems there is already an App at…". Hand them over to Homebrew without downloading them again:

```bash
brew install --cask --adopt <cask>
```

Then `make brew` again.

## Cherry-pick files to restore at any moment

Any time, from the account that owns the files:

1. Open the folder in the Finder, then pick Browse Time Machine Backups in the Time Machine menu of the menu bar.
2. Go back to the date you want, select one or more items, and click Restore.
3. If the file still exists, macOS asks whether to keep the original, keep both, or replace it. To get the old version somewhere else without touching the current one, right-click it in Time Machine, pick Copy, and paste it where you want.
