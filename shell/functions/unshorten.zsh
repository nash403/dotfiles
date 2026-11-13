# Find real from shortened url (HTTP/2 sends the header in lower case)
unshorten() {
  curl -sIL "$1" | tr -d '\r' | sed -n 's/^[Ll]ocation: *//p'
}
