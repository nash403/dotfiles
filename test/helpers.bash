# Shared helpers for the bats suites. Load with: load '../helpers' or load 'helpers'.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
export REPO_ROOT

# setup_home: a throwaway $HOME whose ~/.dotfiles points to a fake clone that
# reuses the repo's shell/ and bin/ but has its own empty custom/, so tests never
# load the real private files.
setup_home() {
  export HOME="$BATS_TEST_TMPDIR/home"
  export FAKE_DOTFILES="$BATS_TEST_TMPDIR/dotfiles"
  mkdir -p "$HOME" "$FAKE_DOTFILES/custom"
  ln -s "$REPO_ROOT/shell" "$FAKE_DOTFILES/shell"
  ln -s "$REPO_ROOT/bin" "$FAKE_DOTFILES/bin"
  ln -s "$FAKE_DOTFILES" "$HOME/.dotfiles"
  unset DOTFILES_DIR DEV_DIR WORK_DIR ZDOTDIR
}

# zrun FILE CMD...: run CMD in a bare zsh after sourcing FILE.
zrun() {
  local file="$1"
  shift
  zsh -f -c 'source "$1" || exit 99; shift; "$@"' zrun "$file" "$@"
}

# stub NAME BODY: put a fake NAME command first in PATH. BODY is sh code.
stub() {
  local dir="$BATS_TEST_TMPDIR/stubs"
  mkdir -p "$dir"
  printf '#!/bin/sh\n%s\n' "$2" >"$dir/$1"
  chmod +x "$dir/$1"
  case ":$PATH:" in *":$dir:"*) ;; *) export PATH="$dir:$PATH" ;; esac
}
