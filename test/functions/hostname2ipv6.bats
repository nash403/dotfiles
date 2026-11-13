#!/usr/bin/env bats
load ../helpers
setup() { F="$REPO_ROOT/shell/functions/hostname2ipv6.zsh"; }

@test "prints the first IPv6 address, skipping CNAME targets" {
  stub dig 'printf "alias.example.test.\n2001:db8::1\n2001:db8::2\n"'
  run zrun "$F" hostname2ipv6 example.test
  [ "$output" = "2001:db8::1" ]
}

@test "prints nothing for a host without IPv6" {
  stub dig 'true'
  run zrun "$F" hostname2ipv6 ipv4only.test
  [ -z "$output" ]
}

@test "asks for a hostname" {
  run zrun "$F" hostname2ipv6
  [ "$status" -eq 2 ]
  [[ "$output" == usage:* ]]
}
