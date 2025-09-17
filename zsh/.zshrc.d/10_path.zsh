#!/usr/bin/env zsh
# PATH management

# Helper function to add to path without duplicates (zsh version)
path_add() {
  # Check if path already exists in $path array
  if (( ! ${path[(Ie)$1]} )); then
    path=($path $1)
  fi
}

# Add common paths
path_add "$HOME/.local/bin"
path_add "$HOME/.cargo/bin"
path_add "/var/lib/flatpak/exports/bin"
path_add "$HOME/.local/share/flatpak/exports/bin"

# Export PATH (zsh automatically syncs $path with $PATH)
export PATH
