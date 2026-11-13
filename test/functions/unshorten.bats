#!/usr/bin/env bats
load ../helpers
setup() { F="$REPO_ROOT/shell/functions/unshorten.zsh"; }

@test "prints the redirect target, whatever the header case" {
  stub curl 'printf "HTTP/2 301\r\nlocation: https://example.test/long\r\n"'
  run zrun "$F" unshorten https://sho.rt/x
  [ "$output" = "https://example.test/long" ]
}

@test "prints nothing without redirect" {
  stub curl 'printf "HTTP/2 200\r\n"'
  run zrun "$F" unshorten https://example.test
  [ -z "$output" ]
}
