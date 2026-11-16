# Time Machine

`make` and the Brewfile rebuild Homebrew, the apps and the tools, so I don't need Time Machine for those. I need it for what nothing else can rebuild. My files, my SSH keys, and the `custom/` folder of the clone.

With two accounts on the Mac, read [multiple-accounts.md](./multiple-accounts.md) first.

## What it backs up

The whole disk, whoever is logged in. Every home folder, `/Applications`, `/opt/homebrew`. Exclusions apply to the whole disk too, so you set them once, from any administrator account.

## Exclude what `make` rebuilds

```bash
sudo tmutil addexclusion -p /opt/homebrew
```

If you want, also exclude each account's mise tools. `make mise` downloads them again.

```bash
tmutil addexclusion ~/.local/share/mise
```

To check:

```bash
tmutil isexcluded /opt/homebrew ~/.local/share/mise
```

`-p` excludes the path itself, so the exclusion survives the folder being deleted and created again. It needs `sudo`. `sudo tmutil removeexclusion -p <path>` undoes it.

You can do the same in System Settings → General → Time Machine → Options…, with the + button. `Cmd+Shift+G` lets you type a path.

Don't exclude the dotfiles clone. git has the tracked files, but `custom/` is ignored by git. Your private aliases, your private Brewfile and the wizard's answers only exist on this disk and in the backup.

## Exclude an account

I leave the work account out. Its files belong to my employer, who has their own backup.

```bash
sudo tmutil addexclusion -p /Users/<account>
```

After that, nothing in that home folder can come back from Time Machine. Not its files, not its `~/.ssh`, not its `custom/`. Make sure they live somewhere else (the company's backup, iCloud, a git remote), or that losing them is fine.

## Restore a few files

Any time, from the account that owns the files:

1. Open the folder in the Finder, then pick Browse Time Machine Backups in the Time Machine menu of the menu bar.
2. Go back to the date you want, select one or more items, and click Restore.
3. If the file still exists, macOS asks whether to keep the original, keep both, or replace it. To get the old version somewhere else without touching the current one, right-click it in Time Machine, pick Copy, and paste it where you want.

That's how I recover from a `make link` gone wrong, a lost file in `custom/`, or a deleted SSH key.

To restore into another account's home folder, log in to that account, or approve the access from an administrator account. If macOS still refuses, give the Finder (or the terminal, for `tmutil restore`) Full Disk Access in System Settings → Privacy & Security.

## Restore some accounts, or some kinds of data

Migration Assistant picks what to restore by account and by kind of data. It runs during the first setup of a Mac, and also any time later from Applications → Utilities → Migration Assistant, with "From a Mac, Time Machine backup, or startup disk".

You choose:

- which accounts, one by one, so the personal one without the work one or the other way around
- the applications
- other files and folders, outside the home folders
- computer and network settings

If an account with the same name already exists on the Mac, it asks whether to rename one or replace the existing one.

## Set up a new Mac from a backup

1. In Migration Assistant, restore the accounts only and untick Applications. `/opt/homebrew` isn't in the backup anyway, and `make` reinstalls the apps.
2. Log in to the main account, the one that will own Homebrew. The clone came back with it, `custom/` and symlinks included.
3. Install the [prerequisites](../README.md#prerequisites), sign in to the App Store, then:

   ```bash
   cd ~/.dotfiles && make
   ```

   `custom/dotfiles.env` came back too, so there's no need for the wizard. Run `make setup` first only if you want to rename the machine.
4. Sign in to Dropbox, then run `gh auth login`, `glab auth login` and `docker login` if their tokens didn't come back.
5. In the second account, if you restored one, run `make` too ([what it does there](./multiple-accounts.md#2-run-the-wizard-and-make)).

### If Applications came back anyway

`brew bundle` then stops on apps it didn't install itself, with "It seems there is already an App at…". Hand them over to Homebrew without downloading them again:

```bash
brew install --cask --adopt <cask>
```

Then `make brew` again.
