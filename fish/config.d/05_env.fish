#!/usr/bin/env fish
# Environment variables and general settings

# History settings (Fish equivalent)
set -gx fish_history_size 10000
set -gx fish_history_max_commands 500

# Fish-specific environment variables
set -gx fish_greeting ""  # Disable Fish greeting

# GPG pinentry TTY (for signing, etc.)
set -gx GPG_TTY (tty)

# XDG base directories
set -gx XDG_DATA_HOME "$HOME/.local/share"
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_STATE_HOME "$HOME/.local/state"
set -gx XDG_CACHE_HOME "$HOME/.cache"

# Privilege escalation - auto-detect available tool, prioritize doas
if command -v doas >/dev/null 2>&1
    set -gx ESCALATION_CMD "doas"
else if command -v sudo-rs >/dev/null 2>&1
    set -gx ESCALATION_CMD "sudo-rs"
else
    set -gx ESCALATION_CMD "sudo"
end
