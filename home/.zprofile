# Read once by login shells, before ~/.zshrc: the base PATH lives here.

for _brew in /opt/homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  if [ -x "$_brew" ]; then
    eval "$("$_brew" shellenv)"
    break
  fi
done
unset _brew

# mise and other user-installed binaries
export PATH="$HOME/.local/bin:$PATH"

# mise shims, so non-interactive login shells (zsh -l -c, git hooks run by a GUI
# client) find mise tools without the prompt hook ~/.zshrc sets up.
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh --shims)"
fi
