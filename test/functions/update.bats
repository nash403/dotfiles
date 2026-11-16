#!/usr/bin/env bats
load ../helpers
setup() {
  F="$REPO_ROOT/shell/functions/update.zsh"
  setup_home
  LOG="$BATS_TEST_TMPDIR/calls"
  export LOG
  stub sudo 'echo "sudo $*" >>"$LOG"'
  stub mise 'echo "mise $*" >>"$LOG"'
}

@test "updates Homebrew in the account that owns it" {
  stub brew "[ \"\$1\" = --prefix ] && echo '$BATS_TEST_TMPDIR' && exit 0; echo \"brew \$*\" >>\"\$LOG\""
  run zrun "$F" update
  [ "$status" -eq 0 ]
  grep -q "brew upgrade" "$LOG"
  grep -q "brew bundle --file=$HOME/.dotfiles/Brewfile" "$LOG"
  grep -q "mise install" "$LOG"
}

@test "skips Homebrew in an account that doesn't own it" {
  stub brew "[ \"\$1\" = --prefix ] && echo / && exit 0; echo \"brew \$*\" >>\"\$LOG\""
  run zrun "$F" update
  [[ "$output" == *"Homebrew skipped, it belongs to root"* ]]
  ! grep -q "^brew" "$LOG"
  grep -q "sudo softwareupdate -i -a" "$LOG"
  grep -q "mise self-update" "$LOG"
}
