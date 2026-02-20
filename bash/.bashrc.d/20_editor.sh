#!/usr/bin/env bash
# Editor and pager settings (editor-agnostic: respects EDITOR or DOTFILES_EDITOR, else fallback)

if [[ -n "${EDITOR:-}" ]]; then
  # Respect existing EDITOR; set VISUAL/SUDO_EDITOR to match if unset
  [[ -z "${VISUAL:-}" ]] && export VISUAL="$EDITOR"
  [[ -z "${SUDO_EDITOR:-}" ]] && export SUDO_EDITOR="$EDITOR"
else
  # Use DOTFILES_EDITOR if set and available (e.g. export DOTFILES_EDITOR=hx in .bashrc or env.d)
  if [[ -n "${DOTFILES_EDITOR:-}" ]] && command -v "$DOTFILES_EDITOR" &>/dev/null; then
    export EDITOR="$DOTFILES_EDITOR"
    export VISUAL="$DOTFILES_EDITOR"
    export SUDO_EDITOR="$DOTFILES_EDITOR"
  else
    # Fallback: try vi, then nano
    for editor in vi nano; do
      if command -v "$editor" &>/dev/null; then
        export EDITOR="$editor"
        export VISUAL="$editor"
        export SUDO_EDITOR="$editor"
        break
      fi
    done
  fi
fi

# Aliases: e opens $EDITOR; se runs sudoedit (uses SUDO_EDITOR)
alias e="$EDITOR"
alias se='sudoedit'

# less + manpage colors
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'
