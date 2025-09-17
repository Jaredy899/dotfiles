#!/usr/bin/env zsh
# Extra dev tools and integrations

alias bd='bun dev'
alias cr='cargo run'

# Fzf bindings (zsh version)
# shellcheck disable=SC1090
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Starship prompt
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

# Auto-start X if TTY1 and dwm config found
if [[ "$(tty)" == "/dev/tty1" ]] && [[ -f "$HOME/.xinitrc" ]] && grep -q "^exec dwm" "$HOME/.xinitrc"; then
  command -v startx &>/dev/null && startx
fi

# Cargo environment
# shellcheck disable=SC1091
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# -------------------------------------------------------------------
# Zoxide (smarter cd), must be at the very end of shell configuration
# -------------------------------------------------------------------
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi
