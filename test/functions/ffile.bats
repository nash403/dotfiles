#!/usr/bin/env bats
load ../helpers
setup() { F="$REPO_ROOT/shell/functions/ffile.zsh"; cd "$BATS_TEST_TMPDIR"; mkdir -p sub/Report.d; touch sub/MyReport.txt other.md; }

@test "finds files by partial name, ignoring case" {
  run zrun "$F" ffile report
  [ "$output" = "./sub/MyReport.txt" ]
}

@test "prints nothing when no file matches" {
  run zrun "$F" ffile nope
  [ -z "$output" ]
}
