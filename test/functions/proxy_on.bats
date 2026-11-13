#!/usr/bin/env bats
load ../helpers
setup() { D="$REPO_ROOT/shell/functions"; }

@test "builds the proxy URL from the PROXY_* variables" {
  run env -i PATH="$PATH" USERNAME=u PASSWORD=p PROXY_SERVER=proxy.test PROXY_PORT=3128 zsh -f -c "source '$D/proxy_show.zsh'; source '$D/proxy_on.zsh'; proxy_on >/dev/null; echo \$https_proxy; echo \$no_proxy"
  # USERNAME is a zsh special parameter: it always holds the login name.
  [[ "${lines[0]}" == "http://"*":p@proxy.test:3128" ]]
  [ "${lines[1]}" = "localhost,127.0.0.0/8,::1" ]
}

@test "still sets a URL when the variables are missing" {
  run env -i PATH="$PATH" zsh -f -c "source '$D/proxy_show.zsh'; source '$D/proxy_on.zsh'; proxy_on >/dev/null; echo \$HTTP_PROXY"
  [[ "$output" == "http://"*":@:" ]]
}
