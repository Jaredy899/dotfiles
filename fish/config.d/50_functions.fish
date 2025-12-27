#!/usr/bin/env fish
# Fish functions

# Distribution detection
function distribution
    set dtype unknown
    if test (uname) = "Darwin"
        set dtype darwin
    else if test -r /etc/os-release
        set -l os_info (cat /etc/os-release)
        set -l id (echo $os_info | grep "^ID=" | cut -d= -f2 | tr -d '"')
        switch $id
            case fedora rhel centos
                set dtype redhat
            case sles opensuse*
                set dtype suse
            case ubuntu debian
                set dtype debian
            case gentoo
                set dtype gentoo
            case arch manjaro
                set dtype arch
            case void
                set dtype void
            case slackware
                set dtype slackware
            case solus
                set dtype solus
            case nixos
                set dtype nixos
        end
    end
    printf '%s\n' $dtype
end

# Prefer bat/batcat for cat if present
if command -v bat >/dev/null 2>&1
    alias cat='bat'
else if command -v batcat >/dev/null 2>&1
    alias cat='batcat'
end

# Safe rm function - use trash for safe deletion, rm for force operations
function rm
    if command -v trash >/dev/null 2>&1
        set force_real 0
        for arg in $argv
            switch $arg
                case -rf -fr -r -f
                    set force_real 1
            end
        end

        if test $force_real = 1
            command rm $argv
        else
            trash -v $argv
        end
    else
        command rm $argv
    end
end

function catp
    if command -v bat >/dev/null 2>&1
        if test -t 1
            # Output is a terminal → use bat in plain mode
            bat --plain --paging=never $argv
        else
            # Output is being piped or redirected → use real cat
            command cat $argv
        end
    else if command -v batcat >/dev/null 2>&1
        if test -t 1
            batcat --plain --paging=never $argv
        else
            command cat $argv
        end
    else
        command cat $argv
    end
end

# OS version info
function ver
    set dtype (distribution)
    switch $dtype
        case redhat
            if test -s /etc/redhat-release
                cat /etc/redhat-release
            else
                cat /etc/issue
            end
            uname -a
        case suse
            cat /etc/SuSE-release
        case debian
            if command -v lsb_release >/dev/null 2>&1
                lsb_release -a
            else
                cat /etc/os-release
            end
        case gentoo
            cat /etc/gentoo-release
        case arch solus nixos
            cat /etc/os-release
        case slackware
            cat /etc/slackware-version
        case darwin
            echo "macOS "(sw_vers -productVersion)" ("(sw_vers -buildVersion)")"
            uname -a
        case '*'
            if test -s /etc/issue
                cat /etc/issue
            else
                echo "Error: Unknown distribution"
                return 1
            end
    end
end

# tscp: SCP any file/folder to a host (fzf host picker if no host given)
function tscp
    set src $argv[1]
    set host $argv[2]
    set dest $argv[3]
    if test -z "$dest"
        set dest "~"
    end
    set default_user "jared"  # change to your normal remote username

    if test -z "$src"
        echo "Usage: tscp <file|dir> [host] [destination-path]"
        echo "Example: tscp myfile.txt myhost"
        echo "         tscp myfile.txt user@myhost /var/www/html"
        echo "         tscp myfile.txt   # pick host via fzf"
        return 1
    end

    # If host not provided, pick from SSH config or Tailscale list
    if test -z "$host"
        if command -v fzf >/dev/null 2>&1
            set ssh_hosts (grep -E '^Host ' ~/.ssh/config 2>/dev/null | awk '{print $2}')
            set ts_hosts ""
            if command -v tailscale >/dev/null 2>&1; and command -v jq >/dev/null 2>&1
                set ts_hosts (tailscale status --json 2>/dev/null | jq -r '.Peer[]?.DNSName' | sed 's/\.$//')
            end
            set host (printf "%s\n%s\n" $ssh_hosts $ts_hosts | sort -u | fzf --prompt="Select host: ")
        else
            echo "Error: fzf not installed and no host provided."
            return 1
        end
    end

    if test -z "$host"
        echo "No host selected."
        return 1
    end

    # If host already contains "@", use it as-is, otherwise prepend default user
    if string match -q "*@*" "$host"
        set remote "$host"
    else
        set remote "$default_user@$host"
    end

    # Decide whether to use -r (only for directories)
    set scp_opts
    if test -d "$src"
        set scp_opts $scp_opts -r
    end

    scp $scp_opts -- "$src" "$remote:$dest"
end

# extract archives
function extract
    for archive in $argv
        if test -f "$archive"
            switch $archive
                case "*.tar.bz2" "*.tbz2"
                    tar xvjf -- "$archive"
                case "*.tar.gz" "*.tgz"
                    tar xvzf -- "$archive"
                case "*.bz2"
                    bunzip2 -- "$archive"
                case "*.rar"
                    unrar x -- "$archive" 2>/dev/null; or rar x -- "$archive"
                case "*.gz"
                    gunzip -- "$archive"
                case "*.tar"
                    tar xvf -- "$archive"
                case "*.zip"
                    unzip -- "$archive"
                case "*.Z"
                    uncompress -- "$archive"
                case "*.7z"
                    7z x -- "$archive"
                case "*.tar.xz" "*.txz"
                    tar xvJf -- "$archive"
                case "*.xz"
                    unxz -- "$archive"
                case '*'
                    echo "Don't know how to extract '$archive'."
            end
        else
            echo "'$archive' is not a valid file!"
        end
    end
end

# grep text recursively in current tree
function ftext
    if test -z "$argv[1]"
        echo "Usage: ftext <pattern>"
        return 1
    end
    grep -iIHrn --color=always -- "$argv[1]" . | less -r
end

# copy with progress (requires strace on Linux, dtruss on macOS)
function cpp
    set -e
    set src $argv[1]
    set dst $argv[2]
    if test -z "$src"; or test -z "$dst"
        echo "Usage: cpp <src> <dst>"
        return 1
    end

    if test (uname) = "Darwin"
        # macOS version using a simple progress indicator
        set total_size (stat -f '%z' "$src")
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
    end
end

# copy and go
function cpg
    set src $argv[1]
    set dst $argv[2]
    if test -z "$src"; or test -z "$dst"
        echo "Usage: cpg <src> <dst-dir|file>"
        return 1
    end
    if test -d "$dst"
        cp -- "$src" "$dst"; and cd "$dst"; or return
    else
        cp -- "$src" "$dst"
    end
end

# move and go
function mvg
    set src $argv[1]
    set dst $argv[2]
    if test -z "$src"; or test -z "$dst"
        echo "Usage: mvg <src> <dst-dir|file>"
        return 1
    end
    if test -d "$dst"
        mv -- "$src" "$dst"; and cd "$dst"; or return
    else
        mv -- "$src" "$dst"
    end
end

# mkdir and go
function mkdirg
    if test -z "$argv[1]"
        echo "Usage: mkdirg <dir>"
        return 1
    end
    mkdir -p -- "$argv[1]"; and cd -- "$argv[1]"
end

# up N directories
function up
    set limit $argv[1]
    if test -z "$limit"
        set limit 1
    end
    set d ""
    for i in (seq 1 $limit)
        set d "$d/.."
    end
    set d (string sub -s 2 $d)
    cd (string sub -s 1 $d; or echo "..")
end

# tail of PWD
function pwdtail
    pwd | awk -F/ '{nlast = NF - 1; print $nlast "/" $NF}'
end

# what is my IP (adapted for macOS)
function whatsmyip
    if test (uname) = "Darwin"
        # macOS
        echo "Internal IP:"
        ipconfig getifaddr en0 2>/dev/null | sed 's/^/  /'
        ipconfig getifaddr en1 2>/dev/null | sed 's/^/  /'
        echo "External IP:"
        curl -sS https://ifconfig.me; or curl -sS https://api.ipify.org
    else
        # Linux
        set dev (ip route 2>/dev/null | awk '/default/ {print $5; exit}')
        if test -n "$dev"
            echo -n "Internal IP: "
            ip -4 -o addr show dev "$dev" 2>/dev/null | awk '{print $4}' | cut -d/ -f1
        else
            echo -n "Internal IP: "
            ip -4 -o addr show 2>/dev/null | awk '{print $4}' | cut -d/ -f1 | head -n1
        end
        echo -n "External IP: "
        curl -fsS ifconfig.me; or curl -fsS ipinfo.io/ip; or echo "N/A"
    end
    echo
end
alias whatismyip='whatsmyip'

# trim leading/trailing whitespace
function trim
    set var "$argv"
    set var (string trim "$var")
    printf '%s' "$var"
end

# Yazi wrapper
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    set cwd (cat "$tmp")
    if test -n "$cwd"; and test "$cwd" != "$PWD"
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end
