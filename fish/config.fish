#!/usr/bin/env fish
# ~/.config/fish/config.fish -- Fish shell configuration

# Local overrides (not in repo — safe for machine-specific settings).
# Example ~/.config/fish/config.local.fish:
#   set -gx DOTFILES_EDITOR hx
#   set -gx DOTFILES /opt/dotfiles
if test -r "$HOME/.config/fish/config.local.fish"
    source "$HOME/.config/fish/config.local.fish"
end

# Path to dotfiles repo (local can override by setting DOTFILES before this runs)
set -q DOTFILES; or set -gx DOTFILES "$HOME/dotfiles"

# Load modular fish config.d scripts
if test -d "$DOTFILES/fish/config.d"
    for config in "$DOTFILES/fish/config.d/"*.fish
        if test -r "$config"
            source "$config"
        end
    end
end

# ──────────────────────────────
# Fish-specific configuration

# Fish completion system
# Enable case-insensitive completion
set fish_complete_path $fish_complete_path /opt/homebrew/share/fish/vendor_completions.d

# macOS-specific plugins (installed via Homebrew)
if test (uname) = "Darwin"
    # Fish autosuggestions
    if test -r /opt/homebrew/share/fish/vendor_conf.d/fish_autosuggestions.fish
        source /opt/homebrew/share/fish/vendor_conf.d/fish_autosuggestions.fish
    end
    
    # Fish syntax highlighting
    if test -r /opt/homebrew/share/fish/vendor_conf.d/fish_syntax_highlighting.fish
        source /opt/homebrew/share/fish/vendor_conf.d/fish_syntax_highlighting.fish
    end
end

# Fish key bindings (emacs-style by default)
fish_default_key_bindings
