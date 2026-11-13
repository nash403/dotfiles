#!/usr/bin/env bats
load ../helpers

@test "matches the current OS" {
  run "$REPO_ROOT/bin/is-macos"
  if [ "$(uname -s)" = Darwin ]; then [ "$status" -eq 0 ]; else [ "$status" -eq 1 ]; fi
}

@test "fails when OSTYPE is not darwin" {
  run env OSTYPE=linux-gnu bash -c '[[ "$OSTYPE" =~ ^darwin ]]'
  [ "$status" -eq 1 ]
}
