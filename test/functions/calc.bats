#!/usr/bin/env bats
load ../helpers
setup() { F="$REPO_ROOT/shell/functions/calc.zsh"; }

@test "evaluates an expression with decimals" {
  run zrun "$F" calc '1/4'
  [ "$output" = ".25000000000000000000" ]
}

@test "reports a malformed expression" {
  run zrun "$F" calc '2 *'
  [ "$status" -ne 0 ]
}
