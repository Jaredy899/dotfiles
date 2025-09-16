#!/usr/bin/env bash
# Colors and grep defaults

# -------------------------------------------------------------------
# LS_COLORS
# -------------------------------------------------------------------
# Prefer vivid (modern theming)
if command -v vivid >/dev/null 2>&1; then
  # Pick a theme you like: one of (gruvbox-dark, one-dark, dracula, solarized-dark, etc.)
  LS_COLORS="$(vivid generate one-dark)"
  export LS_COLORS
else
  # Fallback to dircolors (system defaults)
  if command -v dircolors >/dev/null 2>&1; then
    eval "$(dircolors -b)"
  else
    # As an absolute last fallback, set some sane defaults manually
    export LS_COLORS='di=34:ln=36:so=35:pi=33:ex=32:bd=33;01:cd=33;01:'
  fi
fi

# -------------------------------------------------------------------
# grep
# -------------------------------------------------------------------
if command -v rg &>/dev/null; then
  alias grep='rg --color=auto'
else
  alias grep='grep --color=auto'
fi
