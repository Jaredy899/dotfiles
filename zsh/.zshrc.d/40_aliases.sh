#!/usr/bin/env zsh
# shellcheck disable=SC1071
# All command aliases

# Safer core commands
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'
alias less='less -R'
alias cls='clear'
alias ps='ps auxf'
alias multitail='multitail --no-repeat -c'
alias freshclam='$ESCALATION_CMD freshclam'

# Package manager helpers
if [[ "$OSTYPE" == "darwin"* ]]; then
  alias brewup='brew update && brew upgrade && brew cleanup'
else
  alias apt-get='$ESCALATION_CMD apt-get'
  if command -v nala &>/dev/null; then
    apt() { $ESCALATION_CMD nala "$@"; }
  fi
fi

# Docker helpers
alias dup='docker compose up -d --force-recreate'
alias docker-clean='docker container prune -f && docker image prune -f && docker network prune -f && docker volume prune -f'
alias lzd='lazydocker'
alias lzg='lazygit'
alias lzs='lazyssh'

# Misc shortcuts
alias ff='fastfetch -c all'
if [[ "$OSTYPE" == "darwin"* ]]; then
  alias jc='sh <(curl -fsSL jaredcervantes.com/mac)'
else
  alias jc='sh <(curl -fsSL jaredcervantes.com/linux)'
fi
alias os='sh <(curl -fsSL jaredcervantes.com/os)'
alias nfzf='${EDITOR} "$(fzf -m --preview="bat --color=always {}")"'
# macOS-specific updater
updatebrew() {
  echo "🔄 Updating Homebrew..."
  brew update
  brew upgrade
  brew upgrade --cask --greedy
  brew cleanup --prune=all
  brew autoremove
}

if [[ "$OSTYPE" == "darwin"* ]]; then
  alias update='updatebrew'
else
  alias update='curl -fsSL https://raw.githubusercontent.com/Jaredy899/linux/refs/heads/main/installs/updater.sh | sh'
fi
alias convert='heif-convert'
if [[ "$OSTYPE" != "darwin"* ]]; then
  alias rebuild='$ESCALATION_CMD nixos-rebuild switch'
fi
if [[ "$OSTYPE" == "darwin"* ]]; then
  alias web='cd /Library/WebServer/Documents'  # macOS default web root
else
  alias web='cd /var/www/html'
fi
if [[ "$OSTYPE" == "darwin"* ]]; then
  alert() {
    local last_cmd=$(history | tail -n1 | sed -e "s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//")
    local status=$?
    if [[ $status == 0 ]]; then
      osascript -e "display notification \"$last_cmd\" with title \"Command Completed\""
    else
      osascript -e "display notification \"$last_cmd\" with title \"Command Failed\" subtitle \"Exit code: $status\""
    fi
  }
else
  alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history | tail -n1 | sed -e "s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//")"'
fi
alias ezsh='${EDITOR} ~/dotfiles/zsh/.zshrc.d'

# Platform-specific aliases
if [[ "$OSTYPE" == "darwin"* ]]; then
  alias flushdns='$ESCALATION_CMD dscacheutil -flushcache; $ESCALATION_CMD killall -HUP mDNSResponder'
else
  alias flushdns='$ESCALATION_CMD systemd-resolve --flush-caches'
fi
alias hlp='less ~/.zshrc_help'
alias da='date "+%Y-%m-%d %A %T %Z"'
alias sha1='openssl sha1'
if [[ "$OSTYPE" != "darwin"* ]]; then
  alias clickpaste='sleep 3; xdotool type "$(xclip -o -selection clipboard)"'
fi
alias pfind='pkg-tui'
alias ze='zellij'

# ls family
if command -v eza &>/dev/null; then
  alias ls='eza -a --icons --group-directories-first'
  alias la='eza -Alh --icons --group-directories-first'
  alias ll='eza -l --icons --group-directories-first'
  alias lla='eza -Al --icons --group-directories-first'
  alias las='eza -A --icons --group-directories-first'
  alias lw='eza -a1 --icons'
  alias lr='eza -lR --icons --group-directories-first'
  alias lt='eza -ltrh --icons --group-directories-first'
  alias lk='eza -lSrh --icons --group-directories-first'
  alias lx='eza -lXBh --icons --group-directories-first'
  alias lc='eza -ltcrh --icons --group-directories-first'
  alias lu='eza -lturh --icons --group-directories-first'
  alias lm='eza -alh --icons | more'
  alias labc='eza -lap --icons --group-directories-first'
  alias lf='eza -l --icons --group-directories-first | egrep -v "^d"'
  alias ldir='eza -l --icons --group-directories-first | egrep "^d"'
  alias lg='eza -l --git --icons --group-directories-first'
  alias tree='eza -T --icons --group-directories-first'
  alias treed='eza -T -D --icons --group-directories-first'
else
  alias ls='ls -aFh --color=always'
  alias la='ls -Alh'
  alias lx='ls -lXBh'
  alias lk='ls -lSrh'
  alias lc='ls -ltcrh'
  alias lu='ls -lturh'
  alias lr='ls -lRh'
  alias lt='ls -ltrh'
  alias lm='ls -alh | more'
  alias lw='ls -xAh'
  alias ll='ls -Fls'
  alias labc='ls -lap'
  alias lf="ls -l | egrep -v '^d'"
  alias ldir="ls -l | egrep '^d'"
  alias lla='ls -Al'
  alias las='ls -A'
  alias lls='ls -l'
  alias tree='tree -CAhF --dirsfirst'
  alias treed='tree -CAFd'
fi

# Remove a directory and all files
if [[ "$OSTYPE" == "darwin"* ]]; then
  alias rmd='/bin/rm -rf'  # macOS BSD rm with full path
else
  alias rmd='/bin/rm --recursive --force --verbose'  # Linux GNU rm with verbose
fi

# chmod helpers
alias mx='$ESCALATION_CMD chmod a+x'
alias 000='$ESCALATION_CMD chmod -R 000'
alias 644='$ESCALATION_CMD chmod -R 644'
alias 666='$ESCALATION_CMD chmod -R 666'
alias 755='$ESCALATION_CMD chmod -R 755'
alias 777='$ESCALATION_CMD chmod -R 777'

# Search helpers
alias h="history | grep -- "
alias p="ps aux | grep -- "
alias topcpu="/bin/ps -eo pcpu,pid,user,args | sort -k1 -r | head -10"
alias f="find . | grep -- "
alias countfiles='for t in files links directories; do echo "$(find . -type ${t:0:1} 2>/dev/null | wc -l)" "$t"; done'

# Networking & disks
if [[ "$OSTYPE" == "darwin"* ]]; then
  alias openports='lsof -i -P | grep LISTEN'
else
  alias openports='netstat -nape --inet'
fi
alias rebootsafe='$ESCALATION_CMD shutdown -r now'
alias rebootforce='$ESCALATION_CMD shutdown -r -n now'
alias diskspace="du -S | sort -n -r | more"
alias folders='du -h --max-depth=1'
alias folderssort='find . -maxdepth 1 -type d -print0 | xargs -0 du -sk | sort -rn'
alias mountedinfo='df -hT'

# Archives
alias mktar='tar -cvf'
alias mkbz2='tar -cvjf'
alias mkgz='tar -cvzf'
alias untar='tar -xvf'
alias unbz2='tar -xvjf'
alias ungz='tar -xvzf'

# cd shortcuts
alias home='cd ~'
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias whatismyip='whatsmyip'

# Only alias if sudo-rs exists
if command -v sudo-rs >/dev/null 2>&1; then
  alias sudo="sudo-rs"
fi

if command -v su-rs >/dev/null 2>&1; then
  alias su="su-rs"
fi
