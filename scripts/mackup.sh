#!/bin/sh
# Back up and restore app settings with Mackup, in copy mode, to Dropbox.
# Called by the Makefile.
#
#   mackup.sh config    write ~/.mackup.cfg: Dropbox storage, the folder
#                       MACKUP_DIR from custom/dotfiles.env (default: Mackup),
#                       then the app list of mackup/mackup.cfg
#   mackup.sh backup    config, then copy the settings to Dropbox
#   mackup.sh restore   config, then copy them back (quit the apps first)
#   mackup.sh dry-run   config, then show what backup would copy, copying nothing
#                       (--force: Mackup asks to create the Dropbox folder first,
#                       and stops there without it)
#
# Our own app definitions live in config/mackup/applications/, linked to
# ~/.config/mackup/applications/ by `make link`.

set -eu

REPO=$(cd "$(dirname "$0")/.." && pwd -P)

write_config() {
  if [ -r "$REPO/custom/dotfiles.env" ]; then
    # shellcheck source=/dev/null
    . "$REPO/custom/dotfiles.env"
  fi
  {
    echo "# Written by scripts/mackup.sh from mackup/mackup.cfg. Edit that file instead."
    echo "[storage]"
    echo "engine = dropbox"
    echo "directory = ${MACKUP_DIR:-Mackup}"
    echo
    cat "$REPO/mackup/mackup.cfg"
  } >"$HOME/.mackup.cfg"
}

case "${1:-}" in
  config) write_config ;;
  backup) write_config && mackup backup ;;
  restore) write_config && mackup restore ;;
  dry-run) write_config && mackup --dry-run --force backup ;;
  *)
    echo "usage: mackup.sh config | backup | restore | dry-run" >&2
    exit 1
    ;;
esac
