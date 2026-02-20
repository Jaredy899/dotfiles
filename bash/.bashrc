#!/usr/bin/env bash
# ~/.bashrc -- bootstrapper for modular dotfiles

# Source system-wide bashrc if available
# shellcheck disable=SC1091
[[ -r /etc/bashrc ]] && . /etc/bashrc

# Local overrides (not in repo — safe for machine-specific settings).
# Example ~/.bashrc.local:
#   export DOTFILES_EDITOR=hx
#   export DOTFILES=/opt/dotfiles
#   # Solus build helpers:
#   [[ -r "$HOME/solus-packages/common/Scripts/helpers.sh" ]] && . "$HOME/solus-packages/common/Scripts/helpers.sh"
# shellcheck disable=SC1090
[[ -r "$HOME/.bashrc.local" ]] && . "$HOME/.bashrc.local"

# Path to dotfiles repo (local can override by setting DOTFILES before this runs)
DOTFILES="${DOTFILES:-$HOME/dotfiles}"

# Load modular bashrc fragments
if [[ -d "$DOTFILES/bash/.bashrc.d" ]]; then
  for rc in "$DOTFILES/bash/.bashrc.d/"*.sh; do
    # shellcheck disable=SC1090
    [ -r "$rc" ] && . "$rc"
  done
  unset rc
fi

# Apply local editor override after fragments (DOTFILES_EDITOR from .bashrc.local wins)
if [[ -n "${DOTFILES_EDITOR:-}" ]] && command -v "$DOTFILES_EDITOR" &>/dev/null; then
  export EDITOR="$DOTFILES_EDITOR"
  export VISUAL="$DOTFILES_EDITOR"
  export SUDO_EDITOR="$DOTFILES_EDITOR"
fi

