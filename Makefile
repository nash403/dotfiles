# `make` installs everything; `make help` lists the other targets.

SHELL := /bin/sh
DOTFILES_DIR := $(patsubst %/,%,$(dir $(realpath $(firstword $(MAKEFILE_LIST)))))
export XDG_CONFIG_HOME := $(HOME)/.config
# Tools installed earlier in the same `make` run must be found by later steps.
export PATH := /opt/homebrew/bin:/home/linuxbrew/.linuxbrew/bin:$(HOME)/.local/bin:$(HOME)/.local/share/mise/shims:$(DOTFILES_DIR)/bin:$(PATH)
OS := $(shell uname -s)
ARCH := $(shell uname -m)

.PHONY: help all homebrew link unlink detach backups brew mise apps ohmyzsh setup setup-dry workdirs macos mackup-backup mackup-restore mackup-dry test lint

.DEFAULT_GOAL := all

##@ General

# Lists every target with a `## description` on its line, grouped by the `##@` headings.
help: ## Show this help
	@awk 'BEGIN { FS = ":.*## "; printf "\nUsage:\n  make \033[36m<target>\033[0m\n" } \
		/^[a-zA-Z0-9_.-]+:.*## / { printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2 } \
		/^##@ / { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) }' $(MAKEFILE_LIST)

##@ Install

ifeq ($(OS),Darwin)
all: homebrew link brew mise apps ohmyzsh ## Install everything (default target)
else
all: homebrew link brew mise ohmyzsh
endif

# Homebrew itself. Not NONINTERACTIVE on a terminal: it must ask for the sudo password.
homebrew: ## Install Homebrew
	@command -v brew >/dev/null 2>&1 && exit 0; \
	if [ "$${DOTFILES_YES:-}" = 1 ]; then export NONINTERACTIVE=1; fi; \
	/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || { \
		echo "make homebrew: on \"Insufficient permissions\", run make from a terminal, as an administrator, without DOTFILES_YES." >&2; exit 1; }

##@ Symlinks

# Symlinks home/ -> ~ and config/ -> ~/.config (see scripts/links.sh)
link: ## Symlink home/ to ~ and config/ to ~/.config
	@sh "$(DOTFILES_DIR)/scripts/links.sh" link

unlink: ## Remove the symlinks, restore the files you had before
	@sh "$(DOTFILES_DIR)/scripts/links.sh" unlink

backups: ## List the .bak files left to sort
	@sh "$(DOTFILES_DIR)/scripts/links.sh" backups

# Replace every symlink of $HOME (top level) and $XDG_CONFIG_HOME (recursive) that
# points into this repo with a copy of its content, except ~/.dotfiles itself.
# The copied ~/.zshrc still sources ~/.dotfiles/shell/init.zsh.
detach: ## Replace the symlinks with copies
	@repo=$$(cd "$(DOTFILES_DIR)" && pwd -P); \
	{ find "$(HOME)" -mindepth 1 -maxdepth 1 -type l; find "$(XDG_CONFIG_HOME)" -type l 2>/dev/null; } | \
	{ n=0; \
	while IFS= read -r link; do \
		[ "$$link" = "$(HOME)/.dotfiles" ] && continue; \
		target=$$(readlink -f "$$link" 2>/dev/null) || continue; \
		case "$$target" in "$$repo"/*) ;; *) continue ;; esac; \
		unlink "$$link" && cp -R "$$target" "$$link" && n=$$((n + 1)) && echo "  copied $$link  (was -> $$target)"; \
	done; \
	echo "$$n symlink(s) replaced by copies."; }

##@ Packages and apps

# Formulae, apps, fonts and App Store apps; then the private custom/Brewfile
brew: ## Install the Brewfile, then custom/Brewfile
	brew bundle --file="$(DOTFILES_DIR)/Brewfile"
	@if [ -f "$(DOTFILES_DIR)/custom/Brewfile" ]; then brew bundle --file="$(DOTFILES_DIR)/custom/Brewfile"; fi

# Command-line tools and runtimes (config/mise/config.toml, linked by `make link`)
mise: ## Install the CLI tools and runtimes with mise
	@command -v mise >/dev/null 2>&1 || curl -fsSL https://mise.run | sh
	mise trust "$(DOTFILES_DIR)/mise.toml"
	cd "$(DOTFILES_DIR)" && mise install
	@$(MAKE) --no-print-directory docker-plugins

# Docker without Docker Desktop: compose and buildx plugins point to mise shims
# (stable paths across updates), dead links to Docker.app go, and `docker login`
# stores credentials in the macOS keychain.
.PHONY: docker-plugins
docker-plugins:
	@plugins="$(HOME)/.docker/cli-plugins"; shims="$(HOME)/.local/share/mise/shims"; \
	mkdir -p "$$plugins"; \
	for p in docker-compose docker-buildx; do \
		if [ -x "$$shims/$$p" ]; then ln -sfn "$$shims/$$p" "$$plugins/$$p"; fi; \
	done; \
	for link in "$$plugins"/*; do \
		if [ -L "$$link" ] && [ ! -e "$$link" ]; then unlink "$$link" && echo "  removed dead plugin link $$link"; fi; \
	done; \
	config="$(HOME)/.docker/config.json"; \
	if [ "$(OS)" = Darwin ] && [ -f "$$config" ] && [ "$$(jq -r '.credsStore // empty' "$$config")" = desktop ]; then \
		jq '.credsStore = "osxkeychain"' "$$config" >"$$config.tmp" && mv "$$config.tmp" "$$config" && echo "  docker credsStore: desktop -> osxkeychain"; \
	fi

# Apps without a Homebrew cask, from their GitHub releases (bin/install-dmg-app)
ifeq ($(ARCH),arm64)
ORCA_DMG := orca-macos-arm64\.dmg$$
else
ORCA_DMG := orca-macos-x64\.dmg$$
endif
apps: ## Install the apps without a Homebrew cask (macOS only)
	@install-dmg-app tonyantony300/dashbeam '_universal\.dmg$$' DashBeam.app
	@install-dmg-app erictli/scratch '_universal\.dmg$$' Scratch.app
	@install-dmg-app stablyai/orca '$(ORCA_DMG)' Orca.app

# oh-my-zsh, keeping our ~/.zshrc and without starting a new zsh
ohmyzsh: ## Install oh-my-zsh, keeping ~/.zshrc
	@if [ ! -d "$(HOME)/.oh-my-zsh" ]; then \
		RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; \
	fi

##@ Setup

# Run the install wizard again from this clone
setup: ## Run the install wizard again
	@sh "$(DOTFILES_DIR)/install.sh"

# Ask the wizard's questions and show what it would write and run, changing nothing
setup-dry: ## Show what the wizard would write and run, changing nothing
	@sh "$(DOTFILES_DIR)/install.sh" --dry-run

workdirs: ## Create the dev and work folders
	@if [ -r "$(DOTFILES_DIR)/custom/dotfiles.env" ]; then . "$(DOTFILES_DIR)/custom/dotfiles.env"; fi; \
	mkdir -p "$${DEV_DIR:-$(HOME)/dev}" "$${WORK_DIR:-$(HOME)/work}"

# macOS defaults (opt-in). Read macos/defaults.sh first.
macos: ## Apply the macOS defaults (macOS only; read macos/defaults.sh first)
	@if [ -r "$(DOTFILES_DIR)/custom/dotfiles.env" ]; then . "$(DOTFILES_DIR)/custom/dotfiles.env"; fi; \
	COMPUTER_NAME="$${COMPUTER_NAME:-}" bash "$(DOTFILES_DIR)/macos/defaults.sh"

##@ App settings (Mackup)

# App settings <-> Dropbox folder chosen in the wizard, with Mackup (copy mode).
# The app list is mackup/mackup.cfg; our definitions are in config/mackup/.
mackup-backup: ## Copy the app settings to Dropbox
	@sh "$(DOTFILES_DIR)/scripts/mackup.sh" backup

# Quit the apps first: a running app can overwrite its restored settings.
mackup-restore: ## Copy them back (quit the apps first)
	@sh "$(DOTFILES_DIR)/scripts/mackup.sh" restore

# What mackup-backup would copy, copying nothing
mackup-dry: ## Show what mackup-backup would copy
	@sh "$(DOTFILES_DIR)/scripts/mackup.sh" dry-run

##@ Checks

# `make test`, or one file: `make test T=test/functions/gwtaa.bats`
T ?= -r test
test: ## Run the bats tests (one file: T=test/...bats)
	@command -v zsh >/dev/null 2>&1 || { echo "make test: zsh is required (brew install zsh / apt-get install zsh)" >&2; exit 1; }
	@command -v bats >/dev/null 2>&1 || { echo "make test: bats is missing, run: mise install" >&2; exit 1; }
	bats --timing --print-output-on-failure $(T)

SH_SCRIPTS := install.sh scripts/links.sh scripts/mackup.sh
BASH_SCRIPTS := bin/editor bin/install-dmg-app bin/is-executable bin/is-macos bin/is-supported macos/defaults.sh shell/init.bash shell/path.sh shell/exports.sh shell/aliases.sh
ZSH_FILES := shell/init.zsh $(wildcard shell/functions/*.zsh) home/.zshrc home/.zprofile home/.zshenv
lint: ## Run shellcheck and zsh -n
	@cd "$(DOTFILES_DIR)" && \
	shellcheck -s sh $(SH_SCRIPTS) && echo "shellcheck (sh) on $(words $(SH_SCRIPTS)) files: OK" && \
	shellcheck -s bash $(BASH_SCRIPTS) && echo "shellcheck (bash) on $(words $(BASH_SCRIPTS)) files: OK" && \
	for f in $(ZSH_FILES); do zsh -n "$$f" || exit 1; done && echo "zsh -n on $(words $(ZSH_FILES)) files: OK"
