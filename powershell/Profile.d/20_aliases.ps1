# Core command aliases
# Use eza if available, otherwise fall back to PowerShell commands
if (Get-Command eza -ErrorAction SilentlyContinue) {
    # eza aliases (similar to bash configuration)
    function ll { eza -l --icons --group-directories-first }
    function la { eza -Alh --icons --group-directories-first }
    function ls { eza -a --icons --group-directories-first }
    function lla { eza -Al --icons --group-directories-first }
    function las { eza -A --icons --group-directories-first }
    function lw { eza -a1 --icons }
    function lr { eza -lR --icons --group-directories-first }
    function lt { eza -ltrh --icons --group-directories-first }
    function lk { eza -lSrh --icons --group-directories-first }
    function lx { eza -lXBh --icons --group-directories-first }
    function lc { eza -ltcrh --icons --group-directories-first }
    function lu { eza -lturh --icons --group-directories-first }
    function lm { eza -alh --icons | more }
    function labc { eza -lap --icons --group-directories-first }
    function lf { eza -l --icons --group-directories-first | Select-String -Pattern "^d" -NotMatch }
    function ldir { eza -l --icons --group-directories-first | Select-String -Pattern "^d" }
    function lg { eza -l --git --icons --group-directories-first }
    function tree { eza -T --icons --group-directories-first }
    function treed { eza -T -D --icons --group-directories-first }
} else {
    # Fallback to PowerShell commands
    Set-Alias -Name ll -Value Get-ChildItem
    Set-Alias -Name la -Value Get-ChildItem
    Set-Alias -Name ls -Value Get-ChildItem
}

Set-Alias -Name grep -Value Select-String
Set-Alias -Name which -Value Get-Command

# Directory navigation aliases
function home { Set-Location ~ }
function cd.. { Set-Location .. }
function .. { Set-Location .. }
function ... { Set-Location ../.. }
function .... { Set-Location ../../.. }
function ..... { Set-Location ../../../.. }

# Utility aliases
function ff { fastfetch -c all }
function cls { Clear-Host }
function ps { Get-Process | Format-Table -AutoSize }

# Windows-specific aliases
function apps { winget update --all --include-unknown --force }
function flushdns { Clear-DnsClientCache; Write-Host "DNS has been flushed" }
function bios { shutdown.exe /r /fw /f /t 0 }
