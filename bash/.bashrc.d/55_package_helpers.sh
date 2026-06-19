#!/usr/bin/env bash
# Shared helpers for Solus package.yml and AerynOS stone.yaml recipes.

_pkg_recipe_file() {
  if [[ -f stone.yaml ]]; then
    printf '%s\n' stone.yaml
  elif [[ -f package.yml ]]; then
    printf '%s\n' package.yml
  elif [[ -f pspec.xml ]]; then
    printf '%s\n' pspec.xml
  else
    return 1
  fi
}

_pkg_recipe_kind() {
  case "$(_pkg_recipe_file 2>/dev/null)" in
  stone.yaml) printf '%s\n' aeryn ;;
  package.yml | pspec.xml) printf '%s\n' solus ;;
  *) return 1 ;;
  esac
}

_pkg_need_command() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    printf 'Missing requirement: %s\n' "$cmd" >&2
    return 1
  fi
}

_pkg_require_recipe() {
  _pkg_recipe_kind >/dev/null || {
    printf 'No package.yml, pspec.xml, or stone.yaml found in current directory.\n' >&2
    return 1
  }
}

_pkg_repo_root() {
  git rev-parse --show-toplevel 2>/dev/null
}

goroot() {
  local root
  root="$(_pkg_repo_root)" || return 1
  cd "$root" || return 1
}

pkgroot() {
  goroot "$@"
}

cpesearch() {
  local query="${1:-$(basename "$PWD")}"

  if [[ ${1:-} == "--help" || ${1:-} == "-h" ]]; then
    printf 'usage: cpesearch <package-name>\n'
    return 0
  fi

  if [[ $# -eq 0 ]]; then
    printf 'Warning: No parameters passed, using current directory name. Pass --help to see usage.\n' >&2
  fi

  _pkg_need_command curl && _pkg_need_command jq || return 1

  curl -s -X POST https://cpe-guesser.cve-search.org/search -d "{\"query\": [\"$query\"]}" | jq .
  printf 'Verify successful hits by visiting https://cve.circl.lu/search/$VENDOR/$PRODUCT\n'
  printf '%s\n' "- CPE entries for software applications have the form 'cpe:2.3:a:\$VENDOR:\$PRODUCT'"
}

pkgcd() {
  local package="$1" root
  [[ -n $package ]] || {
    printf 'Usage: pkgcd <package-name>\n' >&2
    return 1
  }

  root="$(_pkg_repo_root)" || return 1

  if [[ -d "$root/packages" ]]; then
    cd "$root"/packages/*/"$package" 2>/dev/null || return 1
  elif [[ -d "$root/${package:0:1}/$package" ]]; then
    cd "$root/${package:0:1}/$package" || return 1
  else
    printf 'Could not find package directory for %s\n' "$package" >&2
    return 1
  fi
}

gotopkg() {
  pkgcd "$@"
}

chpkg() {
  pkgcd "$@"
}

pkgbuild() {
  _pkg_require_recipe || return 1

  case "$(_pkg_recipe_kind)" in
  solus)
    _pkg_need_command go-task || return 1
    go-task build "$@"
    ;;
  aeryn)
    _pkg_need_command boulder || return 1
    if [[ $# -eq 0 ]]; then
      boulder build stone.yaml
    else
      boulder build "$@"
    fi
    ;;
  esac
}

pkgbuild-local() {
  _pkg_require_recipe || return 1

  case "$(_pkg_recipe_kind)" in
  solus)
    _pkg_need_command go-task || return 1
    go-task build-local "$@"
    ;;
  aeryn)
    _pkg_need_command boulder || return 1
    boulder build -p "${BOULDER_PROFILE:-local-x86_64}" "$@"
    ;;
  esac
}

pkgchroot() {
  _pkg_require_recipe || return 1

  case "$(_pkg_recipe_kind)" in
  solus)
    printf 'Solus helper has no pkgchroot mapping; use solbuild directly.\n' >&2
    return 1
    ;;
  aeryn)
    _pkg_need_command boulder || return 1
    if [[ $# -eq 0 ]]; then
      boulder chroot stone.yaml
    else
      boulder chroot "$@"
    fi
    ;;
  esac
}

pkgbump() {
  _pkg_require_recipe || return 1

  case "$(_pkg_recipe_kind)" in
  solus)
    _pkg_need_command go-task || return 1
    go-task bump "$@"
    ;;
  aeryn)
    _pkg_need_command boulder || return 1
    boulder recipe bump "$@"
    ;;
  esac
}

pkgupdates() {
  _pkg_require_recipe || return 1

  case "$(_pkg_recipe_kind)" in
  solus)
    _pkg_need_command go-task || return 1
    go-task updatecheck "$@"
    ;;
  aeryn)
    _pkg_need_command ent || return 1
    ent check updates "$@"
    ;;
  esac
}

pkgautoupdate() {
  _pkg_require_recipe || return 1

  case "$(_pkg_recipe_kind)" in
  solus)
    _pkg_need_command go-task || return 1
    go-task autoupdate "$@"
    ;;
  aeryn)
    _pkg_need_command boulder || return 1
    boulder recipe update "$@"
    ;;
  esac
}

pkgnew() {
  case "$(_pkg_recipe_kind 2>/dev/null)" in
  solus)
    _pkg_need_command go-task || return 1
    go-task new "$@"
    ;;
  aeryn | "")
    _pkg_need_command boulder || return 1
    boulder recipe new "$@"
    ;;
  esac
}

pkgclean() {
  _pkg_require_recipe || return 1

  case "$(_pkg_recipe_kind)" in
  solus)
    _pkg_need_command go-task || return 1
    go-task clean "$@"
    ;;
  aeryn)
    command rm -fv -- ./*.stone
    ;;
  esac
}

pkglocalindex() {
  _pkg_require_recipe || return 1

  case "$(_pkg_recipe_kind)" in
  solus)
    if [[ -d /var/lib/solbuild/local ]]; then
      ${ESCALATION_CMD:-sudo} eopkg.bin index --skip-signing /var/lib/solbuild/local/ --output /var/lib/solbuild/local/eopkg-index.xml &&
        ${ESCALATION_CMD:-sudo} eopkg.bin ur
    fi
    ;;
  aeryn)
    _pkg_need_command moss || return 1
    local repo="${LOCAL_REPO:-$HOME/.cache/local_repo/x86_64}"
    mkdir -p -- "$repo" && moss index "$repo"
    ;;
  esac
}

pkgfixup() {
  _pkg_require_recipe || return 1

  if ! git status --porcelain -- . | grep -q '^ M'; then
    printf 'No files in current directory are modified, aborting!\n' >&2
    return 1
  fi

  case "$(_pkg_recipe_kind)" in
  solus)
    local paths=(abi_* package.yml pspec_x86_64.xml monitoring.yaml files/)
    local path
    for path in "${paths[@]}"; do
      [[ -e $path ]] && git add "$path"
    done
    ;;
  aeryn)
    local paths=(stone.yaml manifest.x86_64.bin manifest.x86_64.jsonc monitoring.yaml pkg/)
    local path
    for path in "${paths[@]}"; do
      [[ -e $path ]] && git add "$path"
    done
    ;;
  esac

  git commit --fixup "$(git log -1 --format='%h' -- .)" &&
    git rebase origin/HEAD --autosquash --autostash &&
    git log -1 -- .
}

quickfixup() {
  pkgfixup "$@"
}

fixup-recipe-commit() {
  pkgfixup "$@"
}

checkupdate() {
  pkgupdates "$@"
}

updatecheck() {
  pkgupdates "$@"
}

localrepo_reindex() {
  pkglocalindex "$@"
}

_pkg_list_packages() {
  local package root
  root="$(_pkg_repo_root)" || return 0

  if [[ -d "$root/packages" ]]; then
    for package in "$root"/packages/*/*; do
      [[ -d $package ]] && basename "$package"
    done
  else
    for package in "$root"/[a-z]/*; do
      [[ -d $package ]] && basename "$package"
    done
  fi
}

_pkgcd_complete() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  mapfile -t COMPREPLY < <(compgen -W "$(_pkg_list_packages)" -- "$cur")
}

complete -F _pkgcd_complete pkgcd gotopkg chpkg 2>/dev/null

_boulder_load_completion() {
  command -v boulder >/dev/null 2>&1 || return 0
  complete -p boulder >/dev/null 2>&1 && return 0

  local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/bash-completion/generated"
  local completion_file="$cache_dir/boulder.bash"
  local boulder_bin
  boulder_bin="$(command -v boulder)" || return 0

  if [[ ! -r $completion_file || $boulder_bin -nt $completion_file ]]; then
    mkdir -p -- "$cache_dir" || return 0
    boulder --generate-completions "$cache_dir" >/dev/null 2>&1 || return 0
  fi

  # shellcheck disable=SC1090
  [[ -r $completion_file ]] && . "$completion_file"
}

_boulder_load_completion
