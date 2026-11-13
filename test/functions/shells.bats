#!/usr/bin/env bats
load ../helpers
setup() { F="$REPO_ROOT/shell/functions/shells.zsh"; }

@test "prints the default shell" {
  run env SHELL=/bin/zsh zsh -f -c "source '$F'; shells"
  [ "${lines[0]}" = "Default Shell:" ]
  [ "${lines[1]}" = "/bin/zsh" ]
}

@test "lists the shells allowed by /etc/shells, without comments" {
  run zrun "$F" shells
  [[ "$output" == *"/bin/sh"* ]]
  [[ "$output" != *"#"* ]]
}
