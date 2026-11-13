#!/usr/bin/env bats
load ../helpers
setup() { F="$REPO_ROOT/shell/functions/duplines.zsh"; }

@test "prints only the repeated lines" {
  printf 'b\na\nb\nc\n' >"$BATS_TEST_TMPDIR/f"
  run zrun "$F" duplines "$BATS_TEST_TMPDIR/f"
  [ "$output" = "b" ]
}

@test "prints nothing when every line is unique" {
  printf 'a\nb\n' >"$BATS_TEST_TMPDIR/f"
  run zrun "$F" duplines "$BATS_TEST_TMPDIR/f"
  [ -z "$output" ]
}
