#!/usr/bin/env bats
load ../helpers
bats_require_minimum_version 1.5.0
setup() { F="$REPO_ROOT/shell/functions/hostname2ip.zsh"; }

@test "extracts the IP from ping" {
  stub ping 'echo "PING example.test (93.184.216.34): 56 data bytes"'
  # stderr apart: recent GNU grep warns that egrep is obsolescent
  run --separate-stderr zrun "$F" hostname2ip example.test
  [ "$output" = "93.184.216.34" ]
}

@test "prints nothing for an unknown host" {
  stub ping 'echo "ping: cannot resolve nope: Unknown host" >&2; exit 68'
  run zrun "$F" hostname2ip nope
  [[ "$output" != *.*.*.* ]]
}
