#!/usr/bin/env bats
# scripts/mackup.sh runs against a fake clone and a stub mackup, so nothing
# touches the real home or Dropbox.

load helpers

setup() {
  export HOME="$BATS_TEST_TMPDIR/home"
  REPO="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$HOME" "$REPO/scripts" "$REPO/mackup" "$REPO/custom"
  cp "$REPO_ROOT/scripts/mackup.sh" "$REPO/scripts/"
  printf '# the list\n[applications_to_sync]\nzed\nalfred\n' >"$REPO/mackup/mackup.cfg"
  unset MACKUP_DIR
  LOG="$BATS_TEST_TMPDIR/mackup.log"
  stub mackup "echo \"mackup \$*\" >>'$LOG'"
  M="$REPO/scripts/mackup.sh"
}

@test "config writes ~/.mackup.cfg: Dropbox storage, the folder from dotfiles.env, then the app list" {
  echo "MACKUP_DIR='Backups/configs'" >"$REPO/custom/dotfiles.env"
  run sh "$M" config
  [ "$status" -eq 0 ]
  run sed -n '/^\[storage\]/,/^\[applications_to_sync\]/p' "$HOME/.mackup.cfg"
  [[ "$output" == *"engine = dropbox"* ]]
  [[ "$output" == *"directory = Backups/configs"* ]]
  grep -qx alfred "$HOME/.mackup.cfg"
}

@test "config defaults the folder to Mackup without dotfiles.env" {
  run sh "$M" config
  [ "$status" -eq 0 ]
  grep -qx "directory = Mackup" "$HOME/.mackup.cfg"
}

@test "backup, restore and dry-run write the config, then call mackup" {
  run sh "$M" backup
  [ "$status" -eq 0 ]
  [ -f "$HOME/.mackup.cfg" ]
  run sh "$M" restore
  [ "$status" -eq 0 ]
  run sh "$M" dry-run
  [ "$status" -eq 0 ]
  [ "$(cat "$LOG")" = "mackup backup
mackup restore
mackup --dry-run --force backup" ]
}

@test "an unknown command stops with the usage" {
  run sh "$M" nope
  [ "$status" -eq 1 ]
  [[ "$output" == *"config | backup | restore | dry-run"* ]]
  [ ! -e "$HOME/.mackup.cfg" ]
}
