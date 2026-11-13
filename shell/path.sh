# PATH entries. Homebrew and ~/.local/bin (mise) come from ~/.zprofile.
# Entries for tools that may not be installed are guarded, so they only appear
# once the tool is there (open a new terminal after installing it).

# dotfiles utilities (bin/editor, bin/is-macos…)
export PATH="$HOME/.dotfiles/bin:$PATH"

# user bin
export PATH="$PATH:$HOME/bin"

# Binaries of the current project's node_modules, last so that a system command
# with the same name always wins. Accepted risk: a malicious package could add
# a command you don't have elsewhere.
export PATH="$PATH:./node_modules/.bin"

# Homebrew prefix, also for bash, which does not read ~/.zprofile
_brew_prefix=${HOMEBREW_PREFIX:-/opt/homebrew}

# Postgres client (libpq) without a full Postgres server
[ -d "$_brew_prefix/opt/libpq/bin" ] && export PATH="$_brew_prefix/opt/libpq/bin:$PATH"

# GNU coreutils under their usual names (ls, cp, date…) instead of the BSD ones
[ -d "$_brew_prefix/opt/coreutils/libexec/gnubin" ] && export PATH="$_brew_prefix/opt/coreutils/libexec/gnubin:$PATH"

unset _brew_prefix

# Android SDK (installed by Android Studio, which does not touch the PATH)
export ANDROID_HOME="$HOME/Library/Android/sdk"
if [ -d "$ANDROID_HOME" ]; then
  export ANDROID_SDK_ROOT="$ANDROID_HOME"
  export PATH="$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools"
  [ -d "$ANDROID_HOME/cmdline-tools/latest/bin" ] && export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
fi

# Console Ninja (Wallaby.js)
[ -d "$HOME/.console-ninja/.bin" ] && export PATH="$HOME/.console-ninja/.bin:$PATH"

# Keep `[ … ] && export` lines from leaving a failed status behind
true
