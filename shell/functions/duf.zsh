# Show disk usage of current folder, or list with depth
duf() {
  du -d ${1:-0} -c | sort -r -n | awk '{split("K M G",v); s=1; while($1>1024){$1/=1024; s++} print int($1)v[s]"\t"$2}'
}
