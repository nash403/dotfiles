#!/usr/bin/env bats
load ../helpers
setup() { F="$REPO_ROOT/shell/functions/gcclip.zsh"; }

@test "clones the URL found in the clipboard" {
  stub pbpaste 'echo https://example.test/repo.git'
  stub git 'echo "git $*"'
  run zrun "$F" gcclip
  [ "$output" = "git clone https://example.test/repo.git" ]
}

@test "returns git's error when the clone fails" {
  stub pbpaste 'echo nope'
  stub git 'exit 128'
  run zrun "$F" gcclip
  [ "$status" -eq 128 ]
}
