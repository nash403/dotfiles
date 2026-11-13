#!/usr/bin/env bats
load ../helpers

@test "succeeds for a command on the PATH" {
  run "$REPO_ROOT/bin/is-executable" sh
  [ "$status" -eq 0 ]
}

@test "fails for an unknown command" {
  run "$REPO_ROOT/bin/is-executable" no-such-command-xyz
  [ "$status" -eq 1 ]
}
