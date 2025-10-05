#!/usr/bin/env fish
# Exit early if not interactive
if not status is-interactive
    return
end

# fastfetch
if command -v fastfetch >/dev/null 2>&1
    fastfetch
end

# Fish-specific terminal behavior
# Enable case-insensitive completion
set fish_complete_path $fish_complete_path /opt/homebrew/share/fish/vendor_completions.d

# Fish history settings
set -gx fish_history_size 10000
set -gx fish_history_max_commands 500

# Enable automatic cd (Fish equivalent)
# Fish doesn't have AUTO_CD, but we can create a function
function __fish_auto_cd
    if test (count $argv) -eq 1 -a -d "$argv[1]"
        cd "$argv[1]"
        return 0
    end
    return 1
end

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
