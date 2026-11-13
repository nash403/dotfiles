#!/usr/bin/env bats
load ../helpers
setup() { F="$REPO_ROOT/shell/functions/myuptime.zsh"; }

@test "prints a short uptime" {
  stub uptime 'echo "10:00  up 3 days, 2:00, 1 user"'
  run zrun "$F" myuptime
  [ "$output" = "Uptime: 3 days 2:00" ]
}

@test "returns success" {
  stub uptime 'echo x'
  run zrun "$F" myuptime
  [ "$status" -eq 0 ]
}
