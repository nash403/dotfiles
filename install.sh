#!/bin/sh
# Messages show paths with a literal ~, and $HOME is written as-is to files:
# shellcheck disable=SC2088,SC2016
# dotfiles installer and setup wizard.
#
#   curl -fsSL https://raw.githubusercontent.com/nash403/dotfiles/master/install.sh | sh
#
# Asks where to clone the repo, your dev and work folders, your git identity,
# the machine name and whether to set up an SSH key, then clones and writes the
# answers. Re-run it from a clone with `make setup`.
#
# Options and environment variables:
#   --dry-run, DOTFILES_DRY_RUN=1
#                     ask the questions, then print what would be done without
#                     writing files or running commands (`make setup-dry`)
#   DOTFILES_REPO     repo to clone (default: github.com/nash403/dotfiles)
#   DOTFILES_BRANCH   branch to clone (default: master)
#   DOTFILES_YES=1    no questions: values come from DOTFILES_DIR, DEV_DIR,
#                     WORK_DIR, GIT_NAME, GIT_EMAIL, defaults otherwise; the
#                     machine name and SSH steps are skipped. DOTFILES_RUN_MAKE=1
#                     also runs `make`.
#
# POSIX sh on purpose: `curl … | sh` must work wherever sh exists.

DOTFILES_REPO=${DOTFILES_REPO:-https://github.com/nash403/dotfiles.git}
DOTFILES_BRANCH=${DOTFILES_BRANCH:-master}
DEFAULT_GIT_NAME="Honoré Nintunze"
DEFAULT_GIT_EMAIL="nintu.lab@gmail.com"
TOTAL_STAGES=9

# ──────────────────────────────────────────────────────────────────────────
# Wizard helpers (ported from the /wizard skill template to POSIX sh)
# ──────────────────────────────────────────────────────────────────────────

if [ -t 1 ] && command -v tput >/dev/null 2>&1 && [ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]; then
  BOLD=$(tput bold) DIM=$(tput dim) RESET=$(tput sgr0)
  BLUE=$(tput setaf 4) GREEN=$(tput setaf 2) YELLOW=$(tput setaf 3) RED=$(tput setaf 1)
else
  BOLD="" DIM="" RESET="" BLUE="" GREEN="" YELLOW="" RED=""
fi
STAGE_INDEX=0

is_yes_mode() { [ "${DOTFILES_YES:-}" = 1 ]; }
is_dry_run() { [ "${DOTFILES_DRY_RUN:-}" = 1 ]; }

clear_screen() {
  is_yes_mode && return 0
  [ -t 1 ] || return 0
  if command -v tput >/dev/null 2>&1; then tput clear; else printf '\033[2J\033[3J\033[H'; fi
}

stage() {
  clear_screen
  STAGE_INDEX=$((STAGE_INDEX + 1))
  printf '\n%s%s▸ Step %s/%s · %s%s\n' "$BOLD" "$BLUE" "$STAGE_INDEX" "$TOTAL_STAGES" "$1" "$RESET"
}
say() { printf '  %s\n' "$1"; }
step() { printf '  %s•%s %s\n' "$BLUE" "$RESET" "$1"; }
note() { printf '  %s%s%s\n' "$DIM" "$1" "$RESET"; }
warn() { printf '  %s⚠ %s%s\n' "$YELLOW" "$1" "$RESET"; }
ok() { printf '  %s✓%s %s\n' "$GREEN" "$RESET" "$1"; }
die() {
  printf '%s✗ %s%s\n' "$RED" "$1" "$RESET" >&2
  exit 1
}

# act "What it does" CMD...: run CMD, or only describe it in a dry run.
act() {
  if is_dry_run; then
    printf '  %s[dry run]%s %s\n' "$YELLOW" "$RESET" "$1"
    return 0
  fi
  shift
  "$@"
}

# ask VAR "Question" DEFAULT: read a value into VAR; Enter keeps DEFAULT.
ask() {
  if is_yes_mode; then
    eval "$1=\$3"
    return 0
  fi
  if [ -n "$3" ]; then
    printf '  %s%s%s %s[%s]%s ' "$BOLD" "$2" "$RESET" "$DIM" "$3" "$RESET"
  else
    printf '  %s%s%s ' "$BOLD" "$2" "$RESET"
  fi
  ASK_REPLY=""
  read -r ASK_REPLY || true
  [ -n "$ASK_REPLY" ] || ASK_REPLY=$3
  eval "$1=\$ASK_REPLY"
}

# confirm "Question" y|n: yes/no gate, Enter takes the default.
confirm() {
  if is_yes_mode; then
    [ "$2" = y ]
    return
  fi
  if [ "$2" = y ]; then CONFIRM_HINT="[Y/n]"; else CONFIRM_HINT="[y/N]"; fi
  printf '  %s? %s %s%s ' "$YELLOW" "$1" "$CONFIRM_HINT" "$RESET"
  CONFIRM_REPLY=""
  read -r CONFIRM_REPLY || true
  [ -n "$CONFIRM_REPLY" ] || CONFIRM_REPLY=$2
  case "$CONFIRM_REPLY" in [yY]*) return 0 ;; *) return 1 ;; esac
}

pause() {
  is_yes_mode && return 0
  printf '  %s%s%s ' "$DIM" "${1:-Press Enter to continue}" "$RESET"
  read -r _ || true
}

open_url() {
  if is_dry_run; then
    printf '  %s[dry run]%s open %s\n' "$YELLOW" "$RESET" "$1"
    return 0
  fi
  printf '  %s↗ opening%s %s\n' "$GREEN" "$RESET" "$1"
  if command -v open >/dev/null 2>&1; then
    open "$1" >/dev/null 2>&1 || warn "open it by hand: $1"
  elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$1" >/dev/null 2>&1 || warn "open it by hand: $1"
  else
    warn "open it by hand: $1"
  fi
}

# ──────────────────────────────────────────────────────────────────────────
# Helpers
# ──────────────────────────────────────────────────────────────────────────

is_macos() { [ "$(uname -s)" = Darwin ]; }

# expand_path PATH: ~ and bare names resolved under $HOME
expand_path() {
  case "$1" in
    "~") printf '%s' "$HOME" ;;
    "~/"*) printf '%s/%s' "$HOME" "${1#"~/"}" ;;
    /*) printf '%s' "$1" ;;
    *) printf '%s/%s' "$HOME" "$1" ;;
  esac
}

# shell_quote VALUE: VALUE as a sh word. Paths under $HOME keep "$HOME" so no
# account name ends up in the file: "$HOME"'/dev'.
shell_quote() {
  case "$1" in
    "$HOME") printf '"$HOME"' ;;
    "$HOME"/*) printf '"$HOME"'; single_quote "${1#"$HOME"}" ;;
    *) single_quote "$1" ;;
  esac
}
single_quote() {
  printf "'%s'" "$(printf '%s' "$1" | sed "s/'/'\\\\''/g")"
}

# hostname_from NAME: letters, digits and hyphens only, 63 characters max.
hostname_from() {
  # One substitution per accented letter: bracket expressions would match single
  # bytes of these multibyte characters.
  printf '%s' "$1" |
    sed -e 's/à/a/g;s/â/a/g;s/ä/a/g;s/á/a/g;s/ã/a/g;s/å/a/g;s/À/A/g;s/Â/A/g' \
      -e 's/Ä/A/g;s/Á/A/g;s/Ã/A/g;s/Å/A/g;s/ç/c/g;s/Ç/C/g;s/é/e/g;s/è/e/g' \
      -e 's/ê/e/g;s/ë/e/g;s/É/E/g;s/È/E/g;s/Ê/E/g;s/Ë/E/g;s/í/i/g;s/ì/i/g' \
      -e 's/î/i/g;s/ï/i/g;s/Í/I/g;s/Ì/I/g;s/Î/I/g;s/Ï/I/g;s/ñ/n/g;s/Ñ/N/g' \
      -e 's/ó/o/g;s/ò/o/g;s/ô/o/g;s/ö/o/g;s/õ/o/g;s/Ó/O/g;s/Ò/O/g;s/Ô/O/g' \
      -e 's/Ö/O/g;s/Õ/O/g;s/ú/u/g;s/ù/u/g;s/û/u/g;s/ü/u/g;s/Ú/U/g;s/Ù/U/g' \
      -e 's/Û/U/g;s/Ü/U/g;s/ý/y/g;s/ÿ/y/g;s/œ/oe/g;s/Œ/OE/g;s/æ/ae/g;s/Æ/AE/g' |
    LC_ALL=C sed -e "s/'//g" -e "s/$(printf '\342\200\231')//g" -e 's/[^A-Za-z0-9]\{1,\}/-/g' -e 's/^-//' |
    cut -c1-63 | sed 's/-$//'
}

# backup_path FILE: where FILE would be copied, never overwriting a backup.
backup_path() {
  if [ -e "$1.bak" ]; then printf '%s' "$1.bak.$(date +%Y%m%d-%H%M%S)"; else printf '%s' "$1.bak"; fi
}

# env_default KEY: KEY from an existing dotfiles.env of the target clone
env_default() {
  [ -r "$DOTFILES_DIR/custom/dotfiles.env" ] || return 0
  (
    set -a
    # shellcheck source=/dev/null
    . "$DOTFILES_DIR/custom/dotfiles.env"
    eval "printf '%s' \"\${$1:-}\""
  )
}

# repo_id URL: owner/name of a git URL, so https and ssh forms compare equal
repo_id() {
  printf '%s' "$1" | sed -E -e 's#/+$##' -e 's#\.git$##' -e 's#^.*[:/]([^/:]+/[^/:]+)$#\1#'
}

gitconfig_get() { git config --file "$HOME/.gitconfig" "$1" 2>/dev/null || true; }

# set_git KEY VALUE: one key of ~/.gitconfig. --file matters: without
# ~/.gitconfig, `git config --global` would write to ~/.config/git/config,
# which is a file of this repo.
set_git() {
  act "git config --file ~/.gitconfig $1 \"$2\"" git config --file "$HOME/.gitconfig" "$1" "$2"
}

# ──────────────────────────────────────────────────────────────────────────
# Stages
# ──────────────────────────────────────────────────────────────────────────

stage_checks() {
  stage "Checks"
  if is_macos; then
    xcode-select -p >/dev/null 2>&1 || die "Xcode Command Line Tools are missing. Run first:
    sudo softwareupdate -i -a
    xcode-select --install
then run this command again."
    ok "macOS, Xcode Command Line Tools installed"
    return
  fi

  MISSING=""
  for tool in git make zsh; do
    command -v "$tool" >/dev/null 2>&1 || MISSING="$MISSING $tool"
  done
  if [ -n "$MISSING" ]; then
    if command -v apt-get >/dev/null 2>&1; then
      INSTALL_CMD="sudo apt-get install -y$MISSING"
    elif command -v dnf >/dev/null 2>&1; then
      INSTALL_CMD="sudo dnf install -y$MISSING"
    else
      die "Missing:$MISSING. Install them, then run this again."
    fi
    if ! is_yes_mode && confirm "Missing:$MISSING. Install them ($INSTALL_CMD)?" y; then
      # shellcheck disable=SC2086 # INSTALL_CMD is meant to split into words
      act "$INSTALL_CMD" $INSTALL_CMD || die "Install failed: $INSTALL_CMD"
    else
      die "Missing:$MISSING. Run: $INSTALL_CMD"
    fi
  fi
  ok "git, make and zsh installed"

  ZSH_PATH=$(command -v zsh || echo /usr/bin/zsh)
  if ! is_yes_mode && [ "${SHELL:-}" != "$ZSH_PATH" ] && confirm "Make zsh your default shell?" y; then
    act "chsh -s $ZSH_PATH" chsh -s "$ZSH_PATH" || warn "chsh failed, run it by hand: chsh -s $ZSH_PATH"
  fi
}

stage_clone_path() {
  stage "Where to clone the dotfiles"
  if [ -n "$SELF_DIR" ]; then
    default=$SELF_DIR
  elif [ -L "$HOME/.dotfiles" ]; then
    default=$(cd "$HOME/.dotfiles" 2>/dev/null && pwd -P) || default="$HOME/dev/dotfiles"
  else
    default="$HOME/dev/dotfiles"
  fi
  say "Full path of the clone. ~/.dotfiles will point to it."
  ask DOTFILES_DIR "Clone folder:" "${DOTFILES_DIR:-$default}"
  DOTFILES_DIR=$(expand_path "$DOTFILES_DIR")
}

stage_folders() {
  stage "Project folders"
  say "A bare name is created in your home folder (dev → ~/dev)."
  ask DEV_DIR "Personal projects folder:" "${DEV_DIR:-$(env_default DEV_DIR)}"
  [ -n "$DEV_DIR" ] || DEV_DIR="~/dev"
  DEV_DIR=$(expand_path "$DEV_DIR")
  ask WORK_DIR "Work projects folder:" "${WORK_DIR:-$(env_default WORK_DIR)}"
  [ -n "$WORK_DIR" ] || WORK_DIR="~/work"
  WORK_DIR=$(expand_path "$WORK_DIR")
}

stage_git() {
  stage "Git identity"
  OLD_GIT_NAME=$(gitconfig_get user.name)
  OLD_GIT_EMAIL=$(gitconfig_get user.email)
  ask GIT_NAME "Name:" "${GIT_NAME:-${OLD_GIT_NAME:-$DEFAULT_GIT_NAME}}"
  ask GIT_EMAIL "Email:" "${GIT_EMAIL:-${OLD_GIT_EMAIL:-$DEFAULT_GIT_EMAIL}}"
}

stage_machine() {
  stage "Machine name"
  if is_yes_mode; then
    # COMPUTER_NAME may be exported by an earlier dotfiles.env: ignore it.
    COMPUTER_NAME=""
    note "Unattended mode: skipped."
    return
  fi
  if is_macos; then
    current=$(scutil --get ComputerName 2>/dev/null || true)
  else
    current=$(hostname 2>/dev/null || true)
  fi
  first_name=${GIT_NAME%% *}
  example="${first_name:-Alex}'s MacBook Pro"
  say "The display name (Sharing, AirDrop) accepts anything, e.g. \"$example\"."
  say "The network name is derived from it: letters, digits and hyphens, 63 characters max."
  note "Here: \"$example\" → $(hostname_from "$example")"
  while :; do
    ask COMPUTER_NAME "Machine name:" "${COMPUTER_NAME:-$current}"
    HOST_NAME=$(hostname_from "$COMPUTER_NAME")
    [ -n "$HOST_NAME" ] && break
    warn "This name gives no valid network name: use at least one letter or digit."
    COMPUTER_NAME=""
  done
  note "Network name: $HOST_NAME"
}

stage_ssh() {
  stage "SSH key"
  SSH_KEY="" SSH_CREATE=no SSH_SIGN=no SSH_PLATFORM=later GITLAB_URL=""
  if is_yes_mode; then
    note "Unattended mode: skipped."
    return
  fi
  if [ -f "$HOME/.ssh/id_ed25519" ]; then
    SSH_KEY="$HOME/.ssh/id_ed25519"
    ok "Existing key: ~/.ssh/id_ed25519"
  elif confirm "Create an SSH key?" y; then
    ask SSH_KEY_NAME "Key file name:" "id_ed25519"
    SSH_KEY="$HOME/.ssh/$SSH_KEY_NAME"
    SSH_CREATE=yes
    note "ssh-keygen will ask for a passphrase. Recommended: with the macOS keychain"
    note "you type it once. Without one, the key sits unencrypted on disk: anyone"
    note "who copies ~/.ssh can push as you."
  else
    note "No SSH key. To do it later: SSH_KEYS.md"
    return
  fi

  if confirm "Sign your commits with this key?" y; then SSH_SIGN=yes; fi

  say "Where to add the key?"
  say "  1) GitHub   2) GitLab   3) both   4) later"
  ask SSH_PLATFORM_CHOICE "Choice:" "4"
  case "$SSH_PLATFORM_CHOICE" in
    1) SSH_PLATFORM=github ;;
    2) SSH_PLATFORM=gitlab ;;
    3) SSH_PLATFORM=both ;;
    *) SSH_PLATFORM=later ;;
  esac
  case "$SSH_PLATFORM" in
    gitlab | both) ask GITLAB_URL "Your GitLab URL:" "https://gitlab.com" ;;
  esac
}

stage_recap() {
  stage "Summary"
  say "Clone            $DOTFILES_DIR ($DOTFILES_BRANCH)"
  say "~/.dotfiles   →  $DOTFILES_DIR"
  say "Personal         $DEV_DIR"
  say "Work             $WORK_DIR"
  say "git user.name    ${OLD_GIT_NAME:-(empty)} → $GIT_NAME"
  say "git user.email   ${OLD_GIT_EMAIL:-(empty)} → $GIT_EMAIL"
  if [ -n "${COMPUTER_NAME:-}" ]; then
    say "Machine          $COMPUTER_NAME ($HOST_NAME)"
  fi
  if [ -n "$SSH_KEY" ]; then
    action="existing"
    [ "$SSH_CREATE" = yes ] && action="to create"
    say "SSH key          $SSH_KEY ($action, add to: $SSH_PLATFORM)"
    if [ "$SSH_SIGN" = yes ]; then
      say "git gpg.format                 $(gitconfig_get gpg.format) → ssh"
      say "git user.signingkey            $(gitconfig_get user.signingkey) → $SSH_KEY.pub"
      say "git commit.gpgsign             $(gitconfig_get commit.gpgsign) → true"
      say "git tag.gpgsign                $(gitconfig_get tag.gpgsign) → true"
      say "git gpg.ssh.allowedSignersFile $(gitconfig_get gpg.ssh.allowedSignersFile) → ~/.ssh/allowed_signers"
    fi
  fi
  [ -f "$HOME/.gitconfig" ] && note "~/.gitconfig is first copied to .bak if a key changes; its other settings stay."
  if is_dry_run; then
    confirm "Show what would be done?" y || die "Cancelled."
  else
    confirm "Apply?" y || die "Cancelled: nothing was changed since the summary."
  fi
}

stage_apply() {
  if is_dry_run; then stage "What would be done (dry run)"; else stage "Install"; fi
  apply_clone
  apply_dotfiles_link
  apply_custom_skeleton
  act "mkdir -p $DEV_DIR $WORK_DIR" mkdir -p "$DEV_DIR" "$WORK_DIR" && ok "Folders $DEV_DIR and $WORK_DIR"
  apply_env_file
  apply_machine_name
  apply_git
  apply_ssh
}

apply_clone() {
  if [ "$DOTFILES_DIR" = "$SELF_DIR" ]; then
    ok "Using the existing clone: $DOTFILES_DIR"
  elif [ -d "$DOTFILES_DIR/.git" ]; then
    origin=$(git -C "$DOTFILES_DIR" remote get-url origin 2>/dev/null || true)
    if [ "$(repo_id "$origin")" = "$(repo_id "$DOTFILES_REPO")" ]; then
      act "git -C $DOTFILES_DIR pull --ff-only" git -C "$DOTFILES_DIR" pull --ff-only || die "git pull failed in $DOTFILES_DIR"
      ok "Existing clone updated: $DOTFILES_DIR"
    else
      die "$DOTFILES_DIR is already another git repo ($origin). Pick another folder."
    fi
  elif [ -e "$DOTFILES_DIR" ] && [ -n "$(ls -A "$DOTFILES_DIR" 2>/dev/null)" ]; then
    die "$DOTFILES_DIR exists and is not empty. Pick another folder."
  else
    act "mkdir -p $(dirname "$DOTFILES_DIR")" mkdir -p "$(dirname "$DOTFILES_DIR")"
    act "git clone --branch $DOTFILES_BRANCH $DOTFILES_REPO $DOTFILES_DIR" \
      git clone --branch "$DOTFILES_BRANCH" "$DOTFILES_REPO" "$DOTFILES_DIR" || die "git clone failed"
    ok "Cloned into $DOTFILES_DIR"
  fi
}

apply_dotfiles_link() {
  if [ -L "$HOME/.dotfiles" ] || [ ! -e "$HOME/.dotfiles" ]; then
    if [ "$DOTFILES_DIR" != "$HOME/.dotfiles" ]; then
      act "ln -sfn $DOTFILES_DIR ~/.dotfiles" ln -sfn "$DOTFILES_DIR" "$HOME/.dotfiles"
      ok "~/.dotfiles → $DOTFILES_DIR"
    fi
  elif [ "$(cd "$HOME/.dotfiles" && pwd -P)" != "$(cd "$DOTFILES_DIR" && pwd -P)" ]; then
    warn "~/.dotfiles is a real folder, left as is. The shell will load that one."
  fi
}

# custom_file NAME CONTENT: create custom/NAME once, never touch it after.
custom_file() {
  [ -e "$DOTFILES_DIR/custom/$1" ] && return 0
  if is_dry_run; then
    printf '  %s[dry run]%s create custom/%s\n' "$YELLOW" "$RESET" "$1"
    return 0
  fi
  printf '%s\n' "$2" >"$DOTFILES_DIR/custom/$1"
}

apply_custom_skeleton() {
  act "mkdir -p custom/functions" mkdir -p "$DOTFILES_DIR/custom/functions"
  custom_file path.sh '# Private PATH entries for this machine. Not committed (custom/ is gitignored).
# Loaded after shell/path.sh, by zsh and bash: keep it POSIX.
#
# export PATH="$HOME/some-sdk/bin:$PATH"'
  custom_file exports.sh '# Private environment variables: tokens, work settings… Not committed.
# Loaded after shell/exports.sh, by zsh and bash.
#
# export SOME_API_KEY="…"'
  custom_file aliases.sh '# Private aliases. Not committed. Loaded after shell/aliases.sh, so an alias
# defined here wins over the tracked one with the same name.
#
# alias vpn="sudo openconnect vpn.example.com"'
  custom_file functions/README.md '# Private functions

One function per `<name>.zsh` file, like `shell/functions/`. zsh only, loaded
after the tracked functions.'
  custom_file Brewfile '# Private Homebrew apps for this machine, installed by `make brew` after the
# main Brewfile.
#
# cask "some-client-app"'
  custom_file mise.toml '# Private mise tools for this machine. `make link` exposes this file as
# ~/.config/mise/conf.d/custom.toml; `make mise` installs it.
#
# [tools]
# terraform = "1.9"'
  ok "custom/ skeleton ready (existing files left as they are)"
}

env_file_content() {
  echo "# Written by install.sh (make setup). Do not edit: re-run the wizard."
  printf 'DOTFILES_DIR=%s\n' "$(shell_quote "$DOTFILES_DIR")"
  printf 'DEV_DIR=%s\n' "$(shell_quote "$DEV_DIR")"
  printf 'WORK_DIR=%s\n' "$(shell_quote "$WORK_DIR")"
  if [ -n "${COMPUTER_NAME:-}" ]; then
    printf 'COMPUTER_NAME=%s\n' "$(shell_quote "$COMPUTER_NAME")"
  fi
}

apply_env_file() {
  if is_dry_run; then
    printf '  %s[dry run]%s write custom/dotfiles.env:\n' "$YELLOW" "$RESET"
    env_file_content | sed 's/^/      /'
    return 0
  fi
  env_file_content >"$DOTFILES_DIR/custom/dotfiles.env"
  ok "Answers saved in custom/dotfiles.env"
}

apply_machine_name() {
  [ -n "${COMPUTER_NAME:-}" ] || return 0
  if is_macos; then
    if act "sudo scutil --set ComputerName \"$COMPUTER_NAME\"" sudo scutil --set ComputerName "$COMPUTER_NAME" &&
      act "sudo scutil --set HostName $HOST_NAME" sudo scutil --set HostName "$HOST_NAME" &&
      act "sudo scutil --set LocalHostName $HOST_NAME" sudo scutil --set LocalHostName "$HOST_NAME"; then
      ok "Machine: $COMPUTER_NAME ($HOST_NAME)"
    else
      warn "Machine name not applied"
    fi
  elif command -v hostnamectl >/dev/null 2>&1; then
    if act "sudo hostnamectl set-hostname $HOST_NAME" sudo hostnamectl set-hostname "$HOST_NAME"; then
      ok "Machine: $HOST_NAME"
    else
      warn "Machine name not applied"
    fi
  else
    warn "No hostnamectl. Run by hand: sudo hostname $HOST_NAME"
  fi
}

apply_git() {
  # Back up only when this run changes something (identity, or SSH signing,
  # which apply_ssh writes next).
  gitconfig_changes=no
  [ "$GIT_NAME" != "$OLD_GIT_NAME" ] || [ "$GIT_EMAIL" != "$OLD_GIT_EMAIL" ] && gitconfig_changes=yes
  [ "$SSH_SIGN" = yes ] && [ "$(gitconfig_get user.signingkey)" != "$SSH_KEY.pub" ] && gitconfig_changes=yes
  if [ -f "$HOME/.gitconfig" ] && [ "$gitconfig_changes" = yes ]; then
    backup=$(backup_path "$HOME/.gitconfig")
    act "cp ~/.gitconfig $backup" cp "$HOME/.gitconfig" "$backup"
    note "~/.gitconfig copied to $backup"
  fi
  set_git user.name "$GIT_NAME"
  set_git user.email "$GIT_EMAIL"
  ok "Git identity: $GIT_NAME <$GIT_EMAIL>"
}

write_ssh_config_block() {
  had_content=no
  [ -s "$1" ] && had_content=yes
  {
    [ "$had_content" = yes ] && echo
    echo "# Added by dotfiles install.sh: keep SSH key passphrases in the keychain"
    echo "Host *"
    echo "  IgnoreUnknown UseKeychain"
    echo "  UseKeychain yes"
    echo "  AddKeysToAgent yes"
  } >>"$1"
}

add_allowed_signer() {
  grep -qxF "$2" "$1" 2>/dev/null || printf '%s\n' "$2" >>"$1"
}

apply_ssh() {
  [ -n "$SSH_KEY" ] || return 0
  act "mkdir -p ~/.ssh" mkdir -p "$HOME/.ssh"
  act "chmod 700 ~/.ssh" chmod 700 "$HOME/.ssh"

  if [ "$SSH_CREATE" = yes ]; then
    act "ssh-keygen -t ed25519 -C $GIT_EMAIL -f $SSH_KEY (asks for a passphrase)" \
      ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$SSH_KEY" || die "ssh-keygen failed"
    ok "Key created: $SSH_KEY"
  fi

  ssh_config="$HOME/.ssh/config"
  if ! grep -q 'Added by dotfiles install.sh' "$ssh_config" 2>/dev/null; then
    act "append a Host * block to ~/.ssh/config (IgnoreUnknown UseKeychain, UseKeychain yes, AddKeysToAgent yes)" \
      write_ssh_config_block "$ssh_config"
    ok "~/.ssh/config: keychain and agent enabled"
  fi
  act "chmod 600 ~/.ssh/config" chmod 600 "$ssh_config"
  if is_macos; then
    act "ssh-add --apple-use-keychain $SSH_KEY" ssh-add --apple-use-keychain "$SSH_KEY" ||
      warn "ssh-add failed, the key will be added on first use"
  fi

  if [ "$SSH_SIGN" = yes ]; then
    allowed="$HOME/.ssh/allowed_signers"
    if [ -f "$SSH_KEY.pub" ]; then pub=$(cat "$SSH_KEY.pub"); else pub="<public key of $SSH_KEY>"; fi
    act "add \"$GIT_EMAIL <key>\" to ~/.ssh/allowed_signers" add_allowed_signer "$allowed" "$GIT_EMAIL $pub"
    set_git gpg.format ssh
    set_git user.signingkey "$SSH_KEY.pub"
    set_git gpg.ssh.allowedSignersFile "$allowed"
    set_git commit.gpgsign true
    set_git tag.gpgsign true
    ok "Commits and tags signed with $SSH_KEY.pub"
  fi

  case "$SSH_PLATFORM" in github | both) add_key_github ;; esac
  case "$SSH_PLATFORM" in gitlab | both) add_key_gitlab ;; esac
  [ "$SSH_PLATFORM" = later ] && note "To add the key later: SSH_KEYS.md"
  return 0
}

copy_public_key() {
  if is_dry_run; then
    printf '  %s[dry run]%s copy %s.pub to the clipboard\n' "$YELLOW" "$RESET" "$SSH_KEY"
  elif command -v pbcopy >/dev/null 2>&1; then
    pbcopy <"$SSH_KEY.pub" && ok "Public key copied to the clipboard"
  else
    say "Public key:"
    say "$(cat "$SSH_KEY.pub")"
  fi
}

add_key_github() {
  copy_public_key
  step "GitHub: paste the key, type \"Authentication Key\", then Add SSH key."
  open_url "https://github.com/settings/ssh/new"
  is_dry_run || pause "Press Enter once the key is added…"
  if [ "$SSH_SIGN" = yes ]; then
    step "Add it a second time, type \"Signing Key\"."
    open_url "https://github.com/settings/ssh/new"
    is_dry_run || pause "Press Enter once the signing key is added…"
  fi
}

add_key_gitlab() {
  copy_public_key
  if [ "$SSH_SIGN" = yes ]; then usage="Authentication & Signing"; else usage="Authentication"; fi
  step "GitLab: Add new key, paste the key, usage \"$usage\"."
  open_url "${GITLAB_URL%/}/-/user_settings/ssh_keys"
  is_dry_run || pause "Press Enter once the key is added…"
}

stage_next() {
  stage "Next"
  if is_dry_run; then
    say "Dry run: nothing was written and no command was run."
    say "Run again without --dry-run (or DOTFILES_DRY_RUN) to apply."
    return 0
  fi
  if is_macos; then
    say "make also installs the App Store apps: sign in to the App Store app first,"
    say "or those installs fail."
  fi
  if is_yes_mode; then
    run_make=no
    [ "${DOTFILES_RUN_MAKE:-}" = 1 ] && run_make=yes
  elif confirm "Run make now?" n; then
    run_make=yes
  else
    run_make=no
  fi
  if [ "$run_make" = yes ]; then
    (cd "$DOTFILES_DIR" && make) || die "make failed. Fix it, then run: cd $DOTFILES_DIR && make"
  else
    say "Next:"
    say "  cd $DOTFILES_DIR && make    # brew, App Store apps (mas), mise, oh-my-zsh, links"
  fi
  is_macos && say "  make macos                  # macOS defaults (optional, read macos/defaults.sh first)"
  say "Then open a new terminal."
}

main() {
  for arg in "$@"; do
    case "$arg" in
      --dry-run) DOTFILES_DRY_RUN=1 ;;
      *) die "Unknown option: $arg (only --dry-run is supported)" ;;
    esac
  done

  # Piped from curl, stdin is the script itself: questions read the terminal.
  if ! is_yes_mode && [ ! -t 0 ]; then
    tty_path=${DOTFILES_TTY:-/dev/tty}
    if (exec <"$tty_path") 2>/dev/null; then
      exec <"$tty_path"
    else
      die "No terminal to ask questions. For an unattended install: DOTFILES_YES=1"
    fi
  fi

  # Run from an existing clone (make setup)?
  SELF_DIR=""
  case "$0" in
    */install.sh | install.sh)
      self=$(cd "$(dirname "$0")" && pwd -P)
      [ -d "$self/.git" ] && [ -f "$self/Makefile" ] && SELF_DIR=$self
      ;;
  esac

  if ! is_yes_mode; then
    clear_screen
    title="dotfiles · install"
    is_dry_run && title="dotfiles · install (dry run: nothing will be changed)"
    printf '\n%s%s  %s%s\n\n' "$BOLD" "$BLUE" "$title" "$RESET"
    say "A few questions (Enter keeps the value in brackets), a summary, then the"
    say "install. Ctrl-C to stop: nothing changes before the summary (except, on"
    say "Linux, missing tools and the default shell, once you agree)."
    pause "Ready?"
  fi

  stage_checks
  stage_clone_path
  stage_folders
  stage_git
  stage_machine
  stage_ssh
  stage_recap
  stage_apply
  stage_next
}

main "$@"
