#!/usr/bin/env fish
# Tool integrations and final setup

# Initialize tools if they exist
if command -v zoxide >/dev/null 2>&1
    zoxide init fish | source
end

if command -v mise >/dev/null 2>&1
    mise activate fish | source
end

if command -v starship >/dev/null 2>&1
    starship init fish | source
end

# Fish-specific tool integrations
if command -v fzf >/dev/null 2>&1
    # FZF key bindings for Fish
    fzf_key_bindings
end

# Additional Fish completions
if test -d /opt/homebrew/share/fish/vendor_completions.d
    set fish_complete_path $fish_complete_path /opt/homebrew/share/fish/vendor_completions.d
end

# Fish-specific environment setup
set -gx fish_greeting ""  # Disable Fish greeting

# Final PATH cleanup
set -gx PATH (string split " " (string join " " $PATH) | sort -u)
