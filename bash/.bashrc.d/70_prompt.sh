#!/usr/bin/env bash
# Prompt hooks and auto-ls

__pcd_prev_pwd="$PWD"

list_if_cd() {
  if [[ "$PWD" != "$__pcd_prev_pwd" ]]; then
    __pcd_prev_pwd="$PWD"
    # Call eza directly — avoid `ls` alias in PROMPT_COMMAND (bash 5.3 segfaults)
    if command -v eza &>/dev/null; then
      eza -a --icons --group-directories-first
    else
      command ls -aFh --color=always
    fi
  fi
}

pc_add 'list_if_cd'
