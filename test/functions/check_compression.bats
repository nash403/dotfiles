#!/usr/bin/env bats
load ../helpers
setup() { F="$REPO_ROOT/shell/functions/check_compression.zsh"; }

@test "prints uncompressed and compressed sizes" {
  stub curl 'case "$*" in "--head "*) echo "Content-Encoding: gzip";; *Accept-Encoding*) echo "Size (compressed) =   10";; *) echo "Size (uncompressed) = 100";; esac'
  run zrun "$F" check_compression https://example.test
  [ "${lines[0]}" = "Size (uncompressed) = 100" ]
  [ "${lines[1]}" = "Size (compressed) =   10" ]
  [ "${lines[2]}" = "Content-Encoding: gzip" ]
}

@test "prints no header line when the server sends none" {
  stub curl 'case "$*" in "--head "*) echo "Server: x";; *) echo size;; esac'
  run zrun "$F" check_compression https://example.test
  [ "${#lines[@]}" -eq 2 ]
}
