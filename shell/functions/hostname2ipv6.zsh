# Get the IPv6 address of a hostname (first AAAA record). Asks DNS directly:
# ping6 would fail on a network without IPv6.
hostname2ipv6() {
  if [[ -z "$1" ]]; then
    print -u2 "usage: hostname2ipv6 <hostname>"
    return 2
  fi
  dig +short AAAA "$1" | grep ':' | head -1
}
