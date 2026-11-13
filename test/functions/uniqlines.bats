#!/usr/bin/env bats
load ../helpers
setup() { F="$REPO_ROOT/shell/functions/uniqlines.zsh"; }

@test "prints only the lines that appear once" {
  printf 'b\na\nb\nc\n' >"$BATS_TEST_TMPDIR/f"
  run zrun "$F" uniqlines "$BATS_TEST_TMPDIR/f"
  [ "$output" = "$(printf 'a\nc')" ]
}

@test "fails on a missing file" {
  run zrun "$F" uniqlines "$BATS_TEST_TMPDIR/missing"
  [[ "$output" == *"No such file"* ]]
}
