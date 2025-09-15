#!/bin/sh -e
# Linux bootstrap for dotfiles

DOTFILES_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/dotfiles"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

detect_pm() {
  if command -v apt >/dev/null 2>&1; then echo apt
  elif command -v pacman >/dev/null 2>&1; then echo pacman
  elif command -v dnf >/dev/null 2>&1; then echo dnf
  elif command -v apk >/dev/null 2>&1; then echo apk
  elif command -v eopkg >/dev/null 2>&1; then echo eopkg
  elif command -v xbps-install >/dev/null 2>&1; then echo xbps
  elif command -v zypper >/dev/null 2>&1; then echo zypper
  else echo unknown
  fi
}
PM=$(detect_pm)

install_dep() {
  case "$PM" in
    apt)    
      sudo apt update && sudo apt install -y git curl unzip fontconfig ;;
    pacman) 
      sudo pacman -Sy --noconfirm git curl unzip fontconfig ;;
    dnf)    
      sudo dnf install -y git curl unzip fontconfig ;;
    apk)    
      doas apk add git curl unzip fontconfig ;;
    eopkg)  
      sudo eopkg install -y git curl unzip fontconfig ;;
    xbps)   
      sudo xbps-install -Sy git curl unzip fontconfig ;;
    zypper) 
      sudo zypper install -y git curl unzip fontconfig ;;
    *)      
      echo "⚠️ Unknown packager. Install git/curl/unzip/fontconfig manually." ;;
  esac
}

backup_and_link() {
  echo "📂 Linking configs..."
  mkdir -p "$CONFIG_DIR/fastfetch" "$CONFIG_DIR/mise"

  ln -sf "$DOTFILES_DIR/bash/.bashrc" "$HOME/.bashrc"

  # Alpine BusyBox/ash fallback
  if grep -qi alpine /etc/os-release 2>/dev/null; then
    ln -sf "$DOTFILES_DIR/sh/.profile" "$HOME/.profile"
  fi

  # If zsh installed, set up .zshrc too
  if command -v zsh >/dev/null 2>&1; then
    ln -sf "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
  fi

  # Starship/Mise/Fastfetch configs
  ln -sf "$DOTFILES_DIR/config/starship.toml" "$CONFIG_DIR/starship.toml"
  ln -sf "$DOTFILES_DIR/config/mise/config.toml" "$CONFIG_DIR/mise/config.toml"
  ln -sf "$DOTFILES_DIR/config/fastfetch/linux.jsonc" "$CONFIG_DIR/fastfetch/config.jsonc"
}

install_tools() {
  if ! command -v starship >/dev/null 2>&1; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y
  fi
  if ! command -v zoxide >/dev/null 2>&1; then
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
  fi
  if ! command -v mise >/dev/null 2>&1; then
    curl -sS https://mise.jdx.dev/install.sh | sh
  fi
  if ! command -v fastfetch >/dev/null 2>&1; then
    case "$PM" in
      apt)    sudo apt install -y fastfetch ;;
      pacman) sudo pacman -S --noconfirm fastfetch ;;
      dnf)    sudo dnf install -y fastfetch ;;
      apk)    sudo apk add fastfetch ;;
      eopkg)  sudo eopkg install -y fastfetch ;;
      xbps)   sudo xbps-install -Sy fastfetch ;;
      zypper) sudo zypper install -y fastfetch ;;
      *)      echo "⚠️ Install fastfetch manually" ;;
    esac
  fi
}

install_dep
backup_and_link
install_tools

echo "✅ Linux dotfiles installed. Restart shell."