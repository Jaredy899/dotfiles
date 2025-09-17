#!/usr/bin/env zsh
# shellcheck disable=SC1071
# History + general environment

# History settings (zsh equivalents)
export HISTFILE="${HISTFILE:-${ZDOTDIR:-$HOME}/.zsh_history}"
export HISTSIZE=500
export SAVEHIST=10000
# History options (equivalent to bash HISTCONTROL)
setopt HIST_IGNORE_DUPS      # erasedups equivalent
setopt HIST_IGNORE_ALL_DUPS  # ignoredups equivalent
setopt HIST_IGNORE_SPACE     # ignorespace equivalent
setopt HIST_REDUCE_BLANKS    # Clean up whitespace
setopt SHARE_HISTORY         # Share history between sessions
setopt EXTENDED_HISTORY      # Add timestamps to history
setopt HIST_VERIFY           # Don't execute immediately on history expansion
setopt HIST_SAVE_NO_DUPS     # Don't save duplicates to file

# Enable automatic cd
setopt AUTO_CD
# Enable globbing
setopt GLOB
# Check window size after commands
setopt CHECK_WINSIZE

# Zsh equivalent of PROMPT_COMMAND using precmd hooks
# Helper to add functions to precmd
precmd_add() {
  local add="$1"
  add="${add#"${add%%[![:space:]]*}"}"
  add="${add%"${add##*[![:space:]]}"}"
  [[ -z $add ]] && return 0

  # Check if already in precmd_functions
  if [[ -n ${precmd_functions[(r)$add]} ]]; then
    return 0
  fi

  precmd_functions+=("$add")
}

# History sync across sessions (zsh handles this with SHARE_HISTORY)
# But we can add custom history saving if needed
precmd_add 'fc -W'  # Write history after each command
precmd_add 'fc -R'  # Read history before each command

# XDG base directories (same as bash)
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
