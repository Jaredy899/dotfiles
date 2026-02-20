#!/usr/bin/env zsh
# shellcheck disable=SC1071
# ~/.zshrc -- bootstrapper for modular dotfiles (macOS)

# Local overrides (not in repo — safe for machine-specific settings).
# Example ~/.zshrc.local:
#   export DOTFILES_EDITOR=hx
#   export DOTFILES=/opt/dotfiles
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# Path to dotfiles repo (local can override by setting DOTFILES before this runs)
DOTFILES="${DOTFILES:-$HOME/dotfiles}"

# Load modular zshrc.d scripts (aliases, functions, tools)
if [[ -d "$DOTFILES/zsh/.zshrc.d" ]]; then
  for rc in "$DOTFILES/zsh/.zshrc.d/"*.sh; do
    [[ -r "$rc" ]] && source "$rc"
  done
  unset rc
fi

# ──────────────────────────────
# macOS-specific / Zsh-specific config

# Zsh completion system
autoload -Uz compinit
compinit -d "${ZDOTDIR:-$HOME}/.zcompdump"

# macOS-specific plugins (installed via Homebrew)
if [[ "$OSTYPE" == "darwin"* ]]; then
  if [[ -r /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  fi
  if [[ -r /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  fi
fi
# Preferred keybindings
bindkey -e   # Emacs-style bindings (use `bindkey -v` for vi-style)
# bun completions
[ -s "/opt/homebrew/share/zsh/site-functions/_bun" ] && source "/opt/homebrew/share/zsh/site-functions/_bun"
