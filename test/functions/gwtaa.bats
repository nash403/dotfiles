#!/usr/bin/env bats
load ../helpers
setup() {
  F="$REPO_ROOT/shell/functions/gwtaa.zsh"
  export GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null
  cd "$BATS_TEST_TMPDIR"
  git init -q -b main repo
  git -C repo -c user.name=t -c user.email=t@t commit -q --allow-empty -m init
}

@test "creates a new branch from the given base and enters the worktree" {
  cd repo
  run zsh -f -c "source '$F'; gwtaa feat main >/dev/null 2>&1 && pwd && git branch --show-current"
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == *"/repo.worktrees/"*-*-* ]]
  [ "${lines[1]}" = "feat" ]
}

@test "checks out an existing branch" {
  git -C repo branch existing
  cd repo
  run zsh -f -c "source '$F'; gwtaa existing >/dev/null 2>&1 && git branch --show-current"
  [ "$output" = "existing" ]
}

@test "rejects a wrong number of arguments" {
  cd repo
  run zrun "$F" gwtaa
  [ "$status" -eq 2 ]
  [[ "$output" == usage:* ]]
}

@test "fails outside a git repository" {
  run zrun "$F" gwtaa feat
  [ "$status" -eq 1 ]
  [[ "$output" == *"not in a git repository"* ]]
}
