#!/usr/bin/env zsh
# shellcheck disable=SC1071
# Prompt hooks and auto-ls

__pcd_prev_pwd="$PWD"

list_if_cd() {
  if [[ "$PWD" != "$__pcd_prev_pwd" ]]; then
    __pcd_prev_pwd="$PWD"
    if command -v eza &>/dev/null; then
      eza -a --icons --group-directories-first
    else
      command ls -aFh --color=always
    fi
  fi
}

# Add to precmd functions (zsh equivalent of PROMPT_COMMAND)
precmd_functions+=('list_if_cd')
