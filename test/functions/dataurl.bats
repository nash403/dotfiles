#!/usr/bin/env bats
load ../helpers
setup() { F="$REPO_ROOT/shell/functions/dataurl.zsh"; }

@test "encodes a file as a base64 data URL" {
  printf 'hi' >"$BATS_TEST_TMPDIR/a.txt"
  run zrun "$F" dataurl "$BATS_TEST_TMPDIR/a.txt"
  [ "$output" = "data:text/plain;charset=utf-8;base64,aGk=" ]
}

@test "fails on a missing file" {
  run zrun "$F" dataurl "$BATS_TEST_TMPDIR/missing"
  [[ "$output" != *"base64,"?* ]]
}
