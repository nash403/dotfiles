#!/usr/bin/env bats
# install.sh is fed on stdin, exactly like `curl … | sh`. Interactive runs read
# their answers from a file passed as DOTFILES_TTY instead of the terminal.

load helpers

setup() {
  export HOME="$BATS_TEST_TMPDIR/home"
  mkdir -p "$HOME"
  export GIT_CONFIG_NOSYSTEM=1
  unset DOTFILES_DIR DEV_DIR WORK_DIR GIT_NAME GIT_EMAIL COMPUTER_NAME DOTFILES_YES DOTFILES_RUN_MAKE

  # A tiny repo standing in for github.com/nash403/dotfiles
  REMOTE="$BATS_TEST_TMPDIR/remote/dotfiles"
  mkdir -p "$REMOTE"
  git -C "$REMOTE" init -q -b main
  printf 'all:\n\t@echo make-ran\n' >"$REMOTE/Makefile"
  git -C "$REMOTE" add Makefile
  git -C "$REMOTE" -c user.name=t -c user.email=t@t commit -q -m init
  export DOTFILES_REPO="$REMOTE" DOTFILES_BRANCH=main

  LOG="$BATS_TEST_TMPDIR/calls.log"
  : >"$LOG"
  stub uname '[ "$1" = -s ] && echo Darwin || /usr/bin/uname "$@"'
  stub xcode-select 'echo /Library/Developer/CommandLineTools'
  stub sudo '"$@"'
  stub scutil "case \"\$1\" in --get) echo 'Old Name';; *) echo \"scutil \$*\" >>'$LOG';; esac"
  stub ssh-keygen "echo \"ssh-keygen \$*\" >>'$LOG'; while [ \$# -gt 0 ]; do [ \"\$1\" = -f ] && f=\$2; shift; done; echo private >\"\$f\"; echo 'ssh-ed25519 AAAAKEY me@test' >\"\$f.pub\""
  stub ssh-add "echo \"ssh-add \$*\" >>'$LOG'"
  stub open "echo \"open \$*\" >>'$LOG'"
  stub pbcopy 'cat >/dev/null'
}

# install [ENV=VALUE…]: run the installer the way curl | sh does
install() {
  run env "$@" sh <"$REPO_ROOT/install.sh"
}

# answers LINE…: the lines typed in the terminal, in order
answers() {
  printf '%s\n' "$@" >"$BATS_TEST_TMPDIR/tty"
}

@test "non-interactive: clones, links and writes the answers" {
  install DOTFILES_YES=1 DOTFILES_DIR="$HOME/src/dotfiles" DEV_DIR=code WORK_DIR="~/job" GIT_NAME="Ada L" GIT_EMAIL=ada@test
  [ "$status" -eq 0 ]
  [ -f "$HOME/src/dotfiles/Makefile" ]
  [ "$(readlink "$HOME/.dotfiles")" = "$HOME/src/dotfiles" ]
  [ -d "$HOME/code" ] && [ -d "$HOME/job" ]
  run cat "$HOME/src/dotfiles/custom/dotfiles.env"
  [[ "$output" == *"DOTFILES_DIR=\"\$HOME\"'/src/dotfiles'"* ]]
  [[ "$output" == *"DEV_DIR=\"\$HOME\"'/code'"* ]]
  [[ "$output" == *"WORK_DIR=\"\$HOME\"'/job'"* ]]
  [[ "$output" != *"$HOME"* ]]
  [ "$(git config --file "$HOME/.gitconfig" user.name)" = "Ada L" ]
  [ "$(git config --file "$HOME/.gitconfig" user.email)" = "ada@test" ]
}

@test "non-interactive: skips the machine name and SSH steps, and make" {
  install DOTFILES_YES=1 DOTFILES_DIR="$HOME/dotfiles-clone"
  [ "$status" -eq 0 ]
  [ ! -s "$LOG" ]
  [[ "$output" != *"make-ran"* ]]
  [[ "$output" == *"cd $HOME/dotfiles-clone && make"* ]]
  [ ! -e "$HOME/.ssh" ]
}

@test "non-interactive: defaults to ~/dev/dotfiles, ~/dev, ~/work and the repo owner's identity" {
  install DOTFILES_YES=1
  [ "$status" -eq 0 ]
  [ "$(readlink "$HOME/.dotfiles")" = "$HOME/dev/dotfiles" ]
  [ -d "$HOME/dev" ] && [ -d "$HOME/work" ]
  [ "$(git config --file "$HOME/.gitconfig" user.name)" = "Honoré Nintunze" ]
}

@test "non-interactive: DOTFILES_RUN_MAKE=1 runs make in the clone" {
  install DOTFILES_YES=1 DOTFILES_RUN_MAKE=1
  [ "$status" -eq 0 ]
  [[ "$output" == *"make-ran"* ]]
}

@test "the custom/ skeleton is created once and never overwritten" {
  install DOTFILES_YES=1
  custom="$HOME/dev/dotfiles/custom"
  for f in path.sh exports.sh aliases.sh Brewfile mise.toml functions/README.md; do [ -f "$custom/$f" ]; done
  echo "alias mine=1" >"$custom/aliases.sh"
  install DOTFILES_YES=1
  [ "$status" -eq 0 ]
  [ "$(cat "$custom/aliases.sh")" = "alias mine=1" ]
}

@test "an existing ~/.gitconfig keeps its other keys and is backed up first" {
  printf '[includeIf "gitdir:~/work/"]\n\tpath = ~/.gitconfig-work\n[user]\n\tname = Old\n' >"$HOME/.gitconfig"
  echo older >"$HOME/.gitconfig.bak"
  install DOTFILES_YES=1 GIT_NAME=New GIT_EMAIL=new@test
  [ "$status" -eq 0 ]
  [ "$(git config --file "$HOME/.gitconfig" user.name)" = "New" ]
  [ "$(git config --file "$HOME/.gitconfig" includeIf.gitdir:~/work/.path)" = "~/.gitconfig-work" ]
  [ "$(cat "$HOME/.gitconfig.bak")" = "older" ]
  run cat "$HOME"/.gitconfig.bak.*
  [[ "$output" == *"name = Old"* ]]
}

@test "the existing git identity is the default on a re-run" {
  git config --file "$HOME/.gitconfig" user.name "Kept Name"
  install DOTFILES_YES=1
  [ "$(git config --file "$HOME/.gitconfig" user.name)" = "Kept Name" ]
}

@test "a non-empty folder that is not this repo stops the install" {
  mkdir -p "$HOME/dev/dotfiles" && echo x >"$HOME/dev/dotfiles/other"
  install DOTFILES_YES=1
  [ "$status" -eq 1 ]
  [[ "$output" == *"is not empty"* ]]
  [ ! -e "$HOME/.dotfiles" ]
}

@test "an existing clone of the same repo is updated" {
  install DOTFILES_YES=1
  echo "new" >"$REMOTE/NEW" && git -C "$REMOTE" add NEW && git -C "$REMOTE" -c user.name=t -c user.email=t@t commit -q -m new
  install DOTFILES_YES=1
  [ "$status" -eq 0 ]
  [ -f "$HOME/dev/dotfiles/NEW" ]
}

@test "paths outside the home folder are quoted and read back intact" {
  odd="$BATS_TEST_TMPDIR/it's here"
  install DOTFILES_YES=1 DEV_DIR="$odd"
  [ "$status" -eq 0 ]
  run sh -c '. "$1"; printf %s "$DEV_DIR"' sh "$HOME/dev/dotfiles/custom/dotfiles.env"
  [ "$output" = "$odd" ]
}

@test "without a terminal and without DOTFILES_YES, explains how to run unattended" {
  install DOTFILES_TTY=/nonexistent/tty
  [ "$status" -eq 1 ]
  [[ "$output" == *"DOTFILES_YES=1"* ]]
  [ ! -e "$HOME/.dotfiles" ]
}

@test "interactive: machine name, new SSH key, signing and GitHub" {
  #       ready  clone              dev   work  name       email       machine                 create key  sign platform recap gh   gh-sign make
  answers ""     "~/dev/dotfiles"   ""    ""    "Ada L"    "ada@test"  "MacBook Pro d'Honoré"  y      ""   y    1        y     ""   ""      n
  install DOTFILES_TTY="$BATS_TEST_TMPDIR/tty"
  [ "$status" -eq 0 ]
  grep -q "scutil --set ComputerName MacBook Pro d'Honoré" "$LOG"
  grep -q "scutil --set LocalHostName MacBook-Pro-dHonore" "$LOG"
  grep -q "ssh-keygen -t ed25519 -C ada@test -f $HOME/.ssh/id_ed25519" "$LOG"
  [ "$(git config --file "$HOME/.gitconfig" gpg.format)" = ssh ]
  [ "$(git config --file "$HOME/.gitconfig" user.signingkey)" = "$HOME/.ssh/id_ed25519.pub" ]
  [ "$(git config --file "$HOME/.gitconfig" commit.gpgsign)" = true ]
  [ "$(cat "$HOME/.ssh/allowed_signers")" = "ada@test ssh-ed25519 AAAAKEY me@test" ]
  [ "$(grep -c 'open https://github.com/settings/ssh/new' "$LOG")" -eq 2 ]
  grep -q "IgnoreUnknown UseKeychain" "$HOME/.ssh/config"
  [ "$(ls -l "$HOME/.ssh/config" | cut -c1-10)" = "-rw-------" ]
  grep -q '^COMPUTER_NAME=' "$HOME/dev/dotfiles/custom/dotfiles.env"
}

@test "interactive: an existing key is reused, the SSH config block is appended once" {
  mkdir -p "$HOME/.ssh"
  echo private >"$HOME/.ssh/id_ed25519"
  echo 'ssh-ed25519 AAAAOLD me@test' >"$HOME/.ssh/id_ed25519.pub"
  printf 'Host perso\n  HostName example.test\n' >"$HOME/.ssh/config"
  #       ready clone dev work name email machine sign platform recap make
  answers ""    ""    ""  ""   ""   ""    ""      n    4        y     n
  install DOTFILES_TTY="$BATS_TEST_TMPDIR/tty"
  [ "$status" -eq 0 ]
  # `! cmd` never fails a bats test (set -e ignores it): check with run instead.
  run grep -q ssh-keygen "$LOG"
  [ "$status" -ne 0 ]
  run grep -q "open " "$LOG"
  [ "$status" -ne 0 ]
  [ -z "$(git config --file "$HOME/.gitconfig" gpg.format)" ]
  head -1 "$HOME/.ssh/config" | grep -q "Host perso"
  answers "" "" "" "" "" "" "" n 4 y n
  install DOTFILES_TTY="$BATS_TEST_TMPDIR/tty"
  [ "$(grep -c 'Added by dotfiles install.sh' "$HOME/.ssh/config")" -eq 1 ]
}

@test "interactive: no SSH key at all" {
  #       ready clone dev work name email machine create recap make
  answers ""    ""    ""  ""   ""   ""    ""      n      y     n
  install DOTFILES_TTY="$BATS_TEST_TMPDIR/tty"
  [ "$status" -eq 0 ]
  [ ! -e "$HOME/.ssh/config" ]
  [[ "$output" == *"SSH_KEYS.md"* ]]
}

@test "interactive: GitLab on a self-hosted instance, with signing" {
  #       ready clone dev work name email machine create name       sign platform url                         recap gitlab make
  answers ""    ""    ""  ""   ""   ""    ""      y      id_ed25519_x y    2        "https://gitlab.example.test/" y     ""     n
  install DOTFILES_TTY="$BATS_TEST_TMPDIR/tty"
  [ "$status" -eq 0 ]
  grep -q "open https://gitlab.example.test/-/user_settings/ssh_keys" "$LOG"
  [[ "$output" == *"Authentication & Signing"* ]]
  [ "$(git config --file "$HOME/.gitconfig" user.signingkey)" = "$HOME/.ssh/id_ed25519_x.pub" ]
}

@test "interactive: refusing the recap changes nothing" {
  #       ready clone dev work name email machine create recap
  answers ""    ""    ""  ""   ""   ""    ""      n      n
  install DOTFILES_TTY="$BATS_TEST_TMPDIR/tty"
  [ "$status" -eq 1 ]
  [ ! -e "$HOME/.dotfiles" ]
  [ ! -e "$HOME/.gitconfig" ]
  [ ! -s "$LOG" ]
}

@test "Linux: a missing tool stops the unattended install with the command to run" {
  stub uname '[ "$1" = -s ] && echo Linux || /usr/bin/uname "$@"'
  stub apt-get 'true'
  # A PATH with every system command except zsh
  sysbin="$BATS_TEST_TMPDIR/sysbin"
  mkdir -p "$sysbin"
  for dir in /usr/bin /bin; do
    for cmd in "$dir"/*; do
      name=${cmd##*/}
      # -L too: a dangling link already there is not "-e" (Ubuntu's /bin is /usr/bin)
      [ "$name" = zsh ] || [ -e "$sysbin/$name" ] || [ -L "$sysbin/$name" ] || ln -s "$cmd" "$sysbin/$name"
    done
  done
  install DOTFILES_YES=1 PATH="$BATS_TEST_TMPDIR/stubs:$sysbin"
  [ "$status" -eq 1 ]
  [[ "$output" == *"sudo apt-get install -y zsh"* ]]
}

@test "non-interactive: an exported COMPUTER_NAME is ignored" {
  install DOTFILES_YES=1 COMPUTER_NAME="From Env"
  [ "$status" -eq 0 ]
  [ ! -s "$LOG" ]
  run grep -q COMPUTER_NAME "$HOME/dev/dotfiles/custom/dotfiles.env"
  [ "$status" -ne 0 ]
}

@test "a re-run that changes nothing makes no new .gitconfig backup" {
  install DOTFILES_YES=1 GIT_NAME=Same GIT_EMAIL=same@test
  install DOTFILES_YES=1 GIT_NAME=Same GIT_EMAIL=same@test
  [ "$status" -eq 0 ]
  [ -z "$(ls -A "$HOME" | grep '^\.gitconfig\.bak')" ]
}

@test "interactive: a long machine name gives a valid network name" {
  long="Un tres long nom de machine qui depasse largement la limite de soixante trois"
  #       ready clone dev work name email machine create recap make
  answers ""    ""    ""  ""   ""   ""    "$long" n      y     n
  install DOTFILES_TTY="$BATS_TEST_TMPDIR/tty"
  [ "$status" -eq 0 ]
  host=$(sed -n 's/^scutil --set LocalHostName //p' "$LOG")
  [ "${#host}" -le 63 ]
  [[ "$host" != *- ]]
}

@test "dry run, unattended: describes the actions and changes nothing" {
  install DOTFILES_YES=1 DOTFILES_DRY_RUN=1 DEV_DIR=code
  [ "$status" -eq 0 ]
  [[ "$output" == *"[dry run] git clone --branch main"* ]]
  [[ "$output" == *"DEV_DIR=\"\$HOME\"'/code'"* ]]
  [[ "$output" == *"[dry run] git config --file ~/.gitconfig user.name"* ]]
  [ ! -e "$HOME/.dotfiles" ] && [ ! -e "$HOME/dev" ] && [ ! -e "$HOME/code" ] && [ ! -e "$HOME/.gitconfig" ]
}

@test "dry run, interactive: asks everything, runs no SSH or machine command" {
  #       ready clone dev work name    email      machine     create name sign platform recap make
  answers ""    ""    ""  ""   "Ada L" "ada@test" "Ada's Mac" y      ""   y    1        y
  run env DOTFILES_TTY="$BATS_TEST_TMPDIR/tty" sh -s -- --dry-run <"$REPO_ROOT/install.sh"
  [ "$status" -eq 0 ]
  [ ! -s "$LOG" ]
  [[ "$output" == *"[dry run] ssh-keygen -t ed25519"* ]]
  [[ "$output" == *"[dry run] sudo scutil --set LocalHostName Adas-Mac"* ]]
  [[ "$output" == *"[dry run] open https://github.com/settings/ssh/new"* ]]
  [[ "$output" == *"[dry run] git config --file ~/.gitconfig gpg.format \"ssh\""* ]]
  [ ! -e "$HOME/.ssh" ] && [ ! -e "$HOME/.gitconfig" ] && [ ! -e "$HOME/.dotfiles" ]
}

@test "an unknown option stops before any question" {
  run env DOTFILES_YES=1 sh -s -- --nope <"$REPO_ROOT/install.sh"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown option: --nope"* ]]
}
