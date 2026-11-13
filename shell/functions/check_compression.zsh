# Check if resource is served compressed
check_compression() {
  curl --write-out 'Size (uncompressed) = %{size_download}\n' --silent --output /dev/null $1
  curl --header 'Accept-Encoding: gzip,deflate,compress' --write-out 'Size (compressed) =   %{size_download}\n' --silent --output /dev/null $1
  curl --head --header 'Accept-Encoding: gzip,deflate' --silent $1 | grep -i "cache\|content\|vary\|expires"
}
