# gwtaa <branch> | gwtaa <new-branch> [base]
# Create a git worktree with a random three-word name next to the main checkout
# (<repo>.worktrees/<name>) and cd into it. An existing local or remote branch is
# checked out; a new one starts from [base], else origin/HEAD, else develop.

_gwt_words() {
  local -a adj=(amber brave calm clever cosmic crisp dusty eager fancy fuzzy gentle happy
    hidden icy jolly keen lively lucky mellow misty noble proud quiet rapid rusty shy
    silent sleepy snowy sunny swift tidy witty young zesty)
  local -a noun=(otter badger falcon heron koala lemur lynx marmot moose newt owl panda
    pelican puffin quokka raven salmon seal sparrow squid tapir tiger toucan turtle walrus
    wombat yak zebra comet delta harbor meadow pebble river summit willow)
  REPLY="${adj[RANDOM % $#adj + 1]}-${adj[RANDOM % $#adj + 1]}-${noun[RANDOM % $#noun + 1]}"
}

_gwt_default_base() {
  REPLY=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null) || REPLY=develop
}

gwtaa() {
  if (( $# < 1 || $# > 2 )); then
    print -u2 "usage: gwtaa <branch> | gwtaa <new-branch> [base]"; return 2
  fi
  local main dir i REPLY base
  main=$(git worktree list --porcelain 2>/dev/null | sed -n '1s/^worktree //p')
  [[ -n $main ]] || { print -u2 "gwtaa: not in a git repository"; return 1; }
  for i in {1..5}; do
    _gwt_words                      # tool variant: REPLY=$(golang-petname -w 3)
    dir="${main:h}/${main:t}.worktrees/$REPLY"
    [[ -e $dir ]] || break
  done
  [[ -e $dir ]] && { print -u2 "gwtaa: no free name after 5 tries"; return 1; }
  if (( $# == 2 )); then
    git worktree add -b "$1" "$dir" "$2"
  elif git show-ref --quiet --verify "refs/heads/$1" || git show-ref --quiet --verify "refs/remotes/origin/$1"; then
    git worktree add "$dir" "$1"
  else
    _gwt_default_base; base=$REPLY
    print "gwtaa: base = $base"
    git worktree add --no-track -b "$1" "$dir" "$base"
  fi || return
  cd "$dir"
}
