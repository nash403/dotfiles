# Move the dotfiles folder

The symlinks in your home folder point to the clone by its full path. Move the clone, or rename a folder above it (`~/dev` to `~/perso`, say), and they all point to a place that no longer exists.

Move the folder first, then run the wizard and `make link` from the new place. Do it all in the same terminal. Until `make link` runs, `~/.zshrc` still points to the old place, and a new terminal would start without your config.

```bash
mv ~/dev ~/perso # ~/dev is the default DEV_DIR
cd ~/perso/dotfiles && make setup
make link
```

The wizard offers the new place as the clone folder and points `~/.dotfiles` to it. If you also moved your personal (`DEV_DIR`) or work (`WORK_DIR`) projects folder (like ~/dev in the example), type its new path when the wizard asks: it still offers the old one. `make link` then replaces the symlinks that pointed to the old place.

Run `mise trust mise.toml` once in the new place too.

Don't type a new path in `make setup` without moving the folder first. The wizard would clone a fresh copy there, without your `custom/` files and without your unpushed commits.
