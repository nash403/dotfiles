#!/usr/bin/env bats
load ../helpers
setup() {
  F="$REPO_ROOT/shell/functions/grecent.zsh"
  export GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null
  cd "$BATS_TEST_TMPDIR"
}

@test "lists the branches switched from, without the current one" {
  git init -q -b main repo && cd repo
  git -c user.name=t -c user.email=t@t commit -q --allow-empty -m init
  git switch -q -c feat-a && git switch -q -c feat-b && git switch -q main
  run zrun "$F" grecent
  [ "$status" -eq 0 ]
  [[ "$output" == *"feat-b"* ]]
  [[ "$output" == *"feat-a"* ]]
  [[ "$output" != *"-> "*"main"* ]]
}

@test "fails outside a git repository" {
  run zrun "$F" grecent
  [ "$status" -eq 1 ]
  [[ "$output" == *"not in a git repository"* ]]
}
