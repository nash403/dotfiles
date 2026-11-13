#!/usr/bin/env bats
load ../helpers
setup() { D="$REPO_ROOT/shell/functions"; }

@test "removes every proxy variable" {
  run env -i PATH="$PATH" HTTP_PROXY=a https_proxy=b no_proxy=c zsh -f -c "source '$D/proxy_show.zsh'; source '$D/proxy_off.zsh'; proxy_off >/dev/null; env | grep -ci proxy"
  [ "$output" = "0" ]
}

@test "is harmless when nothing is set" {
  run env -i PATH="$PATH" zsh -f -c "source '$D/proxy_show.zsh'; source '$D/proxy_off.zsh'; proxy_off"
  [ "$status" -eq 0 ]
  [[ "$output" == *"removed."* ]]
}
