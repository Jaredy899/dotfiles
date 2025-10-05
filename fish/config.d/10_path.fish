#!/usr/bin/env fish
# PATH management

# Helper function to add to path without duplicates (Fish version)
function path_add
    if not contains $argv[1] $PATH
        set -gx PATH $PATH $argv[1]
    end
end

# Add common paths
path_add "$HOME/.local/bin"
path_add "$HOME/.cargo/bin"

# Platform-specific paths
if test (uname) = "Darwin"
    # macOS-specific paths
    path_add "/usr/local/bin"
    path_add "/usr/local/sbin"
    path_add "/opt/homebrew/bin"
    path_add "/opt/homebrew/sbin"
else
    # Linux-specific paths
    path_add "/var/lib/flatpak/exports/bin"
    path_add "$HOME/.local/share/flatpak/exports/bin"
end
