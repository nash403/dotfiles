#!/usr/bin/env bats
load ../helpers
setup() { F="$REPO_ROOT/shell/functions/o.zsh"; stub open 'echo "open $*"'; }

@test "opens the current folder without argument" {
  run zrun "$F" o
  [ "$output" = "open ." ]
}

@test "opens the given locations" {
  run zrun "$F" o a b
  [ "$output" = "open a b" ]
}
