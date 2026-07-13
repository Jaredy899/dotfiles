#!/usr/bin/env bash
# ~/.bashrc -- bootstrapper for modular dotfiles

# Ghostty transient surfaces use `bash --posix` without going through normal startup.
# Skip heavy config there to avoid bash 5.3.x segfaults.
if [[ -n ${BASH_POSIXLY_CORRECT:-} ]]; then
  return 0 2>/dev/null || exit 0
fi

# Ghostty auto shell-integration starts bash --posix and re-adds PROMPT_COMMAND after
# this file finishes — that crashes bash 5.3.x. Use manual integration instead:
#   shell-integration = none   in ~/.config/ghostty/config.ghostty
if [[ -n ${GHOSTTY_RESOURCES_DIR:-} && -r "${GHOSTTY_RESOURCES_DIR}/shell-integration/bash/ghostty.bash" ]]; then
  # shellcheck disable=SC1091
  builtin source "${GHOSTTY_RESOURCES_DIR}/shell-integration/bash/ghostty.bash"
fi

# Prompt hooks (starship, fzf, history sync). Safe with Ghostty when
# shell-integration = none. Set BASHRC_PROMPT_HOOKS=0 in ~/.bashrc.local to disable.
: "${BASHRC_PROMPT_HOOKS:=1}"

# Source system-wide bashrc if available
# shellcheck disable=SC1091
[[ -r /etc/bashrc ]] && . /etc/bashrc

# Local overrides (not in repo — safe for machine-specific settings).
# Example ~/.bashrc.local:
#   export DOTFILES_EDITOR=hx
#   export DOTFILES=/opt/dotfiles
#   export BASHRC_PROMPT_HOOKS=0
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

# Prevent leftover hooks from /etc/bashrc when prompt integrations are disabled.
if [[ ${BASHRC_PROMPT_HOOKS:-0} != 1 ]]; then
  unset PROMPT_COMMAND
fi
