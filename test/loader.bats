#!/usr/bin/env bats

load helpers

setup() {
  setup_home
}

@test "zsh loader defines tracked aliases and functions" {
  run zsh -f -c 'source ~/.dotfiles/shell/init.zsh; alias c; whence -w gwtaa'
  [ "$status" -eq 0 ]
  [[ "$output" == *"c=clear"* ]]
  [[ "$output" == *"gwtaa: function"* ]]
}

@test "zsh loader works with an empty custom/" {
  run zsh -f -c 'source ~/.dotfiles/shell/init.zsh 2>&1'
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "custom/ is loaded after shell/ and overrides it" {
  echo "alias c='echo custom'" >"$FAKE_DOTFILES/custom/aliases.sh"
  run zsh -f -c 'source ~/.dotfiles/shell/init.zsh; alias c'
  [[ "$output" == *"c='echo custom'"* ]]
}

@test "custom functions and extra files are loaded" {
  mkdir -p "$FAKE_DOTFILES/custom/functions"
  echo 'myfn() { echo from-custom-fn; }' >"$FAKE_DOTFILES/custom/functions/myfn.zsh"
  echo 'export WORK_EXTRA=yes' >"$FAKE_DOTFILES/custom/work.zsh"
  run zsh -f -c 'source ~/.dotfiles/shell/init.zsh; myfn; echo "$WORK_EXTRA"'
  [ "${lines[0]}" = "from-custom-fn" ]
  [ "${lines[1]}" = "yes" ]
}

@test "dotfiles.env is exported before the aliases that use it" {
  printf "DEV_DIR=\"\$HOME\"'/code'\n" >"$FAKE_DOTFILES/custom/dotfiles.env"
  run zsh -f -c 'source ~/.dotfiles/shell/init.zsh; echo "$DEV_DIR"; zsh -f -c "echo \$DEV_DIR"'
  [ "${lines[0]}" = "$HOME/code" ]
  [ "${lines[1]}" = "$HOME/code" ]
}

@test "bash loader defines aliases without errors" {
  run bash --norc --noprofile -c 'shopt -s expand_aliases; . ~/.dotfiles/shell/init.bash 2>&1; alias c'
  [ "$status" -eq 0 ]
  [[ "$output" == "alias c='clear'" ]]
}

@test "bash login shell reaches the loader through .bash_profile" {
  cp "$REPO_ROOT/home/.bash_profile" "$REPO_ROOT/home/.bashrc" "$HOME/"
  # bash's `type` cannot look up a name containing "!", so ask `alias` instead.
  run bash -l -c "alias 'reload!'"
  [ "$status" -eq 0 ]
  [[ "$output" == "alias reload!="* ]]
}

@test "bash loader loads custom .sh files but not .zsh ones" {
  echo 'export FROM_SH=1' >"$FAKE_DOTFILES/custom/extra.sh"
  echo 'export FROM_ZSH=1' >"$FAKE_DOTFILES/custom/extra.zsh"
  run bash --norc --noprofile -c '. ~/.dotfiles/shell/init.bash; echo "${FROM_SH:-no}-${FROM_ZSH:-no}"'
  [ "$output" = "1-no" ]
}
