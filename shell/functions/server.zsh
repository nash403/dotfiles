# Serve the current folder over HTTP and open it, optionally on a given port
function server() {
  local port="${1:-8000}"
  sleep 1 && open "http://localhost:${port}/" &
  python3 -m http.server "$port"
}
