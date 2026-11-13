#!/usr/bin/env bats
# make detach against a throwaway HOME: only copies of repo files land there.

load helpers

setup() {
  HOME_T="$BATS_TEST_TMPDIR/my home"
  mkdir -p "$HOME_T/.config/app with space"
  ln -s "$REPO_ROOT/home/.zshrc" "$HOME_T/.zshrc"
  ln -s "$REPO_ROOT/config/git/ignore" "$HOME_T/.config/app with space/ignore"
  ln -s "$REPO_ROOT" "$HOME_T/.dotfiles"
  ln -s /etc/hosts "$HOME_T/.elsewhere"
}

@test "detach replaces repo symlinks with copies, paths with spaces included" {
  run make -C "$REPO_ROOT" --no-print-directory detach HOME="$HOME_T"
  [ "$status" -eq 0 ]
  [ -f "$HOME_T/.zshrc" ] && [ ! -L "$HOME_T/.zshrc" ]
  [ -f "$HOME_T/.config/app with space/ignore" ] && [ ! -L "$HOME_T/.config/app with space/ignore" ]
  [[ "$output" == *"2 symlink(s)"* ]]
}

@test "detach leaves ~/.dotfiles and links to elsewhere alone" {
  run make -C "$REPO_ROOT" --no-print-directory detach HOME="$HOME_T"
  [ -L "$HOME_T/.dotfiles" ]
  [ -L "$HOME_T/.elsewhere" ]
}
