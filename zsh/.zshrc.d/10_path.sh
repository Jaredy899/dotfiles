#!/usr/bin/env zsh
# shellcheck disable=SC1071
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

# Platform-specific paths
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS-specific paths
  path_add "/usr/local/bin"
  path_add "/usr/local/sbin"
  path_add "/opt/homebrew/bin"
  path_add "/opt/homebrew/sbin"
else
  # Linux-specific paths
  path_add "/var/lib/flatpak/exports/bin"
  path_add "$HOME/.local/share/flatpak/exports/bin"
fi

# Export PATH (zsh automatically syncs $path with $PATH)
export PATH
