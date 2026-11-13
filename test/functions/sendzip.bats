#!/usr/bin/env bats
load ../helpers
setup() { F="$REPO_ROOT/shell/functions/sendzip.zsh"; cd "$BATS_TEST_TMPDIR"; }

@test "zips the paths and shares the archive" {
  mkdir dir && echo x >dir/a && touch dir/.DS_Store
  stub sendme 'echo "sendme $*"'
  run zrun "$F" sendzip dir
  [ "$output" = "sendme send archive.zip" ]
  run unzip -l archive.zip
  [[ "$output" == *"dir/a"* ]]
  [[ "$output" != *".DS_Store"* ]]
}

@test "prints usage without argument" {
  run zrun "$F" sendzip
  [ "$status" -eq 1 ]
  [[ "$output" == Usage:* ]]
}

@test "fails clearly when sendme is missing" {
  run env PATH=/usr/bin:/bin zsh -f -c "source '$F'; sendzip x"
  [ "$status" -eq 1 ]
  [[ "$output" == "sendme not found"* ]]
}
