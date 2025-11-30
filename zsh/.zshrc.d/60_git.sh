#!/usr/bin/env zsh
# shellcheck disable=SC1071
# Git helpers

gb() { git branch "$@"; }
gp() { git pull "$@"; }

alias gdp='(cd ~/dotfiles && git pull); source ~/.zshrc'

gbd() {
  [ -z "$1" ] && {
    echo "Usage: gbd <branch>"
    return 1
  }
  git branch -D "$1"
  git push -d origin "$1" 2>/dev/null || echo "Remote branch '$1' not found or already deleted"
}

gcom() {
  [ -z "$1" ] && {
    echo "Usage: gcom <msg>"
    return 1
  }
  git add . && git commit -m "$1"
}

lazyg() {
  [ -z "$1" ] && {
    echo "Usage: lazyg <msg>"
    return 1
  }
  git add . && git commit -m "$1" && git push
}

newb() {
  [ -z "$1" ] || [ -z "$2" ] && {
    echo "Usage: newb <branch> <msg>"
    return 1
  }
  git checkout -b "$1" && git add . && git commit -m "$2" && git push -u origin "$1"
}

gs() {
  local branch
  branch=$(git branch --all --color=never | sed 's/^[* ]*//' | sort -u | fzf --prompt="Switch to branch: ")
  [ -n "$branch" ] || return
  clean_branch="${branch#remotes/}"
  if [[ "$branch" == remotes/* ]]; then
    git switch --track "$clean_branch" 2>/dev/null ||
      git checkout -b "${clean_branch#origin/}" --track "$clean_branch"
  else
    git switch "$clean_branch"
  fi
}

gsc() {
  [ -z "$1" ] && {
    echo "Usage: gsc <branch>"
    return 1
  }
  git switch -c "$1"
}

gpo() {
  [ -z "$1" ] && {
    echo "Usage: gpo <branch>"
    return 1
  }
  git push -u origin "$1"
}

gpf() {
  git push --force-with-lease
}
