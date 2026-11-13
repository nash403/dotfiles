# Git clone the URL in the clipboard (was `gcb`, hidden by oh-my-zsh's
# `gcb` = git checkout -b). To clone and cd, oh-my-zsh has `gccd`.
gcclip() {
  git clone "$(pbpaste)"
}
