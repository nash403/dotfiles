DOTFILES_DIR := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
export STOW_DIR := $(DOTFILES_DIR)
export XDG_CONFIG_HOME := $(HOME)/.config
OS := $(shell bin/is-supported bin/is-macos macos linux)
PATH := $(DOTFILES_DIR)/bin:$(PATH)
NVM_DIR := $(HOME)/.config/nvm

.PHONY: test

all: workdirs $(OS)

macos: sudo core-macos packages link

linux: core-linux link

core-macos: brew git node pnpm ruby

core-linux:
	apt-get update
	apt-get upgrade -y
	apt-get dist-upgrade -f

stow-macos: brew
	is-executable stow || brew install stow

stow-linux: core-linux
	is-executable stow || apt-get -y install stow

sudo:
	sudo -v
	while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

packages: mas brew-packages node-packages gems ohmyzsh

link: stow-$(OS)
	for FILE in $$(\ls -A run); do if [ -f $(HOME)/$$FILE -a ! -h $(HOME)/$$FILE ]; then mv -v $(HOME)/$$FILE{,.bak}; fi; done
	mkdir -p $(XDG_CONFIG_HOME)
	stow -t $(HOME) run
	stow -t $(XDG_CONFIG_HOME) config

unlink: stow-$(OS)
	stow --delete -t $(HOME) run
	stow --delete -t $(XDG_CONFIG_HOME) config
	for FILE in $$(\ls -A run); do if [ -f $(HOME)/$$FILE.bak ]; then mv -v $(HOME)/$$FILE.bak $(HOME)/$${FILE%%.bak}; fi; done

brew:
	echo >> "/Users/$(whoami)/.zprofile"
	echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "/Users/$(whoami)/.zprofile"
	eval "$(/opt/homebrew/bin/brew shellenv)"
	is-executable brew || /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"


git: brew
	brew install git git-extras

pnpm:
	brew install pnpm

node:
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
	. $(NVM_DIR)/nvm.sh; nvm install --lts

bun:
	curl -fsSL https://bun.sh/install | bash

ruby: brew
	brew install ruby

mas:
	brew install mas

brew-packages: brew
	brew bundle --file=$(DOTFILES_DIR)/Brewfile
	# Install brews that cannot be installed via a Brewfile (see https://github.com/Homebrew/homebrew-bundle/#note)
	# brew cask install https://raw.githubusercontent.com/popcorn-official/popcorn-desktop/development/casks/popcorn-time.rb

node-packages: node bun
	. $(NVM_DIR)/nvm.sh; pnpm add -g $(shell cat npmfile)

gems: ruby
	export PATH="/usr/local/opt/ruby/bin:$(PATH)"; sudo gem install $(shell cat Gemfile)

ohmyzsh:
	-curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash
	git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$(XDG_CONFIG_HOME)/oh-my-zsh/themes/spaceship-prompt" --depth=1 || echo "spaceship-prompt directory already exists"
	mkdir -p "$(HOME)/.oh-my-zsh/themes"; ln -s "$(XDG_CONFIG_HOME)/oh-my-zsh/themes/spaceship-prompt/spaceship.zsh-theme" "$(HOME)/.oh-my-zsh/themes"  || echo "could not link spaceship-prompt theme file"

workdirs:
	mkdir -p "$(XDG_CONFIG_HOME)"
	mkdir -p "$(HOME)/dev"
	mkdir -p "$(HOME)/work"
