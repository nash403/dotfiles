DOTFILES_DIR := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
OS := $(shell bin/is-supported bin/is-macos macos linux)
PATH := $(DOTFILES_DIR)/bin:$(PATH)
NVM_DIR := $(HOME)/.nvm
export XDG_CONFIG_HOME := $(HOME)/.config
export STOW_DIR := $(DOTFILES_DIR)

.PHONY: test

all: $(OS)

macos: sudo core-macos packages link

linux: core-linux link

core-macos: brew git npm ruby

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

packages: antigen mas brew-packages node-packages gems

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
	is-executable brew || curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install | ruby

git: brew
	brew install git git-extras

npm:
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.2/install.sh | bash
	. $(NVM_DIR)/nvm.sh; nvm install --lts

ruby: brew
	brew install ruby

mas:
	brew install mas

brew-packages: brew
	brew bundle --file=$(DOTFILES_DIR)/Brewfile

node-packages: npm
	. $(NVM_DIR)/nvm.sh; npm install -g $(shell cat npmfile)

gems: ruby
	export PATH="/usr/local/opt/ruby/bin:$PATH"; gem install $(shell cat Gemfile)

antigen:
	curl -L git.io/antigen > $(XDG_CONFIG_HOME)/antigen.zsh