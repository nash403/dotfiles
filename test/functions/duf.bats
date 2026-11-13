#!/usr/bin/env bats
load ../helpers
setup() { F="$REPO_ROOT/shell/functions/duf.zsh"; }

@test "shows the total of the current folder in human units" {
  stub du 'printf "2048\t.\n2048\ttotal\n"'
  run zrun "$F" duf
  [[ "${lines[0]}" == "2M"* ]]
}

@test "passes the depth to du" {
  stub du 'echo "0 $*" >&2; printf "1\tx\n"'
  run zrun "$F" duf 2
  [[ "$output" == *"-d 2 -c"* ]]
}
