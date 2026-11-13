#!/usr/bin/env bats
load ../helpers
setup() { F="$REPO_ROOT/shell/functions/machinename.zsh"; }

@test "prints the three macOS names" {
  stub scutil 'case "$2" in ComputerName) echo "MacBook Pro d Honore";; HostName) exit 1;; LocalHostName) echo MacBook-Pro;; esac'
  run zrun "$F" machinename
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "ComputerName   MacBook Pro d Honore" ]
  [ "${lines[1]}" = "HostName       (not set)" ]
  [ "${lines[2]}" = "LocalHostName  MacBook-Pro" ]
}

@test "falls back to hostname without scutil" {
  stub hostname 'echo my-linux-box'
  run env PATH="$BATS_TEST_TMPDIR/stubs:/usr/bin:/bin" zsh -f -c "source '$F'; machinename"
  [ "$output" = "my-linux-box" ]
}
