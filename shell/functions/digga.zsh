# Show the main DNS records of a domain. One query per type: many servers
# no longer answer `ANY` (RFC 8482).
function digga() {
  local type
  for type in A AAAA CNAME MX NS TXT; do
    dig +nocmd "$1" "$type" +noall +answer
  done
}
