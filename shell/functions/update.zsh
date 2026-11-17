# Update macOS, Homebrew (Brewfile and custom/Brewfile) and mise.
# Homebrew is skipped in an account that doesn't own it (docs/multiple-accounts.md).
update() {
  sudo softwareupdate -i -a
  local prefix owner
  prefix=$(brew --prefix)
  owner=$(ls -ld "$prefix" | awk '{ print $3 }')
  if [[ "$owner" == "$(id -un)" ]]; then
    brew update
    brew upgrade
    brew bundle --file="$HOME/.dotfiles/Brewfile"
    [[ -r "$HOME/.dotfiles/custom/Brewfile" ]] && brew bundle --file="$HOME/.dotfiles/custom/Brewfile"
  else
    echo "update: Homebrew skipped, it belongs to $owner"
  fi
  mise self-update
  mise install
}
