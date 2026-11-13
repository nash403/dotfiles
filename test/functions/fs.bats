#!/usr/bin/env bats
load ../helpers
setup() { F="$REPO_ROOT/shell/functions/fs.zsh"; cd "$BATS_TEST_TMPDIR"; printf 'hello' >a; }

@test "prints the size of the given file" {
  run zrun "$F" fs a
  [ "$status" -eq 0 ]
  [[ "$output" == *"a" ]]
}

@test "fails on a missing path" {
  run zrun "$F" fs missing
  [ "$status" -ne 0 ]
}
