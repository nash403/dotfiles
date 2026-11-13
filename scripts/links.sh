#!/bin/sh
# Manage the symlinks from $HOME into this repo. Called by the Makefile.
#
#   links.sh link     home/* -> ~, config/* -> ~/.config, one symlink per file
#                     (never a folder symlink); real files in the way are moved
#                     to X.bak, or X.bak.<date> when X.bak exists
#   links.sh unlink   remove those symlinks; put X.bak back, else a copy of the
#                     repo file so the shell keeps working
#   links.sh backups  list the .bak files left to sort, with a diff command

set -eu

REPO=$(cd "$(dirname "$0")/.." && pwd -P)
CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}

# package_files: "<repo file> <destination>" for every file to link.
package_files() {
  for pkg in home config; do
    [ -d "$REPO/$pkg" ] || continue
    if [ "$pkg" = home ]; then dest_root=$HOME; else dest_root=$CONFIG_HOME; fi
    (cd "$REPO/$pkg" && find . -type f ! -name .DS_Store) | sed 's|^\./||' | sort |
      while IFS= read -r rel; do
        printf '%s\t%s\n' "$REPO/$pkg/$rel" "$dest_root/$rel"
      done
  done
  if [ -f "$REPO/custom/mise.toml" ]; then
    printf '%s\t%s\n' "$REPO/custom/mise.toml" "$CONFIG_HOME/mise/conf.d/custom.toml"
  fi
}

# tilde PATH: PATH with $HOME shown as ~ (for display only)
# shellcheck disable=SC2088
tilde() {
  case "$1" in "$HOME"/*) printf '~/%s' "${1#"$HOME"/}" ;; *) printf '%s' "$1" ;; esac
}

# normalize PATH: lexical absolute path (resolves . and .., not symlinks)
normalize() {
  printf '%s\n' "$1" | awk -F/ '{
    n = 0
    for (i = 1; i <= NF; i++) {
      if ($i == "" || $i == ".") continue
      if ($i == "..") { if (n > 0) n--; continue }
      p[++n] = $i
    }
    s = ""
    for (i = 1; i <= n; i++) s = s "/" p[i]
    print (s == "" ? "/" : s)
  }'
}

# points_into_repo LINK: true when the symlink's target lies inside the repo,
# whether or not that target still exists.
points_into_repo() {
  target=$(readlink "$1")
  case "$target" in /*) ;; *) target="$(dirname "$1")/$target" ;; esac
  target=$(normalize "$target")
  case "$target" in
    "$REPO" | "$REPO"/* | "$HOME/.dotfiles"/*) return 0 ;;
    *) return 1 ;;
  esac
}

# backup FILE: move FILE aside without ever overwriting a previous backup.
backup() {
  bak="$1.bak"
  [ -e "$bak" ] || [ -L "$bak" ] && bak="$1.bak.$(date +%Y%m%d-%H%M%S)"
  mv "$1" "$bak"
  printf '%s\t%s\n' "$(tilde "$1")" "$(tilde "$bak")" >>"$BACKUP_LOG"
}

# Broken symlinks into the repo, left by an older layout (e.g. run/.zshrc).
prune_broken_links() {
  {
    find "$HOME" -mindepth 1 -maxdepth 1 -type l
    [ -d "$CONFIG_HOME" ] && find "$CONFIG_HOME" -type l
  } | while IFS= read -r link; do
    [ "$link" = "$HOME/.dotfiles" ] && continue
    if [ ! -e "$link" ] && points_into_repo "$link"; then
      rm -f "$link"
      echo "  removed broken link $(tilde "$link")"
    fi
  done
}

# unfold DEST: a parent folder of DEST that is a symlink into the repo (old
# folded stow layout, e.g. ~/.config/git -> repo/config/git) is removed, so
# the folder can be recreated for real.
unfold() {
  dir=$(dirname "$1")
  while [ "$dir" != "$HOME" ] && [ "$dir" != "/" ]; do
    if [ -L "$dir" ] && points_into_repo "$dir"; then
      rm -f "$dir"
      echo "  removed folder link $(tilde "$dir")"
    fi
    dir=$(dirname "$dir")
  done
}

link() {
  prune_broken_links
  package_files | while IFS='	' read -r src dest; do
    unfold "$dest"
    if [ -L "$dest" ]; then
      [ "$(readlink "$dest")" = "$src" ] && continue
      if points_into_repo "$dest"; then rm -f "$dest"; else backup "$dest"; fi
    elif [ -e "$dest" ]; then
      backup "$dest"
    fi
    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
  done

  # Without ~/.gitconfig, `git config --global` (gh, VS Code…) would write to
  # ~/.config/git/config, which is a file of this repo.
  [ -e "$HOME/.gitconfig" ] || : >"$HOME/.gitconfig"

  report_backups
}

report_backups() {
  backed_up=$(grep -v '^$' "$BACKUP_LOG" 2>/dev/null || true)
  [ -n "$backed_up" ] || return 0
  count=$(printf '%s\n' "$backed_up" | wc -l | tr -d ' ')
  first=$(printf '%s\n' "$backed_up" | head -1)
  echo
  echo "⚠  $count existing file(s) moved aside:"
  printf '%s\n' "$backed_up" | while IFS='	' read -r orig bak; do
    printf '   %-32s → %s\n' "$orig" "$bak"
  done
  echo "   Compare: code --diff ${first#*	} ${first%%	*}"
  echo "   List them again: make backups"
}

unlink_all() {
  package_files | while IFS='	' read -r src dest; do
    [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ] || continue
    rm -f "$dest"
    # Only X.bak comes back; X.bak.<date> files stay for `make backups`.
    if [ -e "$dest.bak" ]; then
      mv "$dest.bak" "$dest"
      echo "  restored $(tilde "$dest")"
    else
      cp "$src" "$dest"
      echo "  copied   $(tilde "$dest")"
    fi
  done
}

backups() {
  found=0
  package_files | cut -f2 | {
    while IFS= read -r dest; do
      for bak in "$dest".bak "$dest".bak.*; do
        [ -e "$bak" ] || continue
        found=1
        echo "  code --diff $(tilde "$bak") $(tilde "$dest")"
      done
    done
    for bak in "$HOME/.gitconfig.bak" "$HOME"/.gitconfig.bak.*; do
      [ -e "$bak" ] || continue
      found=1
      echo "  code --diff $(tilde "$bak") ~/.gitconfig"
    done
    if [ "$found" = 0 ]; then
      echo "No .bak file to sort."
    else
      echo
      echo "Copy what you want to keep to the right side (the repo file) or into custom/, then delete the .bak."
    fi
  }
}

BACKUP_LOG=$(mktemp)
trap 'rm -f "$BACKUP_LOG"' EXIT

case "${1:-}" in
  link) link ;;
  unlink) unlink_all ;;
  backups) backups ;;
  *)
    echo "usage: $0 link|unlink|backups" >&2
    exit 2
    ;;
esac
