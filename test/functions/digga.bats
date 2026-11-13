#!/usr/bin/env bats
load ../helpers
setup() { F="$REPO_ROOT/shell/functions/digga.zsh"; }

@test "asks dig for each main record type, answer section only" {
  stub dig 'echo "$*"'
  run zrun "$F" digga example.com
  [ "${lines[0]}" = "+nocmd example.com A +noall +answer" ]
  [ "${lines[3]}" = "+nocmd example.com MX +noall +answer" ]
  [ "${#lines[@]}" -eq 6 ]
}

@test "prints nothing for a domain without records" {
  stub dig 'true'
  run zrun "$F" digga nope.test
  [ -z "$output" ]
}
