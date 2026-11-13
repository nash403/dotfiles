# Interactive zsh. The base PATH is set in ~/.zprofile; aliases, exports and
# functions live in ~/.dotfiles/shell/ and your private custom/ folder.

# mise first: the oh-my-zsh plugins fzf, bun and httpie look up their command
# when they load.
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

# Completions installed outside Homebrew (e.g. by mise tools)
fpath+=("$HOME/.local/share/zsh/site-functions")

# oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"

# Spaceship prompt: the Homebrew formula when present, else the oh-my-zsh theme
# cloned by older versions of this repo.
_spaceship="${HOMEBREW_PREFIX:-/opt/homebrew}/opt/spaceship/spaceship.zsh"
if [ -r "$_spaceship" ]; then
  ZSH_THEME=""
else
  ZSH_THEME="spaceship"
fi
SPACESHIP_TIME_SHOW="true"

zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 13
ZSH_DISABLE_COMPFIX="true"
HIST_STAMPS="yyyy-mm-dd"

plugins=(
  aliases
  fzf
  git
  isodate
  bun
  httpie
  ssh
  universalarchive
  z
  zsh-interactive-cd
)

# oh-my-zsh runs compinit itself.
[ -r "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"

[ -z "$ZSH_THEME" ] && source "$_spaceship"
unset _spaceship

# History: keep one copy of each command (sizes are in shell/exports.sh)
setopt HIST_IGNORE_ALL_DUPS

# Dotfiles: after the plugins, so our aliases can override theirs.
[ -r "$HOME/.dotfiles/shell/init.zsh" ] && source "$HOME/.dotfiles/shell/init.zsh"

# Syntax highlighting must be loaded last.
_zsh_hl="${HOMEBREW_PREFIX:-/opt/homebrew}/share/zsh-syntax-highlighting"
if [ -r "$_zsh_hl/zsh-syntax-highlighting.zsh" ]; then
  export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR="$_zsh_hl/highlighters"
  source "$_zsh_hl/zsh-syntax-highlighting.zsh"
fi
unset _zsh_hl
