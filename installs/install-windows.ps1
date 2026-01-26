# Windows bootstrap for dotfiles

$DOTFILES = "$env:USERPROFILE\.local\share\dotfiles"
$PROFILEPATH = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
$CONFIGDIR = "$env:USERPROFILE\.config"
$MISEDIR = "$CONFIGDIR\mise"
$FASTDIR = "$CONFIGDIR\fastfetch"

# Ensure dirs
New-Item -ItemType Directory -Force -Path (Split-Path $PROFILEPATH) | Out-Null
New-Item -ItemType Directory -Force -Path $MISEDIR | Out-Null
New-Item -ItemType Directory -Force -Path $FASTDIR | Out-Null

Write-Host "📂 Linking configs..."
Copy-Item -Force "$DOTFILES\powershell\Microsoft.PowerShell_profile.ps1" $PROFILEPATH
Copy-Item -Force "$DOTFILES\config\starship.toml" "$CONFIGDIR\starship.toml"
Copy-Item -Force "$DOTFILES\config\mise\config.toml" "$MISEDIR\config.toml"
Copy-Item -Force "$DOTFILES\config\fastfetch\windows.jsonc" "$FASTDIR\config.jsonc"

Write-Host "⚙️ Installing tools..."
if (-not (Get-Command starship -ErrorAction SilentlyContinue)) {
  winget install -e --id Starship.Starship
}
if (-not (Get-Command fastfetch -ErrorAction SilentlyContinue)) {
  winget install -e --id fastfetch-cli
}
if (-not (Get-Command zoxide -ErrorAction SilentlyContinue)) {
  winget install -e --id ajeetdsouza.zoxide
}
if (-not (Get-Command mise -ErrorAction SilentlyContinue)) {
  winget install -e --id jdx.mise
}
# Note: Terminal-Icons not needed when using eza (which provides its own icons)

Write-Host "✅ Windows dotfiles installed. Restart PowerShell."