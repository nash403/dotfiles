# Print the default shell, the current one and the shells this machine allows
function shells {
  echo "Default Shell:"
  echo "$SHELL"
  echo "Current Shell:"
  echo "$0"
  echo "Available Shells:"
  grep -v '^#' /etc/shells | grep -v '^$'
}
