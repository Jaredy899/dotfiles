#!/usr/bin/env fish
# Editor and pager settings

if command -v nvim >/dev/null 2>&1
    set -gx EDITOR "nvim"
    set -gx VISUAL "nvim"
    set -gx SUDO_EDITOR "nvim"
    alias vim='nvim'
    alias vi='nvim'
    alias svi='$ESCALATION_CMD -E nvim'
    alias vis='nvim "+set si"'
else
    set -gx EDITOR "vim"
    set -gx VISUAL "vim"
end

# less + manpage colors (Fish equivalent)
set -gx LESS_TERMCAP_mb (printf "\033[01;31m")
set -gx LESS_TERMCAP_md (printf "\033[01;31m")
set -gx LESS_TERMCAP_me (printf "\033[0m")
set -gx LESS_TERMCAP_se (printf "\033[0m")
set -gx LESS_TERMCAP_so (printf "\033[01;44;33m")
set -gx LESS_TERMCAP_ue (printf "\033[0m")
set -gx LESS_TERMCAP_us (printf "\033[01;32m")
