#!/bin/bash -e
# macOS bootstrap for dotfiles

DOTFILES_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/dotfiles"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

install_homebrew() {
  if ! command -v brew >/dev/null 2>&1; then
    echo "🍺 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
}

install_dep() {
  brew install git curl unzip starship zoxide mise fastfetch fzf bat eza tree fish
  brew tap homebrew/cask-fonts && brew install --cask font-meslo-lg-nerd-font
}

backup_and_link() {
  echo "📂 Linking configs..."
  mkdir -p "$CONFIG_DIR/fastfetch" "$CONFIG_DIR/mise" "$CONFIG_DIR/fish"

  ln -sf "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
  ln -sf "$DOTFILES_DIR/fish/config.fish" "$CONFIG_DIR/fish/config.fish"
  ln -sf "$DOTFILES_DIR/config/starship.toml" "$CONFIG_DIR/starship.toml"
  ln -sf "$DOTFILES_DIR/config/mise/config.toml" "$CONFIG_DIR/mise/config.toml"
  ln -sf "$DOTFILES_DIR/config/fastfetch/macos.jsonc" "$CONFIG_DIR/fastfetch/config.jsonc"
}

install_homebrew
install_dep
backup_and_link
echo "✅ macOS dotfiles installed. Restart terminal."