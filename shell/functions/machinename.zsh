# Print the machine's names: ComputerName, HostName and LocalHostName on macOS
# (as set in System Settings > General > Sharing), the hostname elsewhere.
machinename() {
  if command -v scutil >/dev/null 2>&1; then
    local key value
    for key in ComputerName HostName LocalHostName; do
      value=$(scutil --get "$key" 2>/dev/null) || value="(not set)"
      printf '%-14s %s\n' "$key" "$value"
    done
  else
    hostname
  fi
}
