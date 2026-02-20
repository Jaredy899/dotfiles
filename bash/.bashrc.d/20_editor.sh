#!/usr/bin/env bash
# Editor and pager settings (editor-agnostic: EDITOR or DOTFILES_EDITOR, else fallback).
# Local override: main .bashrc applies DOTFILES_EDITOR after loading fragments so it wins.

if [[ -n "${EDITOR:-}" ]]; then
  [[ -z "${VISUAL:-}" ]] && export VISUAL="$EDITOR"
  [[ -z "${SUDO_EDITOR:-}" ]] && export SUDO_EDITOR="$EDITOR"
elif [[ -n "${DOTFILES_EDITOR:-}" ]] && command -v "$DOTFILES_EDITOR" &>/dev/null; then
  export EDITOR="$DOTFILES_EDITOR"
  export VISUAL="$DOTFILES_EDITOR"
  export SUDO_EDITOR="$DOTFILES_EDITOR"
else
  for editor in vi nano; do
    if command -v "$editor" &>/dev/null; then
      export EDITOR="$editor"
      export VISUAL="$editor"
      export SUDO_EDITOR="$editor"
      break
    fi
  done
fi

# Aliases: e opens $EDITOR; se runs editor as root with your config (for Helix, etc.)
alias e="$EDITOR"
se() {
  local cfg="${XDG_CONFIG_HOME:-$HOME/.config}"
  local data="${XDG_DATA_HOME:-$HOME/.local/share}"
  $ESCALATION_CMD env XDG_CONFIG_HOME="$cfg" XDG_DATA_HOME="$data" "$EDITOR" "$@"
}

# less + manpage colors
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'
