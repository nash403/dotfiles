#!/usr/bin/env bats
load ../helpers
setup() { F="$REPO_ROOT/shell/functions/gz.zsh"; }

@test "compares original and gzipped sizes" {
  printf 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' >"$BATS_TEST_TMPDIR/f"
  run zrun "$F" gz "$BATS_TEST_TMPDIR/f"
  [ "${lines[0]}" = "orig: 44 bytes" ]
  [[ "${lines[1]}" == "gzip: "*" bytes ("*"%)" ]]
}

@test "fails on a missing file" {
  run zrun "$F" gz "$BATS_TEST_TMPDIR/missing"
  [[ "$output" == *"missing"* ]]
}
