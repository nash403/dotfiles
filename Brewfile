# Homebrew: desktop apps, fonts, App Store apps, and the GNU tools and C libraries
# mise does not provide. Command-line tools live in config/mise/config.toml.
# Private apps go in custom/Brewfile, installed by `make brew` too.

# Formulae
brew 'ack'                       # grep for code
brew 'coreutils'                 # GNU ls, cp, date…
brew 'diff-so-fancy'             # readable git diffs (core.pager)
brew 'docker-credential-helper'  # docker login credentials in the macOS keychain
brew 'exiftool'                  # read and write image metadata
brew 'ffmpeg'                    # convert and record audio/video
brew 'findutils'                 # GNU find, xargs
brew 'fortune'                   # random quotes (cowcat alias)
brew 'git'                       # recent git
brew 'git-extras'                # extra git commands (git summary…)
brew 'gnu-sed'                   # GNU sed
brew 'grep'                      # GNU grep
brew 'imagemagick'               # image manipulation
brew 'libpq'                     # psql client without a Postgres server
brew 'libyaml'                   # needed to build mise's Ruby
brew 'moreutils'                 # sponge, ts, vipe…
brew 'nano'                      # recent nano, with syntax files
brew 'ngrep'                     # grep network traffic (sniff alias)
brew 'nss'                       # lets mkcert install its CA in Firefox
brew 'openssl@3'                 # needed to build mise's Ruby
brew 'qrencode'                  # QR codes in the terminal (qr alias)
brew 'spaceship'                 # zsh prompt
brew 'tree'                      # directory trees
brew 'wget'                      # downloads
brew 'zsh-syntax-highlighting'   # colors commands as you type

if OS.mac?
  brew 'mas'                     # installs the App Store apps below
  brew 'wifi-password'           # shows the current Wi-Fi password

  tap 'rajivm1991/droiddock'
  # Popcorn Time: neither the cask nor its tap exist anymore.
  # cask 'popcorn-time'

  # Apps
  cask 'adapter'               # convert video, audio and images
  cask 'adobe-acrobat-reader'  # PDF reader
  cask 'aerial'                # Apple TV screensaver
  cask 'airflow'               # stream videos to Apple TV / Chromecast
  cask 'alfred'                # launcher and workflows
  cask 'apparency'             # inspect app bundles
  cask 'background-music'      # per-app volume, system audio recording
  cask 'betterzip'             # create and edit archives
  cask 'calibre'               # e-book library
  cask 'cardinal-search'       # fast file search
  cask 'claude'                # Claude desktop app
  cask 'cryptomator'           # encrypt cloud files
  cask 'cyberduck'             # FTP/SFTP/S3 browser
  cask 'dash'                  # offline API docs
  cask 'discord'               # chat
  cask 'rajivm1991/droiddock/droiddock', trusted: true  # Android device manager
  cask 'dropbox'               # cloud storage
  cask 'enpass'                # password manager
  cask 'ferdium'               # all messaging apps in one window
  cask 'firefox'               # browser
  cask 'ghostty'               # terminal
  cask 'google-chrome'         # browser
  cask 'imageoptim'            # compress images
  cask 'insomnia'              # HTTP/GraphQL client
  cask 'linear'                # issue tracking
  cask 'mole-app'              # clean up and monitor the Mac
  cask 'ngrok'                 # expose a local port
  cask 'notion'                # notes and docs
  cask 'opencode-desktop'      # opencode desktop client
  cask 'slack'                 # team chat
  cask 'superwhisper'          # dictation with AI rewording
  cask 'suspicious-package'    # inspect .pkg installers
  cask 'the-unarchiver'        # extract archives
  cask 'visual-studio-code'    # editor
  cask 'vlc'                   # media player
  cask 'whatsapp'              # messaging
  cask 'zed'                   # editor

  # Quick Look previews
  cask 'qlmarkdown'            # Markdown
  cask 'quicklook-video'       # videos
  cask 'syntax-highlight'      # source code, JSON and other text files

  # Fonts
  cask 'font-fira-code'
  cask 'font-karla'
  cask 'font-meslo-for-powerline'
  cask 'font-meslo-lg'
  cask 'font-meslo-lg-nerd-font'
  cask 'font-mononoki'
  cask 'font-roboto'

  # App Store (sign in to the App Store app first)
  mas 'Amphetamine', id: 937984704      # keep the Mac awake
  mas 'Color Picker', id: 1545870783    # color picker
  mas 'Dato', id: 1470584107            # calendar in the menu bar
  mas 'Goodnotes', id: 1444383602       # handwritten notes
  mas 'Zen IPTV', id: 6458223193        # IPTV player
  # Last: once installed, brew stops until its license is accepted (make xcode-license)
  mas 'Xcode', id: 497799835
end
