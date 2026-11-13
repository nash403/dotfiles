# Aliases, grouped by topic. Loaded by zsh and bash: keep it POSIX-compatible.
# Private aliases go in custom/aliases.sh, loaded after this file.

###############################################################################
# Shell
###############################################################################

alias reload!='. ~/.zshrc; echo "Reloaded .zshrc..."'
alias zshconfig="nano ~/.zshrc"
# Open the oh-my-zsh install in Zed
alias ohmyzsh="zed ~/.oh-my-zsh"
alias c='clear'
# Names of the defined aliases, without their value
alias listaliases="alias | sed 's/=.*//'"
# Names of the defined functions, skipping the _private ones
alias listfunctions="declare -f | grep '^[a-z].* ()' | sed 's/{$//'"
# Print each PATH entry on its own line
alias paths='echo -e ${PATH//:/\\n}'
# Intuitive map function: run a command once per input line.
# e.g. list the folders that hold a .gitattributes: find . -name .gitattributes | map dirname
alias map="xargs -n1"
alias makex="chmod a+x"

###############################################################################
# Navigation
###############################################################################

# DEV_DIR and WORK_DIR come from custom/dotfiles.env (install wizard)
alias dev='cd "${DEV_DIR:-$HOME/dev}"'
alias work='cd "${WORK_DIR:-$HOME/work}"'
alias dotf="cd ~/.dotfiles"
alias db="cd ~/Dropbox"
alias dl="cd ~/Downloads"
alias dt="cd ~/Desktop"
alias docs="cd ~/Documents"

###############################################################################
# Files and ls
###############################################################################

# Recursive listing sorted by date, with type markers and human sizes
alias lr='ls -tRFh'
# Hidden files and folders of the current folder
alias ldot='ls -ld .*'
# Hidden files, one per line, oldest change first
alias ldotname='ls -ld1Fcart .*'
# All files, one per line, oldest change first
alias laname='ls -1Fcart'
# Files, one per line, oldest modification first
alias lname='ls -1Fcrt'

alias t='tail'
alias hd='head'

alias rmi='rm -i'
alias rmd='rm -r'
alias rmdf='rm -rf'
alias cpi='cp -i'
alias mvi='mv -i'

# Recursively delete `.DS_Store` files
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"
# Size of every node_modules folder below the current one
alias nmodulessize="find . -name 'node_modules' -type d -prune -print | xargs du -chs"
# Delete every node_modules folder below the current one
alias nmodulesrm="find . -name 'node_modules' -type d -prune -print -exec rm -rf '{}' \;"
# Delete every .git folder below the current one (un-gits the tree)
alias gitrm="find . -name '.git' -type d -prune -print -exec rm -rf '{}' \;"

# `open`, `pbcopy` and `pbpaste` on Linux and WSL, so `o`, `copy` and the
# clipboard aliases work there too (X11 needs xclip, Wayland wl-clipboard)
if [ "$(uname -s)" != 'Darwin' ]; then
  if grep -q Microsoft /proc/version 2>/dev/null; then
    alias open='explorer.exe'
    alias pbcopy='clip.exe'
    alias pbpaste='powershell.exe -noprofile -command Get-Clipboard'
  else
    alias open='xdg-open'
    if command -v wl-copy >/dev/null 2>&1; then
      alias pbcopy='wl-copy'
      alias pbpaste='wl-paste'
    elif command -v xclip >/dev/null 2>&1; then
      alias pbcopy='xclip -selection clipboard'
      alias pbpaste='xclip -selection clipboard -o'
    fi
  fi
fi

###############################################################################
# Clipboard
###############################################################################

# Trim new lines and copy to clipboard
alias copy="tr -d '\n' | pbcopy && echo 'Copied to clipboard.'"
# Copy the public SSH key
alias copy_ssh="cat ~/.ssh/id_ed25519.pub | tr -d '\n' | pbcopy && echo 'Copied to clipboard.'"

###############################################################################
# System and machine info
###############################################################################

# Get macOS Software Updates, and update package managers and their installed packages
alias update='sudo softwareupdate -i -a; brew update; brew upgrade; brew bundle --file="$HOME/.dotfiles/Brewfile"; [ -r "$HOME/.dotfiles/custom/Brewfile" ] && brew bundle --file="$HOME/.dotfiles/custom/Brewfile"; mise self-update; mise install'
alias reboot='sudo shutdown -r now'
alias shutdown='sudo shutdown -h now'
alias displays="system_profiler SPDisplaysDataType"
alias cpuinfo="sysctl -n machdep.cpu.brand_string"
# Processes sorted by CPU, then by memory
alias cpu='top -o cpu'
alias mem='top -o rsize'
# ISO week number
alias week='date +%V'
alias datenow='date +%Y.%m.%d.%H%M%S'
alias datenowUTC='date -u +%Y.%m.%d.%H%M%SZ'
# Folder of the mkcert root certificate
alias wherecertif="mkcert -CAROOT"

###############################################################################
# Network
###############################################################################

# Public IP, then the local IP of the Wi-Fi interface
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
# Names of the network interfaces that are up (status: active)
# shellcheck disable=SC2142 # $1 is awk's first field, not a shell parameter
alias ifactive="ifconfig | awk '/^[a-z]/ { iface = \$1 } /status: active/ { sub(\":\", \"\", iface); print iface }'"
# Show ports in use
alias portsinuse="sudo lsof -i -n -P | grep TCP"
# alternatively use `sudo lsof -nP -i4TCP:$PORT | grep LISTEN` for a specific port, replace $PORT
# alternatively use `sudo lsof -i -P | grep LISTEN | grep :$PORT` for a specific port with hostname resolution, this one may take minutes, replace $PORT
# View HTTP traffic (plain HTTP on port 80 only: HTTPS is encrypted)
# sniff: print each GET/POST request line as it crosses the network interface,
# with a timestamp (ngrep)
# (en0 is the Wi-Fi interface on Apple Silicon Macs)
alias sniff="sudo ngrep -d 'en0' -t '^(GET|POST) ' 'tcp and port 80'"
# httpdump: capture every packet (tcpdump) and keep only the "Host:" headers and
# "GET /path" lines, i.e. which sites and pages are being requested
alias httpdump="sudo tcpdump -i en0 -n -s 0 -w - | grep -a -o -E \"Host\: .*|GET \/.*\""
# Serve the current folder on http://localhost:8000
alias pyserver='open http://localhost:8000 && python3 -m http.server 8000'
# URL-encode a string: urlencode "a b&c"
alias urlencode='python3 -c "import sys, urllib.parse as p; print(p.quote_plus(sys.argv[1]))"'

###############################################################################
# Package managers
###############################################################################

# npm
alias ni='npm install'
alias nid='npm install --save-dev'
alias nis='npm install --save'
alias nr='npm run'
alias ns='npm start'
alias nd='npm run dev'
alias nig='npm install -g'
alias nlsg="npm list -g --depth=0 2>/dev/null"
alias nls="npm list --depth=0 2>/dev/null"

# pnpm
alias pn='pnpm'
alias pni='pnpm install'
alias pna='pnpm add'
alias pnad='pnpm add -D'
alias pnao='pnpm add -O'
alias pnag='pnpm add -g'
alias pns='pnpm start'
alias pnd='pnpm dev'
# Run a script in every workspace package that has it, in parallel
alias pnp='pnpm --if-present --parallel'
# Run in one workspace package: pnf <package> <command>
alias pnf='pnpm -F'

# bun
alias buni='bun install'
alias buna='bun add'
alias bunad='bun add -D'
alias bunao='bun add --optional'
alias bunag='bun add -g'
alias bunlk='bun link'
alias bununlk='bun unlink'
alias buns='bun run start'
alias bund='bun run dev'
alias bunupf='bun update -f'

# yarn: show the global packages manifest
alias yarnglobalpkg='cat $(yarn global dir)/package.json'

###############################################################################
# Git (on top of the oh-my-zsh git plugin)
###############################################################################

alias ggpullr='ggpull --rebase'
# Zip of HEAD, without untracked files
alias garch='git archive HEAD --format=zip'
# All branches, local and remote, with their upstream and last commit
alias gball='git branch -a -vv'
# Commit subjects since the last tag
alias gchangelog='git log "$(git describe --tags --abbrev=0 2>/dev/null)..HEAD" --oneline | cut -d " " -f 2-'

###############################################################################
# Containers and Kubernetes
###############################################################################

alias lzd="lazydocker"
alias lzg="lazygit"
alias dcu="docker compose up"
alias dcud="docker compose up -d"
alias dcd="docker compose down"
# Colima status, current docker context and DOCKER_HOST at a glance
alias dck='colima status 2>&1 | head -1; echo "context: $(docker context show)"; echo "DOCKER_HOST: ${DOCKER_HOST:-<empty>}"'
alias k="kubectl"
alias kns="kubens"
alias ktx="kubectx"

###############################################################################
# Editors
###############################################################################

# Open a file with the editor picked by its type (see bin/editor)
alias e="editor"

###############################################################################
# AI tools
###############################################################################

# Claude Code with the separate work configuration
alias claude-work='CLAUDE_CONFIG_DIR="$HOME/.claude-work" claude'

###############################################################################
# Media
###############################################################################

# Download a video to the Desktop / its audio as MP3 (yt-dlp, from mise)
alias youtube='yt-dlp -P ~/Desktop'
alias youtube-mp3='yt-dlp -x --audio-format mp3'
# Mute, or max the volume
alias stfu="osascript -e 'set volume output muted true'"
alias pumpitup="osascript -e 'set volume output volume 100'"
# QR code of the given text in the terminal
alias qr="qrencode -t ANSI"

###############################################################################
# Fun
###############################################################################

alias shrug="printf '¯\_(ツ)_/¯' | pbcopy"
alias flipt="printf '(╯°□°)╯︵ ┻━┻' | pbcopy"
alias fight="printf '(ง'̀-'́)ง' | pbcopy"
alias nomnom='killall'
alias cowcat='fortune | cowsay | lolcat'
