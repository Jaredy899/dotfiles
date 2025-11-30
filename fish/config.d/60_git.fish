#!/usr/bin/env fish
# Git helpers

function gb
    git branch $argv
end

function gp
    git pull $argv
end

alias gdp='(cd ~/dotfiles && git pull); source ~/.config/fish/config.fish'

function gbd
    if test -z "$argv[1]"
        echo "Usage: gbd <branch>"
        return 1
    end
    git branch -D "$argv[1]"
    git push -d origin "$argv[1]" 2>/dev/null; or echo "Remote branch '$argv[1]' not found or already deleted"
end

function gcom
    if test -z "$argv[1]"
        echo "Usage: gcom <msg>"
        return 1
    end
    git add .; and git commit -m "$argv[1]"
end

function lazyg
    if test -z "$argv[1]"
        echo "Usage: lazyg <msg>"
        return 1
    end
    git add .; and git commit -m "$argv[1]"; and git push
end

function newb
    if test -z "$argv[1]"; or test -z "$argv[2]"
        echo "Usage: newb <branch> <msg>"
        return 1
    end
    git checkout -b "$argv[1]"; and git add .; and git commit -m "$argv[2]"; and git push -u origin "$argv[1]"
end

function gs
    set branch (git branch --all --color=never | sed 's/^[* ]*//' | sort -u | fzf --prompt="Switch to branch: ")
    if test -z "$branch"
        return
    end
    set clean_branch (string replace "remotes/" "" "$branch")
    if string match -q "remotes/*" "$branch"
        git switch --track "$clean_branch" 2>/dev/null; or git checkout -b (string replace "origin/" "" "$clean_branch") --track "$clean_branch"
    else
        git switch "$clean_branch"
    end
end

function gsc
    if test -z "$argv[1]"
        echo "Usage: gsc <branch>"
        return 1
    end
    git switch -c "$argv[1]"
end

function gpo
    if test -z "$argv[1]"
        echo "Usage: gpo <branch>"
        return 1
    end
    git push -u origin "$argv[1]"
end

function gpf
    git push --force-with-lease
end
