# bash loader, sourced by ~/.bashrc. Same order as init.zsh, without the zsh-only
# files (functions/*.zsh, custom/*.zsh):
#   1. custom/dotfiles.env (exported)
#   2. shell/path.sh, exports.sh, aliases.sh
#   3. custom/ the same files, then any other *.sh

_dotfiles_root="$HOME/.dotfiles"

if [ -r "$_dotfiles_root/custom/dotfiles.env" ]; then
  set -a
  # shellcheck source=/dev/null
  . "$_dotfiles_root/custom/dotfiles.env"
  set +a
fi

for _dotfiles_dir in "$_dotfiles_root/shell" "$_dotfiles_root/custom"; do
  for _dotfiles_file in "$_dotfiles_dir/path.sh" "$_dotfiles_dir/exports.sh" "$_dotfiles_dir/aliases.sh"; do
    # shellcheck source=/dev/null
    [ -r "$_dotfiles_file" ] && . "$_dotfiles_file"
  done
done

for _dotfiles_file in "$_dotfiles_root"/custom/*.sh; do
  case "${_dotfiles_file##*/}" in
    path.sh | exports.sh | aliases.sh) continue ;;
  esac
  # shellcheck source=/dev/null
  [ -r "$_dotfiles_file" ] && . "$_dotfiles_file"
done

unset _dotfiles_root _dotfiles_dir _dotfiles_file
