# .files

> These are my dotfiles. Take anything you want, but at your own risk.

It is intended to target macOS systems with zsh shell.


## Overview

![](https://imgs.xkcd.com/comics/borrow_your_laptop.png)

- [Homebrew](https://brew.sh) (packages: [Brewfile](./Brewfile))
- [Node.js + npm LTS](https://nodejs.org/en/download/) (packages: [npmfile](./npmfile))
- Latest Ruby (packages: [Gemfile](./Gemfile))
- Latest Git, Python 3, wget, ...
- [Mackup](https://github.com/lra/mackup) (sync application settings)

## On fresh install...

### Prerequisites

    sudo softwareupdate -i -a
    xcode-select --install

The Xcode Command Line Tools includes `git` and `make` (not available on stock macOS).
Then, install this repo with `curl` available:

    curl -o- https://raw.githubusercontent.com/nash403/dotfiles/master/remote-install.sh | bash

This will clone (using `git`), or download (using `curl` or `wget`), this repo to `~/projects/dotfiles` and symlink it to `~/.dotfiles`. Alternatively, clone manually into the desired location:

    git clone https://github.com/nash403/dotfiles.git ~/projects/dotfiles
    ln -s /the/full/path/to/where/you/cloned/dotfiles ~/.dotfiles

### Init everything

Use the [Makefile](./Makefile) to install everything [listed above](#overview), and symlink [run](./run) and [config](./config) (using [stow](https://www.gnu.org/software/stow/)):

    cd ~/.dotfiles
    make

## Post-install

### Specify the `$PATH`

If `~/.path` exists, it will be sourced along with the other files.

Here’s an example `~/.path` file that adds `/usr/local/bin` to the `$PATH`:

```bash
export PATH="/usr/local/bin:$PATH"
```

### Mackup

  - Log in to Dropbox (and wait until synced)
  - `ln -s ~/.config/mackup/.mackup.cfg ~` (until [#632](https://github.com/lra/mackup/pull/632) is fixed)
  - `mackup restore`

### Sensible macOS defaults

When setting up a new Mac, you may want to set some sensible macOS defaults:

```bash
./.macos
```

Definitely go through and check each [setting](./run/.macos) before running, this can change some major things!

## Customize/extend

You can put your custom settings, such as Git credentials in the `system/.custom` file which will be sourced from `.zshrc` automatically. This file is in `.gitignore`.

## Additional resources & Credits

Where I mainly ~~stole ideas~~ got inspiration from:
  - [webpro's dotfiles](https://github.com/webpro/dotfiles)
  - [Dennis Muensterer's dotfiles](https://github.com/dnnsmnstrr/dotfiles)
  - and of course [Mathias Bynens' dotfiles](https://github.com/mathiasbynens/dotfiles)

Other resources:
  - [Homebrew](https://brew.sh)
  - [Antigen](http://antigen.sharats.me/)
  - [Mac App Store CLI](https://github.com/mas-cli/mas)
  - [Spaceship prompt](https://github.com/denysdovhan/spaceship-prompt)
  - [NVM](https://github.com/nvm-sh/nvm)

Many thanks to the [dotfiles community](https://dotfiles.github.io).

## License

[MIT](./LICENSE) - Copyright (c) 2020-present [Honoré Nintunze](https://twitter.com/nash_403)