# zsh loader, sourced by ~/.zshrc. Order matters:
#   1. custom/dotfiles.env (answers of the install wizard, exported)
#   2. shell/: path.sh, exports.sh, aliases.sh, functions/*.zsh
#   3. custom/: the same files, then any other *.sh or *.zsh
# custom/ comes last so private files can override tracked ones. Missing files
# are skipped.

_dotfiles_root="$HOME/.dotfiles"

if [[ -r "$_dotfiles_root/custom/dotfiles.env" ]]; then
  set -a
  source "$_dotfiles_root/custom/dotfiles.env"
  set +a
fi

for _dotfiles_dir in "$_dotfiles_root/shell" "$_dotfiles_root/custom"; do
  for _dotfiles_file in "$_dotfiles_dir"/{path,exports,aliases}.sh "$_dotfiles_dir"/functions/*.zsh(N); do
    [[ -r "$_dotfiles_file" ]] && source "$_dotfiles_file"
  done
done

for _dotfiles_file in "$_dotfiles_root"/custom/*.{sh,zsh}(N); do
  case "${_dotfiles_file:t}" in
    path.sh | exports.sh | aliases.sh) ;;
    *) [[ -r "$_dotfiles_file" ]] && source "$_dotfiles_file" ;;
  esac
done

unset _dotfiles_root _dotfiles_dir _dotfiles_file
