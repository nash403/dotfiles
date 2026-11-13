#!/usr/bin/env bats
load ../helpers
setup() { F="$REPO_ROOT/shell/functions/fdir.zsh"; cd "$BATS_TEST_TMPDIR"; mkdir -p sub/Report.d; touch sub/MyReport.txt; }

@test "finds directories by partial name, ignoring case" {
  run zrun "$F" fdir report
  [ "$output" = "./sub/Report.d" ]
}

@test "prints nothing when no directory matches" {
  run zrun "$F" fdir nope
  [ -z "$output" ]
}
