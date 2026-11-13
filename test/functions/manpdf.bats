#!/usr/bin/env bats
load ../helpers
setup() { F="$REPO_ROOT/shell/functions/manpdf.zsh"; }

@test "renders the man page as PDF with mandoc and opens it in Preview" {
  stub man 'echo /usr/share/man/man1/ls.1'
  stub mandoc 'echo "pdf of $3"'
  stub open 'cat; echo " opened with $*"'
  run zrun "$F" manpdf ls
  [[ "$output" == *"pdf of /usr/share/man/man1/ls.1"* ]]
  [[ "$output" == *"-f -a Preview"* ]]
}

@test "stops when there is no such man page" {
  stub man 'echo "No manual entry for nope" >&2; exit 1'
  stub open 'echo opened'
  run zrun "$F" manpdf nope
  [ "$status" -ne 0 ]
  [[ "$output" != *opened* ]]
}
