#!/usr/bin/env bats
load ../helpers
setup() { F="$REPO_ROOT/shell/functions/server.zsh"; stub open 'true'; stub sleep 'true'; }

@test "serves on port 8000 by default" {
  stub python3 'echo "python3 $*"'
  run zrun "$F" server
  [ "$output" = "python3 -m http.server 8000" ]
}

@test "uses the given port" {
  stub python3 'echo "python3 $*"'
  run zrun "$F" server 9000
  [ "$output" = "python3 -m http.server 9000" ]
}
