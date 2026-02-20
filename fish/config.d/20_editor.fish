#!/usr/bin/env fish
# Editor and pager settings (editor-agnostic: respects EDITOR or DOTFILES_EDITOR, else fallback)

if set -q EDITOR; and test -n "$EDITOR"
    # Respect existing EDITOR; set VISUAL/SUDO_EDITOR to match if unset
    set -q VISUAL; or set -gx VISUAL "$EDITOR"
    set -q SUDO_EDITOR; or set -gx SUDO_EDITOR "$EDITOR"
else
    # Use DOTFILES_EDITOR if set and available (e.g. in config.local.fish)
    if set -q DOTFILES_EDITOR; and test -n "$DOTFILES_EDITOR"; and command -v "$DOTFILES_EDITOR" >/dev/null 2>&1
        set -gx EDITOR "$DOTFILES_EDITOR"
        set -gx VISUAL "$DOTFILES_EDITOR"
        set -gx SUDO_EDITOR "$DOTFILES_EDITOR"
    else
        # Fallback: try vi, then nano
        for editor in vi nano
            if command -v $editor >/dev/null 2>&1
                set -gx EDITOR $editor
                set -gx VISUAL $editor
                set -gx SUDO_EDITOR $editor
                break
            end
        end
    end
end

# Aliases: e opens $EDITOR; se runs sudoedit (uses SUDO_EDITOR)
alias e="$EDITOR"
alias se='sudoedit'

# less + manpage colors (Fish equivalent)
set -gx LESS_TERMCAP_mb (printf "\033[01;31m")
set -gx LESS_TERMCAP_md (printf "\033[01;31m")
set -gx LESS_TERMCAP_me (printf "\033[0m")
set -gx LESS_TERMCAP_se (printf "\033[0m")
set -gx LESS_TERMCAP_so (printf "\033[01;44;33m")
set -gx LESS_TERMCAP_ue (printf "\033[0m")
set -gx LESS_TERMCAP_us (printf "\033[01;32m")
