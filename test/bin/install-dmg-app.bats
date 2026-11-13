#!/usr/bin/env bats
load ../helpers

setup() {
  export APPS_DIR="$BATS_TEST_TMPDIR/Applications"
  mkdir -p "$APPS_DIR"
  S="$REPO_ROOT/bin/install-dmg-app"
  # Two releases: the newest has no dmg (mobile release), the next one has it.
  stub curl 'case "$*" in
    *api.github.com*) printf "%s\n" "[{\"assets\":[{\"browser_download_url\": \"https://x.test/app.apk\"}]}," "{\"assets\":[{\"browser_download_url\": \"https://x.test/Demo_1.0_universal.dmg\"}]}]";;
    *) for a; do out=$a; done; while [ $# -gt 0 ]; do [ "$1" = -o ] && out=$2; shift; done; echo "dmg from x.test" >"$out";;
  esac'
  stub hdiutil 'case "$1" in
    attach) while [ $# -gt 0 ]; do [ "$1" = -mountpoint ] && mnt=$2; shift; done; mkdir -p "$mnt/Demo.app/Contents";;
    detach) true;;
  esac'
  stub codesign 'true'
  stub spctl 'true'
}

@test "installs the app from the newest release that has a matching dmg" {
  run "$S" owner/demo '_universal\.dmg$' Demo.app
  [ "$status" -eq 0 ]
  [ -d "$APPS_DIR/Demo.app" ]
  [[ "$output" == *"Demo_1.0_universal.dmg"* ]]
}

@test "skips an app that is already installed" {
  mkdir "$APPS_DIR/Demo.app"
  run "$S" owner/demo '_universal\.dmg$' Demo.app
  [ "$status" -eq 0 ]
  [[ "$output" == *"already installed"* ]]
}

@test "fails when no release has a matching file" {
  run "$S" owner/demo 'nothing-matches' Demo.app
  [ "$status" -eq 1 ]
  [ ! -e "$APPS_DIR/Demo.app" ]
}

@test "refuses an app whose signature is broken" {
  stub codesign 'echo "invalid signature" >&2; exit 1'
  run "$S" owner/demo '_universal\.dmg$' Demo.app
  [ "$status" -eq 1 ]
  [ ! -e "$APPS_DIR/Demo.app" ]
}

@test "without a terminal, skips an app Gatekeeper rejects and tells how to force it" {
  stub spctl 'echo rejected >&2; exit 3'
  run "$S" owner/demo '_universal\.dmg$' Demo.app </dev/null
  [ "$status" -eq 0 ]
  [ ! -e "$APPS_DIR/Demo.app" ]
  [[ "$output" == *"make apps FORCE=1"* ]]
}

@test "FORCE=1 installs an app Gatekeeper rejects" {
  stub spctl 'exit 3'
  FORCE=1 run "$S" owner/demo '_universal\.dmg$' Demo.app </dev/null
  [ "$status" -eq 0 ]
  [ -d "$APPS_DIR/Demo.app" ]
}
