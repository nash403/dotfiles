#!/usr/bin/env bats
load ../helpers

setup() {
  for cmd in nano scratch code; do stub "$cmd" "echo $cmd \"\$@\""; done
}

@test "opens Markdown in Scratch" {
  run "$REPO_ROOT/bin/editor" notes.md
  [ "$output" = "scratch notes.md" ]
}

@test "opens text files in nano" {
  run "$REPO_ROOT/bin/editor" todo.txt
  [ "$output" = "nano todo.txt" ]
}

@test "opens anything else in a new VS Code window" {
  run "$REPO_ROOT/bin/editor" app.ts
  [ "$output" = "code -n app.ts" ]
}

@test "falls back to nano when the app is missing" {
  rm "$BATS_TEST_TMPDIR/stubs/code" "$BATS_TEST_TMPDIR/stubs/scratch"
  run env PATH="$BATS_TEST_TMPDIR/stubs:/usr/bin:/bin" "$REPO_ROOT/bin/editor" app.ts
  [ "$output" = "nano app.ts" ]
  run env PATH="$BATS_TEST_TMPDIR/stubs:/usr/bin:/bin" "$REPO_ROOT/bin/editor" notes.md
  [ "$output" = "nano notes.md" ]
}
