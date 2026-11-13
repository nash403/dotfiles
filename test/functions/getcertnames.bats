#!/usr/bin/env bats
load ../helpers
setup() { F="$REPO_ROOT/shell/functions/getcertnames.zsh"; }

@test "refuses to run without a domain" {
  run zrun "$F" getcertnames
  [ "$status" -eq 1 ]
  [ "$output" = "ERROR: No domain specified." ]
}

@test "reports a missing certificate" {
  stub openssl 'echo "connect: refused"'
  run zrun "$F" getcertnames example.test
  [ "$status" -eq 1 ]
  [[ "$output" == *"ERROR: Certificate not found."* ]]
}

@test "lists the common name and alternative names" {
  stub openssl 'case "$1" in
    s_client) echo "-----BEGIN CERTIFICATE-----";;
    x509) printf "Subject: CN=example.test\nX509v3 Subject Alternative Name: \nDNS:example.test, DNS:www.example.test\n";;
  esac'
  run zrun "$F" getcertnames example.test
  [ "$status" -eq 0 ]
  [[ "$output" == *"example.test"* ]]
  [[ "$output" == *"www.example.test"* ]]
}
