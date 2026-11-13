#!/usr/bin/env bats
load ../helpers
setup() { F="$REPO_ROOT/shell/functions/meteo.zsh"; }

@test "asks wttr.in for the given place" {
  stub curl 'echo "GET $*"'
  run zrun "$F" meteo Paris
  [ "$output" = "GET -s wttr.in/Paris" ]
}

@test "uses the IP location when no place is given" {
  stub curl 'case "$2" in ipinfo.io/loc) echo "48.8,2.3";; *) echo "GET $*";; esac'
  run zrun "$F" meteo
  [ "$output" = "GET -s wttr.in/48.8,2.3" ]
}
