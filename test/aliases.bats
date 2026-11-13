#!/usr/bin/env bats
# Aliases whose command line is easy to get wrong.

load helpers

setup() {
  setup_home
}

# alias_run NAME ARGS…: run the alias' command in bash with ARGS appended
alias_run() {
  local name="$1"
  shift
  bash --norc --noprofile -c 'shopt -s expand_aliases; . ~/.dotfiles/shell/aliases.sh; eval "$0 \"\$@\""' "$name" "$@"
}

@test "urlencode encodes spaces and symbols" {
  run alias_run urlencode "a b&c/é"
  [ "$output" = "a+b%26c%2F%C3%A9" ]
}

@test "ifactive prints only the interfaces that are up" {
  stub ifconfig 'printf "lo0: flags=8049<UP>\n\tinet 127.0.0.1\nen0: flags=8863<UP>\n\tstatus: active\nen1: flags=8863<UP>\n\tstatus: inactive\n"'
  run alias_run ifactive
  [ "$output" = "en0" ]
}

@test "gchangelog prints commit subjects without their hash" {
  export GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null
  cd "$BATS_TEST_TMPDIR" && git init -q -b main r && cd r
  git -c user.name=t -c user.email=t@t commit -q --allow-empty -m one
  git tag v1
  git -c user.name=t -c user.email=t@t commit -q --allow-empty -m "two words"
  run alias_run gchangelog
  [ "$output" = "two words" ]
}

@test "youtube aliases use yt-dlp" {
  stub yt-dlp 'echo "yt-dlp $*"'
  run alias_run youtube-mp3 URL
  [ "$output" = "yt-dlp -x --audio-format mp3 URL" ]
}
