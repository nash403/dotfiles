#!/usr/bin/env bats
load ../helpers
setup() { F="$REPO_ROOT/shell/functions/tre.zsh"; stub less 'cat'; }

@test "calls tree with hidden files, ignores and dirs first" {
  stub tree 'echo "tree $*"'
  run zrun "$F" tre src
  [ "$output" = "tree -aC -I .git|node_modules|bower_components --dirsfirst src" ]
}

@test "returns tree's error" {
  stub tree 'echo "tree: missing" >&2; exit 2'
  run zrun "$F" tre missing
  [[ "$output" == *"missing"* ]]
}
