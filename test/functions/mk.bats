#!/usr/bin/env bats
load ../helpers
setup() { F="$REPO_ROOT/shell/functions/mk.zsh"; cd "$BATS_TEST_TMPDIR"; }

@test "creates nested folders and enters them" {
  run zsh -f -c "source '$F'; mk a/b && pwd"
  [[ "$output" == */a/b ]]
  [ -d a/b ]
}

@test "fails when the path is a file" {
  touch afile
  run zrun "$F" mk afile/sub
  [ "$status" -ne 0 ]
}
