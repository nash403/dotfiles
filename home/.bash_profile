# A bash login shell does not read ~/.bashrc on its own.
[ -r "$HOME/.bashrc" ] && . "$HOME/.bashrc"
