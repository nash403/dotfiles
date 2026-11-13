#!/usr/bin/env bats
load ../helpers

@test "with one argument, exits 0 when the check passes" {
  run "$REPO_ROOT/bin/is-supported" true
  [ "$status" -eq 0 ]
}

@test "with one argument, exits 1 when the check fails" {
  run "$REPO_ROOT/bin/is-supported" false
  [ "$status" -eq 1 ]
}

@test "with three arguments, prints the matching value" {
  run "$REPO_ROOT/bin/is-supported" true yes no
  [ "$output" = "yes" ]
  run "$REPO_ROOT/bin/is-supported" false yes no
  [ "$output" = "no" ]
}
