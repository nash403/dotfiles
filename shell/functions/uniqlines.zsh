# Show lines that appear only once
# Source: https://github.com/ain/.dotfiles/commit/967a2e65a44708449b6e93f87daa2721929cb87a
uniqlines() {
  sort $1 | uniq -u
}
