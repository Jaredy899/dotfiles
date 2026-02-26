#!/usr/bin/env zsh
# shellcheck disable=SC1071
## Distribution detection
distribution() {
  local dtype=unknown
  if [[ "$OSTYPE" == "darwin"* ]]; then
    dtype=darwin
  elif [[ -r /etc/os-release ]]; then
    . /etc/os-release
    case "$ID" in
      fedora|rhel|centos) dtype=redhat ;;
      sles|opensuse*) dtype=suse ;;
      ubuntu|debian) dtype=debian ;;
      gentoo) dtype=gentoo ;;
      arch|manjaro) dtype=arch ;;
      void) dtype=void ;;
      slackware) dtype=slackware ;;
      solus) dtype=solus ;;
      nixos) dtype=nixos ;;
      *) ;;
    esac
    if [[ $dtype == unknown && -n ${ID_LIKE:-} ]]; then
      case "$ID_LIKE" in
        *fedora*|*rhel*|*centos*) dtype=redhat ;;
        *sles*|*opensuse*) dtype=suse ;;
        *ubuntu*|*debian*) dtype=debian ;;
        *gentoo*) dtype=gentoo ;;
        *arch*) dtype=arch ;;
        *void*) dtype=void ;;
        *slackware*) dtype=slackware ;;
        *solus*) dtype=solus ;;
      esac
    fi
  fi
  printf '%s\n' "$dtype"
}

# Prefer bat/batcat for cat; use glow for .md files when available
cat() {
  local use_glow=0
  if [[ -t 1 ]] && command -v glow &>/dev/null; then
    for arg in "$@"; do
      [[ "$arg" == *.md ]] && { use_glow=1; break; }
    done
  fi
  if ((use_glow)); then
    command glow "$@"
  elif command -v bat &>/dev/null; then
    bat "$@"
  elif command -v batcat &>/dev/null; then
    batcat "$@"
  else
    command cat "$@"
  fi
}

# Safe rm function - use trash for safe deletion, rm for force operations
rm() {
    if command -v trash &>/dev/null; then
        local force_real=0
        for arg in "$@"; do
            case "$arg" in
            -rf | -fr | -r | -f) force_real=1 ;;
            esac
        done

        if (( force_real == 1 )); then
            command rm "$@"
        else
            trash -v "$@"
        fi
    else
        command rm "$@"
    fi
}

catp() {
    if command -v bat &>/dev/null; then
        if [ -t 1 ]; then
            # Output is a terminal → use bat in plain mode
            bat --plain --paging=never "$@"
        else
            # Output is being piped or redirected → use real cat
            command cat "$@"
        fi
    elif command -v batcat &>/dev/null; then
        if [ -t 1 ]; then
            batcat --plain --paging=never "$@"
        else
            command cat "$@"
        fi
    else
        command cat "$@"
    fi
}

# OS version info
ver() {
  local dtype
  dtype="$(distribution)"
  case "$dtype" in
    redhat)
      if [[ -s /etc/redhat-release ]]; then
        cat /etc/redhat-release
      else
        cat /etc/issue
      fi
      uname -a
      ;;
    suse) cat /etc/SuSE-release ;;
    debian) if command -v lsb_release &>/dev/null; then lsb_release -a; else cat /etc/os-release; fi ;;
    gentoo) cat /etc/gentoo-release ;;
    arch|solus|nixos) cat /etc/os-release ;;
    slackware) cat /etc/slackware-version ;;
    darwin)
      echo "macOS $(sw_vers -productVersion) ($(sw_vers -buildVersion))"
      uname -a
      ;;
    *)
      if [[ -s /etc/issue ]]; then
        cat /etc/issue
      else
        echo "Error: Unknown distribution"
        return 1
      fi
      ;;
  esac
}

# tscp: SCP any file/folder to a host (fzf host picker if no host given)
tscp() {
    local src="$1"
    local host="$2"
    local dest="${3:-~}"
    local default_user="jared"  # change to your normal remote username

    if [[ -z $src ]]; then
        echo "Usage: tscp <file|dir> [host] [destination-path]"
        echo "Example: tscp myfile.txt myhost"
        echo "         tscp myfile.txt user@myhost /var/www/html"
        echo "         tscp myfile.txt   # pick host via fzf"
        return 1
    fi

    # If host not provided, pick from SSH config or Tailscale list
    if [[ -z $host ]]; then
        if command -v fzf &>/dev/null; then
            local ssh_hosts ts_hosts
            ssh_hosts=$(grep -E '^Host ' ~/.ssh/config 2>/dev/null | awk '{print $2}')
            if command -v tailscale &>/dev/null && command -v jq &>/dev/null; then
                ts_hosts=$(tailscale status --json 2>/dev/null | jq -r '.Peer[]?.DNSName' | sed 's/\.$//')
            fi
            host=$(printf "%s\n%s\n" "$ssh_hosts" "$ts_hosts" | sort -u | fzf --prompt="Select host: ")
        else
            echo "Error: fzf not installed and no host provided."
            return 1
        fi
    fi

    [[ -z $host ]] && { echo "No host selected."; return 1; }

    # If host already contains "@", use it as-is, otherwise prepend default user
    if [[ "$host" == *"@"* ]]; then
        remote="$host"
    else
        remote="${default_user}@${host}"
    fi

    # Decide whether to use -r (only for directories)
    local scp_opts=()
    if [[ -d $src ]]; then
        scp_opts+=(-r)
    fi

    scp "${scp_opts[@]}" -- "$src" "${remote}:$dest"
}

# extract archives
extract() {
  local archive
  for archive in "$@"; do
    if [[ -f $archive ]]; then
      case "$archive" in
        *.tar.bz2|*.tbz2) tar xvjf -- "$archive" ;;
        *.tar.gz|*.tgz) tar xvzf -- "$archive" ;;
        *.bz2) bunzip2 -- "$archive" ;;
        *.rar) unrar x -- "$archive" 2>/dev/null || rar x -- "$archive" ;;
        *.gz) gunzip -- "$archive" ;;
        *.tar) tar xvf -- "$archive" ;;
        *.zip) unzip -- "$archive" ;;
        *.Z) uncompress -- "$archive" ;;
        *.7z) 7z x -- "$archive" ;;
        *.tar.xz|*.txz) tar xvJf -- "$archive" ;;
        *.xz) unxz -- "$archive" ;;
        *) echo "Don't know how to extract '$archive'." ;;
      esac
    else
      echo "'$archive' is not a valid file!"
    fi
  done
}

# grep text recursively in current tree
ftext() {
  [[ -n $1 ]] || { echo "Usage: ftext <pattern>"; return 1; }
  grep -iIHrn --color=always -- "$1" . | less -r
}

# copy with progress (requires strace on Linux, dtruss on macOS)
cpp() {
  set -e
  local src="$1" dst="$2"
  [[ -n $src && -n $dst ]] || { echo "Usage: cpp <src> <dst>"; return 1; }

  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS version using a simple progress indicator
    local total_size=$(stat -f '%z' "$src")
    echo "Copying $src to $dst..."
    cp -v "$src" "$dst" 2>&1 | awk -v total="$total_size" '
      /->/ {
        if (match($0, /([0-9]+) bytes/, arr)) {
          percent = (arr[1] / total) * 100
          printf "%.1f%% copied\r", percent
        }
      }
      END { print "Copy complete" }'
  else
    # Linux version using strace
    strace -q -ewrite cp -- "$src" "$dst" 2>&1 |
      awk -v total_size="$(stat -c '%s' "$src")" '
        { count += $NF
          if (count % 10 == 0) {
            percent = (count / total_size) * 100
            if (percent > 100) percent = 100
            printf "%3d%% [", percent
            for (i = 0; i <= percent; i++) printf "="
            printf ">"
            for (i = percent; i < 100; i++) printf " "
            printf "]\r"
          }
        }
        END { print "" }'
  fi
}

# copy and go
cpg() {
  local src="$1" dst="$2"
  [[ -n $src && -n $dst ]] || { echo "Usage: cpg <src> <dst-dir|file>"; return 1; }
  if [[ -d $dst ]]; then
    cp -- "$src" "$dst" && cd "$dst" || return
  else
    cp -- "$src" "$dst"
  fi
}

# move and go
mvg() {
  local src="$1" dst="$2"
  [[ -n $src && -n $dst ]] || { echo "Usage: mvg <src> <dst-dir|file>"; return 1; }
  if [[ -d $dst ]]; then
    mv -- "$src" "$dst" && cd "$dst" || return
  else
    mv -- "$src" "$dst"
  fi
}

# mkdir and go
mkdirg() {
  [[ -n $1 ]] || { echo "Usage: mkdirg <dir>"; return 1; }
  mkdir -p -- "$1" && cd -- "$1"
}

# up N directories
up() {
  local limit="${1:-1}" d=
  local i
  for ((i = 1; i <= limit; i++)); do
    d="${d}/.."
  done
  d="${d#/}"
  cd "${d:-..}"
}

# tail of PWD
pwdtail() {
  pwd | awk -F/ '{nlast = NF - 1; print $nlast "/" $NF}'
}

# what is my IP (adapted for macOS)
whatsmyip() {
  local dev
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    echo "Internal IP:"
    ipconfig getifaddr en0 2>/dev/null | sed 's/^/  /'
    ipconfig getifaddr en1 2>/dev/null | sed 's/^/  /'
    echo "External IP:"
    curl -sS https://ifconfig.me || curl -sS https://api.ipify.org
  else
    # Linux
    dev="$(ip route 2>/dev/null | awk '/default/ {print $5; exit}')"
    if [[ -n $dev ]]; then
      echo -n "Internal IP: "
      ip -4 -o addr show dev "$dev" 2>/dev/null | awk '{print $4}' | cut -d/ -f1
    else
      echo -n "Internal IP: "
      ip -4 -o addr show 2>/dev/null | awk '{print $4}' | cut -d/ -f1 | head -n1
    fi
    echo -n "External IP: "
    curl -fsS ifconfig.me || curl -fsS ipinfo.io/ip || echo "N/A"
  fi
  echo
}
alias whatismyip='whatsmyip'

# trim leading/trailing whitespace
trim() {
  local var="$*"
  var="${var#"${var%%[![:space:]]*}"}"
  var="${var%"${var##*[![:space:]]}"}"
  printf '%s' "$var"
}

# Yazi wrapper
y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}
