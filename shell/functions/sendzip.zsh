# Zip given files/folders into ./archive.zip (overwritten if present) and share it with sendme
function sendzip() {
  if [ $# -eq 0 ]; then
    echo "Usage: sendzip <path> [path...]"
    return 1
  fi
  if ! command -v sendme >/dev/null 2>&1; then
    echo "sendme not found (brew install sendme / cargo install sendme)"
    return 1
  fi

  local archive="archive.zip"
  rm -f "$archive"
  zip -r -q "$archive" "$@" -x "*.DS_Store" || return 1
  sendme send "$archive"
}
