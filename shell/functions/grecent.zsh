# Last 10 distinct branches switched from, with the command to go back to each
function grecent() {
  git rev-parse --git-dir >/dev/null 2>&1 || { print -u2 "grecent: not in a git repository"; return 1; }
  git reflog | awk -v cur="$(git branch --show-current)" '
    /checkout: moving/ {
      n++; b = $(NF-2)
      if (b in seen || b == cur) next
      seen[b] = 1
      printf "\033[32m- git checkout @{-%d}\033[0m  ->  \033[36m%s\033[0m\n", n, b
      if (++shown == 10) exit
    }'
}
