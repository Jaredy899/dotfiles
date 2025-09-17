#!/usr/bin/env zsh
# shellcheck disable=SC1071
# Exit early if not interactive
[[ -o interactive ]] || return 0

# fastfetch
if command -v fastfetch &>/dev/null; then
  fastfetch
fi

# Source global zshrc if available
[[ -r /etc/zshrc ]] && . /etc/zshrc

# Zsh-specific terminal behavior (equivalent to readline bindings)
# Set completion to be case insensitive
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# Show completion menu on first tab press
zstyle ':completion:*' menu select
# Enable completion for hidden files
_comp_options+=(globdots)

# Terminal bell and key bindings
# Disable terminal bell
unsetopt BEEP
# Enable extended globbing
setopt EXTENDED_GLOB
# Enable interactive comments
setopt INTERACTIVE_COMMENTS
