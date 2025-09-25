# Exit early if not interactive
if ($Host.Name -ne 'ConsoleHost' -and $Host.Name -ne 'Windows Terminal') {
    return
}

# Check if this is a regular SSH session, not SFTP
if ($env:SSH_CLIENT -and $env:SSH_TTY -or -not $env:SSH_CLIENT) {
    # Run fastfetch only in an interactive session
    if (Get-Command fastfetch -ErrorAction SilentlyContinue) {
        fastfetch
    }
}
