#!/usr/bin/env fish
# Colors and grep defaults

# -------------------------------------------------------------------
# LS_COLORS
# -------------------------------------------------------------------
# Prefer vivid (modern theming)
if command -v vivid >/dev/null 2>&1
    # Pick a theme you like: one of (gruvbox-dark, one-dark, dracula, solarized-dark, etc.)
    set -gx LS_COLORS (vivid generate one-dark)
else
    # Fallback to dircolors (system defaults)
    if command -v dircolors >/dev/null 2>&1
        eval (dircolors -c)
    else
        # As an absolute last fallback, set some sane defaults manually
        set -gx LS_COLORS 'di=34:ln=36:so=35:pi=33:ex=32:bd=33;01:cd=33;01:'
    end
end

# -------------------------------------------------------------------
# grep
# -------------------------------------------------------------------
if command -v rg >/dev/null 2>&1
    alias grep='rg --color=auto'
else
    alias grep='grep --color=auto'
end
