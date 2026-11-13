export XDG_CONFIG_HOME="$HOME/.config"
# nano everywhere, like git's core.editor: crontab -e, kubectl edit, gh and mise
# wait for the editor to close, which GUI editors do not. `e` opens bin/editor.
export EDITOR="nano"
export VISUAL="nano"
# Editor that dev servers (Vite, React…) open when you click an error
export LAUNCH_EDITOR=code
export LANG=en_US.UTF-8

# Opt out homebrew analytics
export HOMEBREW_NO_ANALYTICS=1

# Enable persistent REPL history for `node`.
export NODE_REPL_HISTORY=~/.node_history
# Allow 32³ entries; the default is 1000.
export NODE_REPL_HISTORY_SIZE='32768'
# Use sloppy mode by default, matching web browsers.
export NODE_REPL_MODE='sloppy'

# Make Python use UTF-8 encoding for output to stdin, stdout, and stderr.
export PYTHONIOENCODING='UTF-8'

# History: zsh keeps SAVEHIST lines on disk, HISTSIZE in memory; bash uses
# HISTFILESIZE and HISTCONTROL. zsh's duplicate handling is set in ~/.zshrc.
export HISTSIZE=32768
export SAVEHIST="$HISTSIZE"
export HISTFILESIZE="$HISTSIZE"
export HISTCONTROL=ignoredups:erasedups

# Don’t clear the screen after quitting a manual page.
export MANPAGER='less -X'

# Docker with colima: to make tools that ignore Docker contexts use colima, link
# its socket to the default path (may break other Docker servers):
#   sudo ln -sf $HOME/.colima/default/docker.sock /var/run/docker.sock
# or point them to it:
#   export DOCKER_HOST="unix://${HOME}/.colima/default/docker.sock"
