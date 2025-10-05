#!/usr/bin/env fish
# Prompt configuration

# Fish doesn't have a traditional prompt system like bash/zsh
# Instead, we configure the prompt using fish_prompt function
# This is handled by starship if installed

# If starship is not available, we can set up a basic Fish prompt
if not command -v starship >/dev/null 2>&1
    function fish_prompt
        set_color $fish_color_cwd
        printf '%s' (prompt_pwd)
        set_color normal
        printf ' > '
    end
end
