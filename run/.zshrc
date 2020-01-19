# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH
export DOTFILES=$HOME/.dotfiles

#Load antigen
source ~/.config/antigen.zsh
# Load the oh-my-zsh's library.
antigen use oh-my-zsh

# Bundles from the default repo (robbyrussell's oh-my-zsh).
antigen bundle git
antigen bundle command-not-found
antigen bundle npm
antigen bundle yarn
antigen bundle nvm
antigen bundle brew
antigen bundle sudo
antigen bundle zsh-nvm
antigen bundle https://github.com/tomsquest/nvm-auto-use.zsh/ nvm-auto-use.zsh

# Syntax highlighting bundle.
antigen bundle zsh-users/zsh-syntax-highlighting

# Load the theme.
antigen theme spaceship

# Tell Antigen that you're done.
antigen apply

SPACESHIP_TIME_SHOW="true"
HIST_STAMPS="yyyy-mm-dd"

source ~/.zsh_profile
source ~/.path
source ~/.exports
source ~/.alias
source ~/.function
source ~/.function_ls
source ~/.function_network
source ~/.function_text
source ~/.custom

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

alias zshconfig="nano ~/.zshrc"
# alias ohmyzsh="nano ~/.oh-my-zsh"
# alias theme="echo $RANDOM_THEME"
alias reload!='. ~/.zshrc'
