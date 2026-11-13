#!/usr/bin/env bats
load ../helpers
setup() { F="$REPO_ROOT/shell/functions/proxy_show.zsh"; }

@test "lists the proxy variables, sorted" {
  run env -i PATH="$PATH" HTTPS_PROXY=b HTTP_PROXY=a zsh -f -c "source '$F'; proxy_show"
  [ "${lines[0]}" = "HTTPS_PROXY=b" ]
  [ "${lines[1]}" = "HTTP_PROXY=a" ]
}

@test "prints nothing without proxy variables" {
  run env -i PATH="$PATH" zsh -f -c "source '$F'; proxy_show"
  [ -z "$output" ]
}
