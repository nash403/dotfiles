#!/usr/bin/env bats
# scripts/links.sh runs against a fake clone, so nothing touches the real home.

load helpers

setup() {
  export HOME="$BATS_TEST_TMPDIR/home"
  export XDG_CONFIG_HOME="$HOME/.config"
  REPO="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$HOME" "$REPO/scripts" "$REPO/home" "$REPO/config/git" "$REPO/config/mise" "$REPO/custom"
  cp "$REPO_ROOT/scripts/links.sh" "$REPO/scripts/"
  echo zshrc >"$REPO/home/.zshrc"
  echo nanorc >"$REPO/home/.nanorc"
  echo gitconfig >"$REPO/config/git/config"
  echo gitignore >"$REPO/config/git/ignore"
  echo tools >"$REPO/config/mise/config.toml"
  REPO="$(cd "$REPO" && pwd -P)"
  L="$REPO/scripts/links.sh"
}

@test "link creates file symlinks, never folder symlinks" {
  run sh "$L" link
  [ "$status" -eq 0 ]
  [ "$(readlink -f "$HOME/.zshrc")" = "$REPO/home/.zshrc" ]
  [ "$(readlink -f "$XDG_CONFIG_HOME/git/config")" = "$REPO/config/git/config" ]
  [ -d "$XDG_CONFIG_HOME/mise" ] && [ ! -L "$XDG_CONFIG_HOME/mise" ]
  [ -d "$XDG_CONFIG_HOME/git" ] && [ ! -L "$XDG_CONFIG_HOME/git" ]
}

@test "link moves a real file aside to .bak and reports it" {
  echo mine >"$HOME/.zshrc"
  run sh "$L" link
  [ "$status" -eq 0 ]
  [ "$(cat "$HOME/.zshrc.bak")" = "mine" ]
  [ -L "$HOME/.zshrc" ]
  [[ "$output" == *"~/.zshrc"*"~/.zshrc.bak"* ]]
  [[ "$output" == *"make backups"* ]]
}

@test "link never overwrites an existing .bak" {
  echo old >"$HOME/.zshrc.bak"
  echo mine >"$HOME/.zshrc"
  run sh "$L" link
  [ "$(cat "$HOME/.zshrc.bak")" = "old" ]
  newest=$(ls "$HOME"/.zshrc.bak.* | head -1)
  [[ "$newest" =~ \.zshrc\.bak\.[0-9]{8}-[0-9]{6}$ ]]
  [ "$(cat "$newest")" = "mine" ]
}

@test "link removes broken symlinks left by an older layout of the repo" {
  ln -s "$REPO/run/.zshrc" "$HOME/.zshrc"
  ln -s "$REPO/run/.oldrc" "$HOME/.oldrc"
  ln -s /nowhere/else "$HOME/.unrelated"
  run sh "$L" link
  [ "$status" -eq 0 ]
  [ "$(readlink -f "$HOME/.zshrc")" = "$REPO/home/.zshrc" ]
  [ ! -L "$HOME/.oldrc" ]
  [ -L "$HOME/.unrelated" ]
}

@test "link replaces a folder symlink into the repo with real folders" {
  mkdir -p "$XDG_CONFIG_HOME"
  ln -s "$REPO/config/git" "$XDG_CONFIG_HOME/git"
  run sh "$L" link
  [ "$status" -eq 0 ]
  [ -d "$XDG_CONFIG_HOME/git" ] && [ ! -L "$XDG_CONFIG_HOME/git" ]
  [ "$(readlink -f "$XDG_CONFIG_HOME/git/ignore")" = "$REPO/config/git/ignore" ]
  [ -f "$REPO/config/git/config" ]
}

@test "link creates an empty ~/.gitconfig only when missing" {
  run sh "$L" link
  [ -f "$HOME/.gitconfig" ] && [ ! -s "$HOME/.gitconfig" ]
  echo "[user]" >"$HOME/.gitconfig"
  run sh "$L" link
  [ "$(cat "$HOME/.gitconfig")" = "[user]" ]
}

@test "link exposes custom/mise.toml to mise when present" {
  echo private >"$REPO/custom/mise.toml"
  run sh "$L" link
  [ "$(readlink -f "$XDG_CONFIG_HOME/mise/conf.d/custom.toml")" = "$REPO/custom/mise.toml" ]
}

@test "link is idempotent" {
  sh "$L" link
  run sh "$L" link
  [ "$status" -eq 0 ]
  [ -z "$(ls -A "$HOME" | grep '\.bak')" ]
  [[ "$output" != *"moved aside"* ]]
}

@test "unlink restores .bak files, else leaves a copy of the repo file" {
  echo mine >"$HOME/.zshrc"
  echo older >"$HOME/.nanorc.bak.20200101-000000"
  sh "$L" link
  run sh "$L" unlink
  [ "$status" -eq 0 ]
  [ ! -L "$HOME/.zshrc" ] && [ "$(cat "$HOME/.zshrc")" = "mine" ]
  [ ! -L "$HOME/.nanorc" ] && [ "$(cat "$HOME/.nanorc")" = "nanorc" ]
  [ -f "$HOME/.nanorc.bak.20200101-000000" ]
}

@test "backups lists every .bak with a diff command" {
  echo mine >"$HOME/.zshrc"
  echo older >"$HOME/.zshrc.bak.20200101-000000"
  sh "$L" link
  run sh "$L" backups
  [[ "$output" == *"code --diff ~/.zshrc.bak ~/.zshrc"* ]]
  [[ "$output" == *"~/.zshrc.bak.20200101-000000"* ]]
}

@test "backups says so when there is nothing to sort" {
  run sh "$L" backups
  [ "$status" -eq 0 ]
  [[ "$output" == *"No .bak file"* ]]
}
