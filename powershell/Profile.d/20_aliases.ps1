# Core command aliases
# Remove built-in aliases that conflict with our functions
if (Get-Alias ls -ErrorAction SilentlyContinue) { Remove-Item Alias:ls -Force }
if (Get-Alias ll -ErrorAction SilentlyContinue) { Remove-Item Alias:ll -Force }
if (Get-Alias la -ErrorAction SilentlyContinue) { Remove-Item Alias:la -Force }

# Use eza if available, otherwise fall back to PowerShell commands
if (Get-Command eza -ErrorAction SilentlyContinue) {
    # eza aliases (similar to bash configuration)
    function ll { eza -l --icons --group-directories-first @args }
    function la { eza -Alh --icons --group-directories-first @args }
    function ls { eza -a --icons --group-directories-first @args }
    function lla { eza -Al --icons --group-directories-first @args }
    function las { eza -A --icons --group-directories-first @args }
    function lw { eza -a1 --icons @args }
    function lr { eza -lR --icons --group-directories-first @args }
    function lt { eza -ltrh --icons --group-directories-first @args }
    function lk { eza -lSrh --icons --group-directories-first @args }
    function lx { eza -lXBh --icons --group-directories-first @args }
    function lc { eza -ltcrh --icons --group-directories-first @args }
    function lu { eza -lturh --icons --group-directories-first @args }
    function lm { eza -alh --icons @args | more }
    function labc { eza -lap --icons --group-directories-first @args }
    function lf { eza -l --icons --group-directories-first @args | Select-String -Pattern "^d" -NotMatch }
    function ldir { eza -l --icons --group-directories-first @args | Select-String -Pattern "^d" }
    function lg { eza -l --git --icons --group-directories-first @args }
    function tree { eza -T --icons --group-directories-first @args }
    function treed { eza -T -D --icons --group-directories-first @args }
} else {
    # Fallback to PowerShell commands
    function ll { Get-ChildItem -Force @args }
    function la { Get-ChildItem -Force @args }
    function ls { Get-ChildItem -Force @args }
}

Set-Alias -Name grep -Value Select-String
Set-Alias -Name which -Value Get-Command

# Directory navigation aliases with auto-ls
function home { Set-Location ~; ls }
function cd.. { Set-Location ..; ls }
function .. { Set-Location ..; ls }
function ... { Set-Location ../..; ls }
function .... { Set-Location ../../..; ls }
function ..... { Set-Location ../../../..; ls }

# Custom cd function with auto-ls
function Set-LocationWithLs {
    param([string]$Path)
    if ($Path) {
        Microsoft.PowerShell.Management\Set-Location $Path
    } else {
        Microsoft.PowerShell.Management\Set-Location
    }
    try {
        # Call the ls function directly
        if (Get-Command eza -ErrorAction SilentlyContinue) {
            eza -a --icons --group-directories-first
        } else {
            Get-ChildItem -Force
        }
    } catch {
        Write-Warning "Failed to run ls: $($_.Exception.Message)"
    }
}

# Remove the built-in cd alias and create our own
if (Get-Alias cd -ErrorAction SilentlyContinue) {
    Remove-Item Alias:cd -Force -ErrorAction SilentlyContinue
}
Set-Alias -Name cd -Value Set-LocationWithLs

# Utility aliases
function ff { fastfetch -c all }
function cls { Clear-Host }
function ps { Get-Process | Format-Table -AutoSize }

# Windows-specific aliases
function apps { winget update --all --include-unknown --force }
function flushdns { Clear-DnsClientCache; Write-Host "DNS has been flushed" }
function bios { shutdown.exe /r /fw /f /t 0 }
